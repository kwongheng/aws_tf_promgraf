#!/bin/bash

# Specify the Grafana version to install
GRAFANA_VERSION="12.1.0"  # Change this to your desired version

# Update system packages
echo "Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

# Install required dependencies
echo "Installing dependencies..."
sudo apt-get install -y adduser libfontconfig1 musl

# Download and install the specified Grafana version
echo "Downloading and installing Grafana version ${GRAFANA_VERSION}..."
wget https://dl.grafana.com/oss/release/grafana_${GRAFANA_VERSION}_amd64.deb
sudo dpkg -i grafana_${GRAFANA_VERSION}_amd64.deb

# Clean up downloaded package
rm grafana_${GRAFANA_VERSION}_amd64.deb

# Enable and start Grafana service
echo "Starting Grafana service..."
sudo systemctl daemon-reload
sudo systemctl enable grafana-server
sudo systemctl start grafana-server

# Check Grafana service status
echo "Checking Grafana service status..."
sudo systemctl status grafana-server --no-pager

# Output access information
echo "Grafana installation completed!"
echo "Access Grafana at: http://<your-ec2-public-ip>:3000"
echo "Default login: admin/admin (change password on first login)"
