#!/bin/bash

# Install necessary packages
sudo apt-get update
sudo apt-get install -y realmd sssd sssd-tools libnss-sss libpam-sss adcli

# Discover the domain
realm discover yourdomain.com

# Join the domain
echo 'your-password' | realm join -U your-domain-username yourdomain.com

# Enable SSSD
sudo systemctl enable sssd
sudo systemctl start sssd

# Configure PAM and NSS for AD authentication
sudo authselect select sssd with-mkhomedir --force

# Restart services
sudo systemctl restart sssd
