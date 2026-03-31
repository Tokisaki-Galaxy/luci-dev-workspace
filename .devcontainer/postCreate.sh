#!/bin/bash
set -e

OPENWRT_IMAGE="openwrt/rootfs:x86-64-24.10.5"

echo "=== Setting up OpenWrt Docker Environment ==="

docker pull $OPENWRT_IMAGE

echo "Testing OpenWrt container execution..."
docker run --rm $OPENWRT_IMAGE /bin/ash -c "cat /etc/openwrt_release"

echo "Starting LuCI service verification..."
CONTAINER_NAME="dev-luci-check"
docker rm -f $CONTAINER_NAME 2>/dev/null || true

docker run -d --name "$CONTAINER_NAME" -p 8080:80 $OPENWRT_IMAGE /bin/ash -c '
    mkdir -p /var/lock /var/run
    opkg update && opkg install luci-base luci-compat
    /sbin/ubusd & sleep 1
    /sbin/procd & sleep 2
    /sbin/rpcd & sleep 1
    /usr/sbin/uhttpd -f -h /www -p 0.0.0.0:80 &
    tail -f /dev/null
'

sleep 5
if docker ps | grep -q "$CONTAINER_NAME"; then
    echo "SUCCESS: LuCI debug container is running on port 8080."
    docker rm -f "$CONTAINER_NAME"
else
    echo "ERROR: LuCI service failed to start."
    exit 1
fi

echo "Development environment is ready!"
