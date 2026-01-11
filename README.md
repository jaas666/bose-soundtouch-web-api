# Bose SoundTouch Web API Documentation

**Version 1.0** | **Effective January 7, 2026**

> **⚠️ DISCLAIMER**: This is an **unofficial** community repository. While the documentation is sourced from official Bose materials ([SoundTouch-Web-API.pdf](soundtouch-api.pdf)), this repository is **NOT** officially maintained, endorsed, or sponsored by Bose Corporation.
>
> **📝 Note**: This documentation was converted from PDF to Markdown using Claude Code. Code examples are provided for reference and **have not been tested**. Use at your own risk and please test thoroughly before deploying in production.
>
> **🤝 Contributions Welcome**: This is a community effort! If you find errors, have improvements, or want to add tested examples, please contribute via issues or pull requests.

## Why This Repository Exists

On **May 6, 2026**, Bose is ending cloud support for SoundTouch products. While Bose has graciously released a local-only app and published the Web API documentation, this community repository aims to preserve and make this critical documentation more accessible for developers.

### What's Changing (May 6, 2026)

**❌ Stopping:**
- Cloud-based music service browsing in the SoundTouch app
- Cloud-dependent multi-room features
- Remote access from outside your network

**✅ Still Working:**
- **Local network control** via the updated SoundTouch app
- **Web API** for custom integrations (this documentation!)
- **AirPlay** and **Spotify Connect**
- **Bluetooth** connectivity
- Basic playback, volume, and source control

### The Silver Lining

By releasing this Web API documentation, Bose has enabled the community to build custom control solutions that will work indefinitely on your local network. This repository makes that documentation easier to discover, search, and implement.

**Official Announcement:** [Bose SoundTouch End of Life](https://www.bose.com/soundtouch-end-of-life)

---

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

## Additional Resources

### Official Bose Information
- **[SoundTouch End of Life Announcement](https://www.bose.com/soundtouch-end-of-life)** - Official details from Bose
- **[Trade-In Program](https://www.bose.com/soundtouch-end-of-life)** - Up to $200 credit toward new Bose systems

### Community & News Coverage
- **[Bose SoundTouch End of Life Gets Less Painful With Public API Release](https://itsfoss.com/news/bose-soundtouch-api/)** - It's FOSS coverage
- **[Bose is ending SoundTouch's cloud features, but not entirely killing the speakers](https://www.techspot.com/news/110844-bose-ending-soundtouch-cloud-features-but-not-entirely.html)** - TechSpot article
- **[Bose Sets New Standard for End-of-Life Hardware: Open-Sourcing SoundTouch API](https://techplanet.today/post/bose-sets-new-standard-for-end-of-life-hardware-open-sourcing-soundtouch-api)** - TechPlanet coverage
- **[AVS Forum Discussion](https://www.avsforum.com/threads/bose-soundtouch-owners-left-hanging-%E2%80%94-cloud-shutdown-2026.3334275/)** - User community discussion

### Alternative Apps & Integrations
- **[SoundTouch App Alternatives](https://bose.fandom.com/wiki/SoundTouch_app_alternatives)** - Community wiki
- Consider building your own using this API documentation!

## Trademarks

Bose and SoundTouch are trademarks of Bose Corporation.

## License

See [TERMS.md](TERMS.md) for the complete Bose SoundTouch Web API Terms of Use.
