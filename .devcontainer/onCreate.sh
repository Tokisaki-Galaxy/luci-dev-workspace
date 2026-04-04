#!/bin/bash
set -e

echo "🚀 Starting onCreate setup..."
export DEBIAN_FRONTEND=noninteractive

# 配置 pnpm store 目录
echo "📦 Configuring pnpm..."
# Use /tmp for store to avoid permission issues in different environments
mkdir -p /tmp/pnpm-store
pnpm config set store-dir /tmp/pnpm-store
export PNPM_HOME=/tmp/.pnpm

# 设置 copilot 配置
echo "🤖 Setting up Copilot MCP..."
mkdir -p ~/.copilot
cp /workspaces/luci-dev-workspace/.devcontainer/mcp-config.json ~/.copilot/

# 克隆仓库（如果不存在）
echo "📥 Cloning repositories..."
cd /workspaces/luci-dev-workspace

repos=("openwrt" "luci" "luci-app-2fa" "luci-app-webauthn")
for repo in "${repos[@]}"; do
  if [ ! -d "$repo" ]; then
    git clone https://github.com/tokisaki-galaxy/$repo
  fi
done

sudo apt-get update
sudo apt-get install -y \
    jq xvfb tree ripgrep \
    qemu-user-static binfmt-support build-essential \
    ccache gawk gettext libncurses5-dev libssl-dev \
    rsync unzip zlib1g-dev sshpass socat netcat-openbsd

npx --yes playwright install --with-deps chromium

echo "✨ onCreate setup complete!"
