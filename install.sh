#!/bin/bash
################################################################################
# Fr3k AI Ecosystem - Complete Installation Script
# Installs and integrates all components for a production-ready AI agent system
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$REPO_DIR/installation.log"
CONFIG_DIR="$REPO_DIR/configs"
SRC_DIR="$REPO_DIR/src"

# Logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1" | tee -a "$LOG_FILE"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" | tee -a "$LOG_FILE"
    exit 1
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" | tee -a "$LOG_FILE"
}

info() {
    echo -e "${BLUE}[INFO]${NC} $1" | tee -a "$LOG_FILE"
}

################################################################################
# Phase 0: Prerequisites Check
################################################################################
check_prerequisites() {
    log "Phase 0: Checking prerequisites..."

    # Check OS
    if [[ ! -f /etc/os-release ]]; then
        error "Cannot determine OS. This script requires Linux."
    fi
    source /etc/os-release
    log "OS: $PRETTY_NAME"

    # Check architecture
    ARCH=$(uname -m)
    if [[ "$ARCH" != "aarch64" && "$ARCH" != "x86_64" ]]; then
        warning "Architecture $ARCH not officially supported. Continuing anyway..."
    fi
    log "Architecture: $ARCH"

    # Check disk space
    AVAILABLE=$(df -BG "$HOME" | awk 'NR==2 {print $4}' | sed 's/G//')
    if [[ $AVAILABLE -lt 10 ]]; then
        error "Insufficient disk space. Need at least 10GB free, have ${AVAILABLE}GB."
    fi
    log "Disk space: ${AVAILABLE}GB available"

    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        warning "Running as root. Some services may not start correctly."
    fi

    log "✓ Prerequisites check passed"
}

################################################################################
# Phase 1: Install System Dependencies
################################################################################
install_dependencies() {
    log "Phase 1: Installing system dependencies..."

    # Update package list
    info "Updating package lists..."
    sudo apt-get update -qq >> "$LOG_FILE" 2>&1

    # Install basic dependencies
    info "Installing basic dependencies..."
    sudo apt-get install -y \
        curl \
        wget \
        git \
        build-essential \
        python3.13 \
        python3.13-venv \
        python3-pip \
        postgresql \
        postgresql-contrib \
        pkg-config \
        libssl-dev \
        >> "$LOG_FILE" 2>&1

    # Install Node.js 22.x
    if ! command -v node &> /dev/null; then
        info "Installing Node.js 22.x..."
        curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash - >> "$LOG_FILE" 2>&1
        sudo apt-get install -y nodejs >> "$LOG_FILE" 2>&1
    fi

    # Install Bun
    if ! command -v bun &> /dev/null; then
        info "Installing Bun runtime..."
        curl -fsSL https://bun.sh/install | bash >> "$LOG_FILE" 2>&1
        # Add Bun to PATH for this session
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
    fi

    # Install Docker
    if ! command -v docker &> /dev/null; then
        info "Installing Docker..."
        curl -fsSL https://get.docker.com | sh >> "$LOG_FILE" 2>&1
        sudo usermod -aG docker "$USER" >> "$LOG_FILE" 2>&1
        warning "Docker installed. You may need to log out and back in for group changes to take effect."
    fi

    # Install uv (Python package manager)
    if ! command -v uv &> /dev/null; then
        info "Installing uv package manager..."
        curl -LsSf https://astral.sh/uv/install.sh | sh >> "$LOG_FILE" 2>&1
    fi

    # Install Fabric
    if ! command -v fabric &> /dev/null; then
        info "Installing Fabric AI patterns..."
        curl -fsSL https://raw.githubusercontent.com/danielmiessler/fabric/main/scripts/installer/install.sh | bash >> "$LOG_FILE" 2>&1
    fi

    log "✓ Dependencies installed successfully"
    log "  Node.js: $(node --version)"
    log "  npm: $(npm --version)"
    log "  Python: $(python3.13 --version)"
    log "  Bun: $(bun --version)"
    log "  Docker: $(docker --version | cut -d' ' -f3)"
    log "  Fabric: $(fabric --version 2>&1 | head -n1 || echo 'installed')"
}

