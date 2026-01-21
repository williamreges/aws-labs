#!/bin/bash

set -e

echo "Installing AWS Session Manager..."

# Detect OS
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux - detect distribution
    if [[ -f /etc/debian_version ]]; then
        # Debian/Ubuntu
        curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/ubuntu_64bit/session-manager-plugin.deb" -o "session-manager-plugin.deb"
        sudo dpkg -i session-manager-plugin.deb
        rm session-manager-plugin.deb
    else
        # Red Hat/CentOS
        curl "https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/session-manager-plugin.rpm" -o "session-manager-plugin.rpm"
        sudo yum install -y session-manager-plugin.rpm
        rm session-manager-plugin.rpm
    fi

elif [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    curl "https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/osx/sessionmanagerplugin.pkg" -o "sessionmanagerplugin.pkg"
    sudo installer -pkg sessionmanagerplugin.pkg -target /
    rm sessionmanagerplugin.pkg
else
    echo "Unsupported OS"
    exit 1
fi

# Verify installation
session-manager-plugin --version

echo "AWS Session Manager installed successfully!"