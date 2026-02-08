# Fr3k AI Ecosystem - Complete Integration

> **Integrated AI Agent Infrastructure for Linux ARM64**
> Combining the best of Telegram-Claude integration, AI patterns, memory systems, and autonomous agents into one cohesive ecosystem.

## 🎯 Mission

Build a production-ready, always-on AI agent system that:
- ✅ Responds via Telegram 24/7
- ✅ Remembers everything with proactive memory
- ✅ Uses proven AI patterns for tasks
- ✅ Monitors and heals itself autonomously
- ✅ Continuously learns and improves
- ✅ Optimized for Linux ARM64 (Raspberry Pi)

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    FR3K AI ECOSYSTEM                         │
│                  (Single Repository)                         │
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌──────────────┐      ┌──────────────┐      ┌──────────────┐
│   TELEGRAM   │      │    MEMORY    │      │  FRAMEWORKS  │
│   LAYER      │      │    LAYER     │      │              │
│              │      │              │      │              │
│ • Relay      │      │ • memU       │      │ • Fabric     │
│ • Bot        │      │ • PAI        │      │ • Substrate  │
│ • Reachout   │      │ • Substrate  │      │ • TELOS      │
│ • Remote     │      │ • ZAI API    │      │ • Algorithm  │
└──────────────┘      └──────────────┘      └──────────────┘
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              │
                              ▼
                    ┌──────────────────┐
                    │   AGENT ORC      │
                    │  (Orchestrator)  │
                    │                  │
                    │ • Health Agent   │
                    │ • Git Agent      │
                    │ • Update Agent   │
                    │ • Memory Agent   │
                    └──────────────────┘
```

## 📦 Components

### 1. Telegram Integration Layer
- **claude-telegram-relay** - Minimal relay with systemd (Core)
- **agent-reachout** - Proactive notifications
- **Claude-Code-Remote** - Multi-channel control

### 2. Memory & Intelligence Layer
- **memU** - 24/7 proactive memory capture
- **Personal_AI_Infrastructure** - PAI framework with skills
- **Substrate** - Evidence and solutions knowledge base

### 3. Frameworks & Patterns
- **Fabric** - 100+ AI prompt patterns
- **TELOS** - Deep context (mission, goals, strategies)
- **TheAlgorithm** - Problem-solving methodology

### 4. Observability & Automation
- **claude-code-hooks-mastery** - Hook patterns
- **claude-code-hooks-multi-agent-observability** - Monitoring
- **infinite-agentic-loop** - Autonomous patterns

### 5. Background Agents (4x Autonomous)
- **Health Agent** - Monitors services, auto-restart failures
- **Git Agent** - Auto-commits, pushes, syncs upstream
- **Update Agent** - Keeps dependencies updated
- **Memory Agent** - Manages memU proactive memory

## 🚀 Quick Start

### Prerequisites
```bash
# Linux ARM64 (tested on Raspberry Pi 500)
# Debian 12+ / Ubuntu 20.04+
# 13GB+ free disk space
```

### One-Line Install
```bash
curl -fsSL https://raw.githubusercontent.com/fr3kstyle/fr3k-ai-ecosystem/main/install.sh | bash
```

### Manual Install
```bash
# 1. Clone repository
git clone https://github.com/fr3kstyle/fr3k-ai-ecosystem.git
cd fr3k-ai-ecosystem

# 2. Run installation script
./scripts/install-all.sh

# 3. Configure API keys
./scripts/configure-api-keys.sh

# 4. Start all services
./scripts/start-all.sh
```

## 📋 Installation Steps

### Phase 1: Core Infrastructure (15 min)
1. ✅ Install dependencies (Node.js, Python 3.13, Bun, Docker)
2. ✅ Install Fabric AI patterns
3. ✅ Configure ZAI API with ElevenLabs voice
4. ✅ Setup memU memory system with PostgreSQL
5. ✅ Configure PAI framework

### Phase 2: Telegram Integration (10 min)
6. ✅ Create Telegram bot via @BotFather
7. ✅ Configure claude-telegram-relay with systemd
8. ✅ Setup agent-reachout for notifications
9. ✅ Test Telegram connection

### Phase 3: Background Agents (10 min)
10. ✅ Deploy 4 autonomous agents
11. ✅ Configure systemd services
12. ✅ Setup health monitoring
13. ✅ Enable auto-start on boot

### Phase 4: Integration & Testing (10 min)
14. ✅ Test end-to-end flow
15. ✅ Verify memory persistence
16. ✅ Test proactive notifications
17. ✅ Run integration tests

**Total Time: ~45 minutes**

## 🔧 Configuration

### API Keys Required
```bash
# Claude Code (Z.AI)
export ANTHROPIC_API_KEY="your-zai-key"

# ElevenLabs (Voice)
export ELEVENLABS_API_KEY="your-elevenlabs-key"

# Telegram Bot
export TELEGRAM_BOT_TOKEN="your-bot-token"

