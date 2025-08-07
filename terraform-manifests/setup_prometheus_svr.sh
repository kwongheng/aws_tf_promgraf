#!/bin/bash

# Exit on any error
set -e

# Variables
PROMETHEUS_VERSION="3.5.0"  # Check https://github.com/prometheus/prometheus/releases for the latest version
USER="prometheus"
GROUP="prometheus"
INSTALL_DIR="/opt/prometheus"
CONFIG_DIR="/etc/prometheus"
DATA_DIR="/var/lib/prometheus"

echo "Starting Prometheus installation..."

# Update package list
sudo apt update

# Install prerequisites
sudo apt install -y wget curl

# Create Prometheus user and group
if ! id -u $USER > /dev/null 2>&1; then
    sudo useradd --no-create-home --shell /bin/false $USER
    sudo groupadd $GROUP || true
    sudo usermod -a -G $GROUP $USER
fi

# Create directories
sudo mkdir -p $INSTALL_DIR $CONFIG_DIR $DATA_DIR
sudo chown $USER:$GROUP $DATA_DIR $CONFIG_DIR

# Download and extract Prometheus
echo "Downloading Prometheus v${PROMETHEUS_VERSION}..."
wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz -O /tmp/prometheus.tar.gz
tar -xzf /tmp/prometheus.tar.gz -C /tmp
sudo mv /tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64/prometheus /tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64/promtool $INSTALL_DIR/
sudo chown -R $USER:$GROUP $INSTALL_DIR
rm -rf /tmp/prometheus*

# Create basic Prometheus configuration
echo "Creating Prometheus configuration..."
cat <<EOF | sudo tee $CONFIG_DIR/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOF
sudo chown $USER:$GROUP $CONFIG_DIR/prometheus.yml
sudo chmod 644 $CONFIG_DIR/prometheus.yml

# Create systemd service file
echo "Setting up Prometheus as a systemd service..."
cat <<EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Monitoring
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
Group=$GROUP
Type=simple
ExecStart=$INSTALL_DIR/prometheus \
  --config.file=$CONFIG_DIR/prometheus.yml \
  --storage.tsdb.path=$DATA_DIR \
  --web.listen-address=0.0.0.0:9090

Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable, and start Prometheus
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus

# Verify Prometheus is running
if sudo systemctl is-active --quiet prometheus; then
    echo "Prometheus is running. Access it at http://<your-ec2-public-ip>:9090"
else
    echo "Failed to start Prometheus. Check logs with: sudo journalctl -u prometheus"
    exit 1
fi

# Clean up
echo "Cleaning up..."
sudo apt clean

echo "Prometheus installation completed successfully!"