################################################################################
# Phase 2: Setup PostgreSQL for memU
################################################################################
setup_database() {
    log "Phase 2: Setting up PostgreSQL database..."

    # Start PostgreSQL
    sudo systemctl start postgresql >> "$LOG_FILE" 2>&1
    sudo systemctl enable postgresql >> "$LOG_FILE" 2>&1

    # Create database and user
    info "Creating database and user..."
    sudo -u postgres psql -c "DROP DATABASE IF EXISTS memudb;" >> "$LOG_FILE" 2>&1 || true
    sudo -u postgres psql -c "DROP USER IF EXISTS memu;" >> "$LOG_FILE" 2>&1 || true
    sudo -u postgres psql -c "CREATE USER memu WITH PASSWORD 'memu_password';" >> "$LOG_FILE" 2>&1
    sudo -u postgres psql -c "CREATE DATABASE memudb OWNER memu;" >> "$LOG_FILE" 2>&1
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE memudb TO memu;" >> "$LOG_FILE" 2>&1

    # Enable pgvector extension
    info "Enabling pgvector extension..."
    sudo -u postgres psql -d memudb -c "CREATE EXTENSION IF NOT EXISTS vector;" >> "$LOG_FILE" 2>&1

    log "✓ PostgreSQL setup complete"
}

################################################################################
# Phase 3: Install Python Dependencies
################################################################################
install_python_deps() {
    log "Phase 3: Installing Python dependencies..."

    # Create Python virtual environment
    info "Creating Python virtual environment..."
    cd "$REPO_DIR"
    python3.13 -m venv venv
    source venv/bin/activate

    # Install Python packages
    info "Installing Python packages..."
    pip install --upgrade pip >> "$LOG_FILE" 2>&1

    # Install memU dependencies
    pip install \
        fastapi \
        uvicorn[standard] \
        sqlalchemy \
        pgvector \
        psycopg2-binary \
        alembic \
        openai \
        langchain \
        anthropic \
        python-multipart \
        python-dotenv \
        >> "$LOG_FILE" 2>&1

    # Install PAI dependencies
    pip install \
        rich \
        typer \
        pydantic \
        pydantic-settings \
        httpx \
        >> "$LOG_FILE" 2>&1

    log "✓ Python dependencies installed"
}

################################################################################
# Phase 4: Install Node.js Dependencies
################################################################################
install_node_deps() {
    log "Phase 4: Installing Node.js dependencies..."

    # Install core Node.js packages
    info "Installing Node.js packages..."

    # Telegram relay dependencies
    mkdir -p "$SRC_DIR/telegram/relay"
    cd "$SRC_DIR/telegram/relay"
    npm init -y >> "$LOG_FILE" 2>&1
    npm install \
        @clack/prompts \
        telegram \
        node-telegram-bot-api \
        dotenv \
        >> "$LOG_FILE" 2>&1

    # Agent reachout dependencies
    mkdir -p "$SRC_DIR/telegram/reachout"
    cd "$SRC_DIR/telegram/reachout"
    npm init -y >> "$LOG_FILE" 2>&1
    npm install \
        telegram \
        node-telegram-bot-api \
        dotenv \
        >> "$LOG_FILE" 2>&1

    cd "$REPO_DIR"

    log "✓ Node.js dependencies installed"
}

################################################################################
# Phase 5: Copy and Integrate Source Code
################################################################################
integrate_source() {
    log "Phase 5: Integrating source code from cloned repositories..."

    # Copy Telegram relay
    if [[ -d "$HOME/github/claude-telegram-relay" ]]; then
        info "Integrating claude-telegram-relay..."
        cp -r "$HOME/github/claude-telegram-relay/"* "$SRC_DIR/telegram/relay/"
    fi

    # Copy agent-reachout
    if [[ -d "$HOME/github/agent-reachout" ]]; then
        info "Integrating agent-reachout..."
        cp -r "$HOME/github/agent-reachout/"* "$SRC_DIR/telegram/reachout/"
    fi

    # Copy memU
    if [[ -d "$HOME/github/memU" ]]; then
        info "Integrating memU..."
        cp -r "$HOME/github/memU/"* "$SRC_DIR/memory/memu/"
    fi

    # Copy memU-server
    if [[ -d "$HOME/github/memU-server" ]]; then
        info "Integrating memU-server..."
        cp -r "$HOME/github/memU-server/"* "$SRC_DIR/memory/memu-server/"
    fi

    # Copy PAI
    if [[ -d "$HOME/github/Personal_AI_Infrastructure" ]]; then
        info "Integrating PAI..."
        cp -r "$HOME/github/Personal_AI_Infrastructure/"* "$SRC_DIR/memory/pai/"
    fi

    # Copy Substrate
    if [[ -d "$HOME/github/Substrate" ]]; then
        info "Integrating Substrate..."
        cp -r "$HOME/github/Substrate/"* "$SRC_DIR/frameworks/substrate/"
    fi

    # Copy TELOS
    if [[ -d "$HOME/github/Telos" ]]; then
        info "Integrating TELOS..."
        cp -r "$HOME/github/Telos/"* "$SRC_DIR/frameworks/telos/"
    fi

    # Copy TheAlgorithm
    if [[ -d "$HOME/github/TheAlgorithm" ]]; then
        info "Integrating TheAlgorithm..."
        cp -r "$HOME/github/TheAlgorithm/"* "$SRC_DIR/frameworks/algorithm/"
    fi

    # Copy hooks mastery
    if [[ -d "$HOME/github/claude-code-hooks-mastery" ]]; then
        info "Integrating claude-code-hooks-mastery..."
        cp -r "$HOME/github/claude-code-hooks-mastery/"* "$SRC_DIR/observability/hooks/"
    fi

    # Copy multi-agent observability
    if [[ -d "$HOME/github/claude-code-hooks-multi-agent-observability" ]]; then
        info "Integrating observability system..."
        cp -r "$HOME/github/claude-code-hooks-multi-agent-observability/"* "$SRC_DIR/observability/monitoring/"
    fi

    log "✓ Source code integrated"
}

