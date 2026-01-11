# Getting Started with the SoundTouch Web API

This guide will help you start developing applications that control Bose SoundTouch speakers.

## Prerequisites

- A Bose SoundTouch compatible device on your network
- Basic understanding of HTTP REST APIs
- Familiarity with XML (the API uses XML for request/response payloads)

## Device Discovery

Before you can communicate with a SoundTouch device, you need to find it on your network.

### SSDP Discovery

Simple Services Discovery Protocol uses unicast and multicast over UDP:

```python
import socket

# Send SSDP M-SEARCH
msg = 'M-SEARCH * HTTP/1.1\r\n' \
      'HOST: 239.255.255.250:1900\r\n' \
      'MAN: "ssdp:discover"\r\n' \
      'MX: 1\r\n' \
      'ST: urn:schemas-upnp-org:device:MediaRenderer:1\r\n\r\n'

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
sock.settimeout(2)
sock.sendto(msg.encode(), ('239.255.255.250', 1900))
```

### mDNS/Bonjour Discovery

Use zero-configuration networking to discover devices:

```bash
# On macOS/Linux with avahi
avahi-browse -r _soundtouch._tcp
```

### Manual Configuration

If you know your device's IP address, you can skip discovery and connect directly:

```bash
# Replace with your device IP
DEVICE_IP=192.168.1.100
```

## First API Call

Get basic device information:

```bash
curl http://${DEVICE_IP}:8090/info
```

**Response:**
```xml
<info deviceID="AABBCCDDEEFF">
  <name>Living Room</name>
  <type>SoundTouch 20</type>
  <margeAccountUUID>user@example.com</margeAccountUUID>
  <components>
    <component>
      <componentCategory>SCM</componentCategory>
      <softwareVersion>22.0.0.15571</softwareVersion>
      <serialNumber>066534P23110294AE</serialNumber>
    </component>
  </components>
  <networkInfo type="SMSC">
    <macAddress>AABBCCDDEEFF</macAddress>
    <ipAddress>192.168.1.100</ipAddress>
  </networkInfo>
</info>
```

## Basic Operations

### Control Playback

Send key presses using the `/key` endpoint:

```bash
# Play/Pause
curl -X POST http://${DEVICE_IP}:8090/key \
  -d '<key state="press" sender="MyApp">PLAY_PAUSE</key>'

curl -X POST http://${DEVICE_IP}:8090/key \
  -d '<key state="release" sender="MyApp">PLAY_PAUSE</key>'

# Volume Up
curl -X POST http://${DEVICE_IP}:8090/key \
  -d '<key state="press" sender="MyApp">VOLUME_UP</key>'

curl -X POST http://${DEVICE_IP}:8090/key \
  -d '<key state="release" sender="MyApp">VOLUME_UP</key>'
```

### Set Volume

```bash
# Set volume to 25 (range: 0-100)
curl -X POST http://${DEVICE_IP}:8090/volume \
  -d '<volume>25</volume>'

# Get current volume
curl http://${DEVICE_IP}:8090/volume
```

**Response:**
```xml
<volume deviceID="AABBCCDDEEFF">
  <targetvolume>25</targetvolume>
  <actualvolume>25</actualvolume>
  <muteenabled>false</muteenabled>
</volume>
```

### Select Source

```bash
# Switch to Bluetooth
curl -X POST http://${DEVICE_IP}:8090/select \
  -d '<ContentItem source="BLUETOOTH"></ContentItem>'

# Switch to AUX input
curl -X POST http://${DEVICE_IP}:8090/select \
  -d '<ContentItem source="AUX" sourceAccount="AUX"></ContentItem>'
```

### Get Available Sources

```bash
curl http://${DEVICE_IP}:8090/sources
```

**Response:**
```xml
<sources deviceID="AABBCCDDEEFF">
  <sourceItem source="BLUETOOTH" status="READY">Bluetooth</sourceItem>
  <sourceItem source="AUX" sourceAccount="AUX" status="READY">AUX</sourceItem>
  <sourceItem source="SPOTIFY" status="READY">Spotify</sourceItem>
  <sourceItem source="PANDORA" status="READY">Pandora</sourceItem>
</sources>
```

### Get Now Playing

```bash
curl http://${DEVICE_IP}:8090/now_playing
```

**Response:**
```xml
<nowPlaying deviceID="AABBCCDDEEFF" source="SPOTIFY">
  <ContentItem source="SPOTIFY" location="spotify:track:xyz"
               sourceAccount="user@example.com" isPresetable="true">
    <itemName>Song Title</itemName>
  </ContentItem>
  <track>Song Title</track>
  <artist>Artist Name</artist>
  <album>Album Name</album>
  <art artImageStatus="IMAGE_PRESENT">http://example.com/image.jpg</art>
  <playStatus>PLAY_STATE</playStatus>
</nowPlaying>
```

## WebSocket Notifications

To receive real-time updates, connect to the WebSocket endpoint:

```javascript
// JavaScript example
const socket = new WebSocket("ws://192.168.1.100:8080", "gabbo");

socket.onopen = () => {
  console.log("Connected to SoundTouch");
};

socket.onmessage = (event) => {
  console.log("Received:", event.data);
  // Parse XML and handle updates
};

socket.onerror = (error) => {
  console.error("WebSocket error:", error);
};
```

Common notifications you'll receive:
- `volumeUpdated` - Volume or mute changed
- `nowPlayingUpdated` - Track changed
- `presetsUpdated` - Presets modified
- `zoneUpdated` - Multi-room zone changed

See [WebSocket Notifications](websockets.md) for complete details.

## HTTP Methods Convention

The API uses a simple convention:
- **GET requests**: Retrieve current state (e.g., `/volume`, `/now_playing`, `/presets`)
- **POST requests**: Send commands or update state (e.g., `/key`, `/select`, `/volume`)

## Response Formats

### Success Response
```xml
<status>OK</status>
```

### Error Response
```xml
<errors deviceID="AABBCCDDEEFF">
  <error value="1019" name="CLIENT_XML_ERROR" severity="Unknown">
    XML parse error
  </error>
</errors>
```

## Best Practices

1. **Send Press and Release**: For `/key` commands, always send both press and release events
2. **Handle Errors**: Check for error responses and handle them gracefully
3. **Use WebSockets**: Subscribe to notifications instead of polling for status
4. **Respect Rate Limits**: Don't spam the API with rapid requests
5. **Test Incrementally**: Start with simple GET requests before implementing complex features

## Next Steps

- Explore the [complete API reference](api-reference/endpoints.md)
- Learn about [data types and enums](api-reference/data-types.md)
- Review [code examples](../examples/) in your preferred language
- Read the [WebSocket documentation](websockets.md) for real-time updates

## Common Issues

### Connection Refused
- Verify the device is on the same network
- Check firewall settings
- Ensure port 8090 is accessible

### Authentication Errors
- The API doesn't require authentication for local network access
- Cloud account features may require the device to be linked to a Bose account

### XML Parse Errors
- Ensure XML is properly formatted
- Escape special characters (`&`, `<`, `>`, `"`, `'`)
- Don't include XML declaration (`<?xml version="1.0"?>`)