# Optional: OpenAI, Tavily, Google
```

### Environment Files
- `.env` - Production environment variables
- `.env.development` - Development overrides
- `configs/elevenlabs.json` - Voice configuration
- `configs/telegram.json` - Bot configuration
- `configs/memory.json` - memU settings

## 📊 Services

### systemd Services
```bash
# Core services
fr3k-telegram-relay.service      # Telegram relay
fr3k-memu-server.service          # Memory backend

# Agent services
fr3k-health-agent.service         # Health monitor
fr3k-git-agent.service            # Git automation
fr3k-update-agent.service         # Dependency updates
fr3k-memory-agent.service         # Memory management

# Status
systemctl status fr3k-*.service
```

### Service Management
```bash
# Start all services
./scripts/start-all.sh

# Stop all services
./scripts/stop-all.sh

# Restart all services
./scripts/restart-all.sh

# View logs
journalctl -u fr3k-telegram-relay -f
journalctl -u fr3k-memu-server -f
```

## 🎯 Usage Examples

### Telegram Bot Commands
```bash
# Send message via Telegram
/telegram "Analyze this code and suggest improvements"

# Proactive notification
# (Agent reaches out when task completes)

# Memory recall
/telegram "What did I work on yesterday?"
```

### Fabric Patterns
```bash
# Use Fabric patterns
fabric --pattern extract_summary --text "file.txt"
fabric --pattern improve_writing --text "article.md"

# List all patterns
fabric --listpatterns
```

### Memory Operations
```bash
# Store memory
curl -X POST http://localhost:8000/api/memory \
  -H "Content-Type: application/json" \
  -d '{"content": "User prefers TypeScript"}'

# Retrieve memory
curl http://localhost:8000/api/memory/search?q=TypeScript
```

### PAI Workflow
```bash
# Activate PAI
pai activate

# Use The Algorithm
pai algorithm "How should I optimize this system?"

# View TELOS context
pai telos show
```

## 📈 Monitoring

### Health Dashboard
```bash
# Check all services
./scripts/health-check.sh

# View agent status
./scripts/agent-status.sh

# Memory statistics
./scripts/memory-stats.sh
```

### Logs
```bash
# All logs
tail -f logs/fr3k-ecosystem.log

# Service-specific logs
journalctl -u fr3k-telegram-relay -f
journalctl -u fr3k-memu-server -f
```

## 🔄 Automation

### Git Agent
- Auto-commits changes every 5 minutes
- Pushes to GitHub hourly
- Syncs with upstream daily
- Creates intelligent commit messages

### Health Agent
- Monitors all services every 30 seconds
- Auto-restarts failed services
- Alerts on critical failures
- Generates health reports

### Update Agent
- Checks for updates daily
- Tests updates in staging
- Applies updates safely
- Rolls back on failure

### Memory Agent
- Captures interactions in real-time
- Organizes memories by topic
- Retrieves relevant context
- Proactively suggests actions

## 🛠️ Development

### Project Structure
```
fr3k-ai-ecosystem/
├── README.md
├── install.sh                    # One-line installer
├── package.json                  # Root package file
├── configs/                      # Configuration files
├── scripts/                      # Installation & management
├── src/                          # Integrated source code
│   ├── telegram/                 # Telegram integration
│   ├── memory/                   # Memory systems (memU, PAI)
│   ├── frameworks/               # Fabric, TELOS, Algorithm
│   ├── agents/                   # Background agents
│   └── observability/            # Hooks & monitoring
├── services/                     # systemd service files
├── tests/                        # Integration tests
├── docs/                         # Documentation
└── docker/                       # Docker configurations
```

### Adding New Features
1. Fork the repository
2. Create feature branch
3. Make changes
4. Run tests: `./scripts/test.sh`
5. Submit pull request

## 🧪 Testing

### Run All Tests
```bash
./scripts/test.sh
```

### Test Individual Components
```bash
# Test Telegram integration
./tests/test-telegram.sh

# Test memory system
./tests/test-memory.sh

# Test agents
./tests/test-agents.sh
```

## 📚 Documentation

- [Installation Guide](docs/INSTALLATION.md)
- [Configuration Guide](docs/CONFIGURATION.md)
- [Architecture](docs/ARCHITECTURE.md)
- [API Reference](docs/API.md)
- [Troubleshooting](docs/TROUBLESHOOTING.md)
- [Contributing](docs/CONTRIBUTING.md)

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📜 License

This project integrates multiple open-source frameworks:
- Each component retains its original license
- Integration code is MIT licensed
- See LICENSE file for details

## 🙏 Acknowledgments

Integrated frameworks and their authors:
- Daniel Miessler: Fabric, PAI, TELOS, TheAlgorithm, Substrate
- memU team: Proactive memory system
- Claude Code community: Hooks, observability, Telegram integrations
- All original framework authors

## 📞 Support

- **Issues**: https://github.com/fr3kstyle/fr3k-ai-ecosystem/issues
- **Discussions**: https://github.com/fr3kstyle/fr3k-ai-ecosystem/discussions
- **Telegram**: @fr3kstyle_bot (once deployed)

---

**Built with ❤️ for the open-source AI community**

*Last Updated: 2026-02-08*
*Version: 1.0.0*
*Status: Alpha - Under Active Development*