################################################################################
# Phase 6: Configuration Files
################################################################################
setup_configuration() {
    log "Phase 6: Creating configuration files..."

    # Create .env template
    cat > "$REPO_DIR/.env.example" << 'EOF'
# Fr3k AI Ecosystem - Environment Configuration

# Claude Code / Z.AI
ANTHROPIC_API_KEY=your-zai-api-key-here
ANTHROPIC_BASE_URL=https://api.z.ai/api/anthropic

# ElevenLabs (Voice)
ELEVENLABS_API_KEY=your-elevenlabs-api-key-here
ELEVENLABS_VOICE_ID=21m00Tcm4TlvDq8ikWAM  # Rachel (female voice)

# Telegram Bot
TELEGRAM_BOT_TOKEN=your-telegram-bot-token-here
TELEGRAM_ALLOWED_USERS=-1003412651630,8188688460

# Database
DATABASE_URL=postgresql://memu:memu_password@localhost:5432/memudb

# OpenClaw
OPENCLAW_GATEWAY_PORT=18789
OPENCLAW_GATEWAY_TOKEN=f043d2007f33da2f3b40bf810b10091c471edbfe5c4bb8d5

# Optional APIs
TAVILY_API_KEY=your-tavily-key-here
GOOGLE_API_KEY=your-google-key-here
EOF

    # Create configs directory structure
    mkdir -p "$CONFIG_DIR"

    # Copy ElevenLabs config
    cat > "$CONFIG_DIR/elevenlabs.json" << 'EOF'
{
  "provider": "elevenlabs",
  "apiKey": "",
  "voiceId": "21m00Tcm4TlvDq8ikWAM",
  "voiceSettings": {
    "speed": 1.28,
    "stability": 0.5,
    "similarity_boost": 0.75
  }
}
EOF

    # Copy OpenClaw config (updated)
    cp "$HOME/.openclaw/openclaw.json" "$CONFIG_DIR/openclaw.json.bak"

    log "✓ Configuration files created"
    warning "Please edit .env file with your API keys before running services"
}

################################################################################
# Phase 7: Create systemd Services
################################################################################
create_services() {
    log "Phase 7: Creating systemd services..."

    # Telegram Relay Service
    cat > "$REPO_DIR/services/fr3k-telegram-relay.service" << EOF
[Unit]
Description=Fr3k Telegram Relay - Claude Code Bridge
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$SRC_DIR/telegram/relay
ExecStart=/usr/bin/node index.js
Restart=always
RestartSec=10
Environment=NODE_ENV=production

[Install]
WantedBy=multi-user.target
EOF

    # memU Server Service
    cat > "$REPO_DIR/services/fr3k-memu-server.service" << EOF
[Unit]
Description=Fr3k memU Memory Server
After=network.target postgresql.service

[Service]
Type=simple
User=$USER
WorkingDirectory=$SRC_DIR/memory/memu-server
Environment="PATH=$REPO_DIR/venv/bin"
ExecStart=$REPO_DIR/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

    # Health Agent Service
    cat > "$REPO_DIR/services/fr3k-health-agent.service" << EOF
[Unit]
Description=Fr3k Health Monitoring Agent
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$SRC_DIR/agents
Environment="PATH=$REPO_DIR/venv/bin"
ExecStart=$REPO_DIR/venv/bin/python health_agent.py
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF

    # Git Agent Service
    cat > "$REPO_DIR/services/fr3k-git-agent.service" << EOF
[Unit]
Description=Fr3k Git Automation Agent
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$REPO_DIR
Environment="PATH=$REPO_DIR/venv/bin:/usr/bin:/bin"
ExecStart=$REPO_DIR/venv/bin/python src/agents/git_agent.py
Restart=always
RestartSec=300

[Install]
WantedBy=multi-user.target
EOF

    # Install services
    info "Installing systemd services..."
    sudo cp "$REPO_DIR/services/"*.service /etc/systemd/system/
    sudo systemctl daemon-reload >> "$LOG_FILE" 2>&1

    log "✓ systemd services created and installed"
    info "Services can be enabled with: ./scripts/enable-services.sh"
}

