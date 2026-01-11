# Bose SoundTouch Web API Documentation

**Version 1.0** | **Effective January 7, 2026**

This repository contains the complete documentation for the Bose SoundTouch Web API, which enables developers to create applications that control and interact with Bose SoundTouch speakers.

## Overview

The SoundTouch Web API provides a REST-based HTTP interface on port 8090 and WebSocket notifications on port 8080 for controlling Compatible Bose Products. The API allows you to:

- Control playback (play, pause, stop, skip tracks)
- Manage volume and bass settings
- Select audio sources (Bluetooth, AUX, streaming services)
- Configure presets
- Create multi-room zones
- Receive real-time notifications via WebSockets

## Quick Start

### Discovery

Discover SoundTouch devices on your network using:
- **SSDP** (Simple Services Discovery Protocol) - UDP unicast/multicast
- **mDNS/Bonjour** - Zero-configuration networking

### Basic Usage

All API commands are sent over HTTP to port 8090 of your SoundTouch device:

```bash
# Get device information
curl http://192.168.1.100:8090/info

# Set volume to 30
curl -X POST http://192.168.1.100:8090/volume -d '<volume>30</volume>'

# Get now playing information
curl http://192.168.1.100:8090/now_playing
```

### WebSocket Notifications

Connect to port 8080 using the "gabbo" protocol to receive real-time updates:

```javascript
const socket = new WebSocket("ws://192.168.1.100:8080", "gabbo");
socket.onmessage = (event) => {
  console.log("Update:", event.data);
};
```

## Documentation

- **[Getting Started Guide](docs/getting-started.md)** - Setup and basic concepts
- **[API Reference](docs/api-reference/)** - Complete endpoint documentation
  - [Endpoints](docs/api-reference/endpoints.md)
  - [Data Types](docs/api-reference/data-types.md)
  - [Error Handling](docs/api-reference/errors.md)
- **[WebSocket Notifications](docs/websockets.md)** - Real-time event system
- **[OpenAPI Specification](schemas/openapi.yaml)** - Machine-readable API spec
- **[Code Examples](examples/)** - Sample code in multiple languages

## Key Features

### HTTP Methods
- **GET**: Retrieve current state (volume, now playing, presets, etc.)
- **POST**: Send commands (set volume, select source, create zones, etc.)

### Main Capabilities
- **Playback Control**: `/key` endpoint for play/pause/stop/skip
- **Source Selection**: `/select` and `/sources` for input switching
- **Volume Management**: `/volume` with mute support
- **Presets**: `/presets` for quick access to favorite stations
- **Multi-Room Audio**: `/getZone`, `/setZone`, `/addZoneSlave`, `/removeZoneSlave`
- **Device Info**: `/info`, `/name`, `/capabilities`
- **Audio Settings**: `/bass`, `/audiodspcontrols`, `/audioproducttonecontrols`

## Legal Notice

By using the SoundTouch Materials, you agree to the [Bose SoundTouch Web API Terms of Use](TERMS.md).

**Important**: The SoundTouch API and Compatible Bose Products are **not designed for mission-critical systems**. They are not fault-tolerant and should not be used in life support, emergency, or any application where failure could lead to death, injury, or environmental damage.

## Requirements

- Compatible Bose SoundTouch product connected to your network
- Network access on the same subnet as the device
- Port 8090 (HTTP API) and 8080 (WebSocket) accessible

## Compatible Products

Any internet or Bluetooth connected consumer electronic product manufactured by or on behalf of Bose that supports the SoundTouch Web API.

## Version History

| Version | Release Date | Notes |
|---------|--------------|-------|
| 1.0.0   | January 7, 2026 | Initial Release |

## Contributing

This is official documentation from Bose Corporation. For issues or corrections, please open an issue in this repository.

## Trademarks

Bose and SoundTouch are trademarks of Bose Corporation.

## License

See [TERMS.md](TERMS.md) for the complete Bose SoundTouch Web API Terms of Use.
