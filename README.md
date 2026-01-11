# Bose SoundTouch Web API Documentation

**Version 1.0** | **Effective January 7, 2026**

> **⚠️ DISCLAIMER**: This is an **unofficial** community repository. While the documentation is sourced from official Bose materials ([SoundTouch-Web-API.pdf](soundtouch-api.pdf)), this repository is **NOT** officially maintained, endorsed, or sponsored by Bose Corporation.
>
> **📝 Note**: This documentation was converted from PDF to Markdown using Claude Code. Code examples are provided for reference and **have not been tested**. Use at your own risk and please test thoroughly before deploying in production.
>
> **🤝 Contributions Welcome**: This is a community effort! If you find errors, have improvements, or want to add tested examples, please contribute via issues or pull requests.

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

## Original Source

This documentation was converted from the official [Bose SoundTouch Web API PDF](soundtouch-api.pdf) (Version 1.0, effective January 7, 2026).

**Original Source**: https://assets.bosecreative.com/m/496577402d128874/original/SoundTouch-Web-API.pdf

## Contributing

**We welcome contributions!** This is a community-maintained repository and your help is appreciated.

### How to Contribute

- **🐛 Found an error?** Open an issue describing the problem
- **✅ Tested the code?** Share your results and improvements
- **📚 Better examples?** Submit working code examples in your favorite language
- **🌍 Translations?** Help translate the docs to other languages
- **📖 Improvements?** Better explanations, diagrams, or formatting

### Contribution Guidelines

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/your-improvement`)
3. Make your changes
4. Test thoroughly (especially code examples!)
5. Commit with clear messages
6. Open a pull request

**Note**: Since the original documentation is from Bose Corporation, maintain accuracy to the official specification. Add clarifications and examples, but don't alter the core API documentation.

## Trademarks

Bose and SoundTouch are trademarks of Bose Corporation.

## License

See [TERMS.md](TERMS.md) for the complete Bose SoundTouch Web API Terms of Use.