################################################################################
# Phase 8: Create Management Scripts
################################################################################
create_scripts() {
    log "Phase 8: Creating management scripts..."

    # Start all script
    cat > "$REPO_DIR/scripts/start-all.sh" << 'EOF'
#!/bin/bash
echo "Starting all Fr3k AI Ecosystem services..."
sudo systemctl start fr3k-telegram-relay
sudo systemctl start fr3k-memu-server
sudo systemctl start fr3k-health-agent
sudo systemctl start fr3k-git-agent
echo "✓ All services started"
EOF

    # Stop all script
    cat > "$REPO_DIR/scripts/stop-all.sh" << 'EOF'
#!/bin/bash
echo "Stopping all Fr3k AI Ecosystem services..."
sudo systemctl stop fr3k-git-agent
sudo systemctl stop fr3k-health-agent
sudo systemctl stop fr3k-memu-server
sudo systemctl stop fr3k-telegram-relay
echo "✓ All services stopped"
EOF

    # Status script
    cat > "$REPO_DIR/scripts/status.sh" << 'EOF'
#!/bin/bash
echo "Fr3k AI Ecosystem Service Status"
echo "=================================="
systemctl status fr3k-*.service
EOF

    # Health check script
    cat > "$REPO_DIR/scripts/health-check.sh" << 'EOF'
#!/bin/bash
echo "Fr3k AI Ecosystem Health Check"
echo "=============================="
services=("fr3k-telegram-relay" "fr3k-memu-server" "fr3k-health-agent" "fr3k-git-agent")
for service in "${services[@]}"; do
    if systemctl is-active --quiet "$service"; then
        echo "✓ $service: RUNNING"
    else
        echo "✗ $service: STOPPED"
    fi
done
EOF

    # Make scripts executable
    chmod +x "$REPO_DIR/scripts/"*.sh

    log "✓ Management scripts created"
}

################################################################################
# Phase 9: Installation Summary
################################################################################
print_summary() {
    cat << 'EOF'

╔════════════════════════════════════════════════════════════════╗
║                  Installation Complete! ✓                      ║
╚════════════════════════════════════════════════════════════════╝

Next Steps:

1. Configure API Keys:
   cp .env.example .env
   nano .env
   # Add your API keys

2. Enable Services:
   ./scripts/enable-services.sh

3. Start Services:
   ./scripts/start-all.sh

4. Check Status:
   ./scripts/status.sh

Services Installed:
  • fr3k-telegram-relay   - Telegram bot integration
  • fr3k-memu-server      - Proactive memory system
  • fr3k-health-agent     - Health monitoring
  • fr3k-git-agent        - Git automation

Logs:
  journalctl -u fr3k-telegram-relay -f
  journalctl -u fr3k-memu-server -f

Documentation:
  • README.md              - Main documentation
  • docs/INSTALLATION.md   - Detailed installation guide
  • docs/CONFIGURATION.md  - Configuration reference

Support:
  https://github.com/fr3kstyle/fr3k-ai-ecosystem/issues

EOF
}

################################################################################
# Main Installation Flow
################################################################################
main() {
    echo -e "${BLUE}"
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════╗
║          Fr3k AI Ecosystem - Complete Installation           ║
║                                                                ║
║  Integrated AI Agent Infrastructure for Linux ARM64           ║
╚════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}"

    log "Starting installation at $(date)"
    log "Installation log: $LOG_FILE"

    check_prerequisites
    install_dependencies
    setup_database
    install_python_deps
    install_node_deps
    integrate_source
    setup_configuration
    create_services
    create_scripts

    log "Installation completed successfully at $(date)"
    print_summary
}

# Run main installation
main "$@"
