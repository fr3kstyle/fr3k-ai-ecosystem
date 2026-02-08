#!/usr/bin/env python3
"""
Fr3k Health Monitoring Agent
Monitors all services and auto-restarts failures
"""

import subprocess
import time
import logging
from datetime import datetime
from typing import List, Dict

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/var/log/fr3k-health-agent.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger('HealthAgent')

# Services to monitor
SERVICES = [
    'fr3k-telegram-relay',
    'fr3k-memu-server',
    'fr3k-git-agent',
    'openclaw-gateway'
]

# Health check intervals
CHECK_INTERVAL = 30  # seconds
RESTART_DELAY = 5    # seconds

def check_service_status(service_name: str) -> bool:
    """Check if a service is running"""
    try:
        result = subprocess.run(
            ['systemctl', 'is-active', service_name],
            capture_output=True,
            text=True,
            timeout=5
        )
        return result.returncode == 0
    except Exception as e:
        logger.error(f"Error checking {service_name}: {e}")
        return False

def restart_service(service_name: str) -> bool:
    """Restart a failed service"""
    try:
        logger.warning(f"Restarting {service_name}...")
        result = subprocess.run(
            ['sudo', 'systemctl', 'restart', service_name],
            capture_output=True,
            text=True,
            timeout=30
        )
        if result.returncode == 0:
            logger.info(f"✓ {service_name} restarted successfully")
            time.sleep(RESTART_DELAY)
            return check_service_status(service_name)
        else:
            logger.error(f"✗ Failed to restart {service_name}: {result.stderr}")
            return False
    except Exception as e:
        logger.error(f"Error restarting {service_name}: {e}")
        return False

def get_service_stats() -> Dict[str, Dict]:
    """Get statistics for all services"""
    stats = {}
    for service in SERVICES:
        try:
            # Get CPU and memory usage
            result = subprocess.run(
                ['systemctl', 'show', service, '--property=CPUUsage,MemoryCurrent'],
                capture_output=True,
                text=True,
                timeout=5
            )
            output = result.stdout.strip()
            cpu = memory = "N/A"
            for line in output.split('\n'):
                if 'CPUUsage=' in line:
                    cpu = line.split('=')[1]
                elif 'MemoryCurrent=' in line:
                    mem_bytes = int(line.split('=')[1])
                    memory = f"{mem_bytes // 1024 // 1024}M"

            stats[service] = {
                'running': check_service_status(service),
                'cpu': cpu,
                'memory': memory
            }
        except Exception as e:
            logger.error(f"Error getting stats for {service}: {e}")
            stats[service] = {'running': False, 'cpu': 'N/A', 'memory': 'N/A'}

    return stats

def send_alert(message: str):
    """Send alert notification via agent-reachout"""
    try:
        # TODO: Integrate with agent-reachout
        logger.info(f"ALERT: {message}")
    except Exception as e:
        logger.error(f"Error sending alert: {e}")

def generate_health_report() -> str:
    """Generate a health status report"""
    stats = get_service_stats()
    report = ["\n=== Fr3k AI Ecosystem Health Report ==="]
    report.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    report.append("")

    running = 0
    for service, stat in stats.items():
        status = "✓ RUNNING" if stat['running'] else "✗ STOPPED"
        report.append(f"{service}:")
        report.append(f"  Status: {status}")
        report.append(f"  CPU: {stat['cpu']}")
        report.append(f"  Memory: {stat['memory']}")
        if stat['running']:
            running += 1

    report.append(f"\nTotal: {running}/{len(SERVICES)} services running")
    return '\n'.join(report)

def main():
    """Main health monitoring loop"""
    logger.info("Starting Fr3k Health Monitoring Agent")
    logger.info(f"Monitoring {len(SERVICES)} services: {', '.join(SERVICES)}")

    while True:
        try:
            # Check all services
            for service in SERVICES:
                if not check_service_status(service):
                    logger.warning(f"Service {service} is not running")
                    if restart_service(service):
                        logger.info(f"Successfully recovered {service}")
                    else:
                        send_alert(f"Service {service} failed to restart after multiple attempts")

            # Generate and log health report
            report = generate_health_report()
            logger.info(report)

            # Save report to file
            with open('/tmp/fr3k-health-report.txt', 'w') as f:
                f.write(report)

            # Wait before next check
            time.sleep(CHECK_INTERVAL)

        except KeyboardInterrupt:
            logger.info("Health monitoring agent stopped by user")
            break
        except Exception as e:
            logger.error(f"Error in health monitoring loop: {e}")
            time.sleep(CHECK_INTERVAL)

if __name__ == '__main__':
    main()
