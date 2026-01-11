#!/bin/bash
# Bose SoundTouch Web API - Basic curl Examples
# Replace DEVICE_IP with your SoundTouch device IP address

DEVICE_IP="192.168.1.100"
BASE_URL="http://${DEVICE_IP}:8090"

echo "=== Bose SoundTouch API Examples ==="
echo "Device: ${DEVICE_IP}"
echo ""

# Get device information
echo "1. Getting device information..."
curl -s "${BASE_URL}/info" | head -20
echo ""

# Get current volume
echo "2. Getting current volume..."
curl -s "${BASE_URL}/volume"
echo ""

# Set volume to 30
echo "3. Setting volume to 30..."
curl -X POST "${BASE_URL}/volume" -d '<volume>30</volume>'
echo ""

# Get available sources
echo "4. Getting available sources..."
curl -s "${BASE_URL}/sources"
echo ""

# Get now playing
echo "5. Getting now playing information..."
curl -s "${BASE_URL}/now_playing"
echo ""

# Play/Pause (press and release)
echo "6. Sending PLAY_PAUSE command..."
curl -X POST "${BASE_URL}/key" -d '<key state="press" sender="BashScript">PLAY_PAUSE</key>'
sleep 0.1
curl -X POST "${BASE_URL}/key" -d '<key state="release" sender="BashScript">PLAY_PAUSE</key>'
echo ""

# Get presets
echo "7. Getting presets..."
curl -s "${BASE_URL}/presets"
echo ""

# Get bass capabilities
echo "8. Getting bass capabilities..."
curl -s "${BASE_URL}/bassCapabilities"
echo ""

# Get zone configuration
echo "9. Getting zone configuration..."
curl -s "${BASE_URL}/getZone"
echo ""

# Get device capabilities
echo "10. Getting device capabilities..."
curl -s "${BASE_URL}/capabilities"
echo ""

echo "=== Examples Complete ==="
