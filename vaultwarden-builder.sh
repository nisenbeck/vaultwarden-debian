#!/bin/bash
set -e

# Configuration
DEBIAN_VERSIONS=("bullseye" "bookworm")
ARCH=$(dpkg --print-architecture)
REPO_URL="https://github.com/nisenbeck/vaultwarden-debian.git"
REPO_DIR="vaultwarden-debian"
HTTP_PORT=80

# Functions for colored output
log_info() {
    echo -e "\033[0;36m[INFO]\033[0m $1"
}

log_success() {
    echo -e "\033[0;32m[SUCCESS]\033[0m $1"
}

log_error() {
    echo -e "\033[0;31m[ERROR]\033[0m $1"
}

# Install dependencies
log_info "Installing dependencies..."
apt-get update
apt-get install -y git curl gnupg ca-certificates apparmor build-essential patch psmisc python3
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  \"$(. /etc/os-release && echo "$VERSION_CODENAME")\" stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
log_success "Dependencies installed"

# Clone or update repository
if [ -d "$REPO_DIR" ]; then
    log_info "Repository already exists, updating..."
    cd "$REPO_DIR"
    git pull
else
    log_info "Cloning repository..."
    git clone "$REPO_URL"
    cd "$REPO_DIR"
fi
log_success "Repository ready"

# Run builds
log_info "Starting builds for architecture: $ARCH"
for VERSION in "${DEBIAN_VERSIONS[@]}"; do
    log_info "Building for $VERSION..."
    ./build.sh -a "$ARCH" -o "$VERSION"
    log_success "Build for $VERSION completed"
done

# Check if dist directory exists
if [ ! -d "dist" ]; then
    log_error "dist directory was not created!"
    exit 1
fi

# Start HTTP server
log_success "All builds completed!"
log_info "Starting HTTP server on port $HTTP_PORT..."

# Get public IP
PUBLIC_IP=$(curl -s https://checkip.amazonaws.com)

log_info "Packages available at: http://$PUBLIC_IP:$HTTP_PORT"
echo ""
log_info "Press Ctrl+C to stop"
python3 -m http.server --directory dist $HTTP_PORT