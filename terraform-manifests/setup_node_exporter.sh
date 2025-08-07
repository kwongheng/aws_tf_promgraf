#!/bin/bash

# Exit on any error
set -e

# Variables
NODE_EXPORTER_VERSION="1.9.1"  # Check https://github.com/prometheus/node_exporter/releases for the latest version
USER="node_exporter"
GROUP="node_exporter"
INSTALL_DIR="/opt/node_exporter"
DATA_DIR="/var/lib/node_exporter"

echo "Starting Prometheus Node Exporter installation..."

# Update package list
sudo apt update

# Install prerequisites
sudo apt install -y wget curl

# Create Node Exporter user and group
if ! id -u $USER > /dev/null 2>&1; then
    sudo useradd --no-create-home --shell /bin/false $USER
    sudo groupadd $GROUP || true
    sudo usermod -a -G $GROUP $USER
fi

# Create directories
sudo mkdir -p $INSTALL_DIR $DATA_DIR
sudo chown $USER:$GROUP $DATA_DIR $INSTALL_DIR

# Download and extract Node Exporter
echo "Downloading Node Exporter v${NODE_EXPORTER_VERSION}..."
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz -O /tmp/node_exporter.tar.gz
tar -xzf /tmp/node_exporter.tar.gz -C /tmp
sudo mv /tmp/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter $INSTALL_DIR/
sudo chown -R $USER:$GROUP $INSTALL_DIR
rm -rf /tmp/node_exporter*

# Create systemd service file
echo "Setting up Node Exporter as a systemd service..."
cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=$USER
Group=$GROUP
Type=simple
ExecStart=$INSTALL_DIR/node_exporter \
  --collector.systemd \
  --web.listen-address=0.0.0.0:9100

Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable, and start Node Exporter
sudo systemctl daemon-reload
sudo systemctl enable node_exporter
sudo systemctl start node_exporter

# Verify Node Exporter is running
if sudo systemctl is-active --quiet node_exporter; then
    echo "Node Exporter is running. Access metrics at http://<your-ec2-public-ip>:9100/metrics"
else
    echo "Failed to start Node Exporter. Check logs with: sudo journalctl -u node_exporter"
    exit 1
fi

# Clean up
echo "Cleaning up..."
sudo apt clean

echo "Prometheus Node Exporter installation completed successfully!"
