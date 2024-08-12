Installing Node.js across different operating systems requires different approaches due to the variations in package managers and system configurations. Below are scripts for installing Node.js on various operating systems:

### 1. **Ubuntu/Debian**

For Ubuntu and Debian-based distributions, you can use the following script. This script installs Node.js using the NodeSource repository to ensure you get the latest version.

```bash
#!/bin/bash

# Update package list
sudo apt update

# Install required packages
sudo apt install -y curl software-properties-common

# Add NodeSource repository
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -

# Install Node.js
sudo apt install -y nodejs

# Verify installation
node -v
npm -v
```

### 2. **CentOS/RHEL**

For CentOS and RHEL-based distributions, you can use the following script. It installs Node.js using the NodeSource repository as well.

```bash
#!/bin/bash

# Install required packages
sudo yum install -y curl

# Add NodeSource repository
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -

# Install Node.js
sudo yum install -y nodejs

# Verify installation
node -v
npm -v
```

### 3. **Fedora**

For Fedora, you can use the following script. Fedora users can also use the NodeSource repository.

```bash
#!/bin/bash

# Install required packages
sudo dnf install -y curl

# Add NodeSource repository
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -

# Install Node.js
sudo dnf install -y nodejs

# Verify installation
node -v
npm -v
```

### 4. **macOS**

For macOS, you can use Homebrew to install Node.js. Make sure you have Homebrew installed.

```bash
#!/bin/bash

# Install Node.js using Homebrew
brew install node

# Verify installation
node -v
npm -v
```

### 5. **Windows**

For Windows, you typically download and run the installer manually from the [Node.js website](https://nodejs.org/). However, if you want to automate the installation using PowerShell, you can use the following script:

```powershell
# Download Node.js installer
$nodeUrl = "https://nodejs.org/dist/v18.15.0/node-v18.15.0-x64.msi"
$installerPath = "$env:TEMP\nodejs-installer.msi"
Invoke-WebRequest -Uri $nodeUrl -OutFile $installerPath

# Install Node.js
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$installerPath`" /quiet" -Wait

# Verify installation
node -v
npm -v
```

### Summary

- **Ubuntu/Debian**: Use `apt` and NodeSource setup script.
- **CentOS/RHEL**: Use `yum` and NodeSource setup script.
- **Fedora**: Use `dnf` and NodeSource setup script.
- **macOS**: Use Homebrew.
- **Windows**: Use PowerShell script to download and install the MSI package.

Feel free to modify the versions and URLs based on your requirements or the latest Node.js releases.