# WebSocket Notifications

The SoundTouch Web API provides real-time notifications via WebSocket connections on port 8080.

## Overview

WebSocket notifications allow your application to receive immediate updates when the device state changes, eliminating the need for polling. The WebSocket server pushes XML-formatted messages whenever:

- Volume or mute state changes
- Now playing information changes
- Presets are updated
- Multi-room zones are modified
- Network connection status changes
- And more...

**Port:** `8080`
**Protocol:** `"gabbo"`
**Format:** XML messages

## Establishing a Connection

### JavaScript/Browser

```javascript
const socket = new WebSocket("ws://192.168.1.100:8080", "gabbo");

socket.onopen = () => {
  console.log("Connected to SoundTouch WebSocket");
};

socket.onmessage = (event) => {
  console.log("Received update:", event.data);
  // Parse XML and handle the update
  parseUpdate(event.data);
};

socket.onerror = (error) => {
  console.error("WebSocket error:", error);
};

socket.onclose = () => {
  console.log("WebSocket connection closed");
  // Implement reconnection logic
};
```

### Python

```python
import websocket
import xml.etree.ElementTree as ET

def on_message(ws, message):
    print(f"Received: {message}")
    root = ET.fromstring(message)
    handle_update(root)

def on_error(ws, error):
    print(f"Error: {error}")

def on_close(ws, close_status_code, close_msg):
    print("Connection closed")

def on_open(ws):
    print("Connected to SoundTouch")

# Create WebSocket connection
ws = websocket.WebSocketApp(
    "ws://192.168.1.100:8080",
    subprotocols=["gabbo"],
    on_message=on_message,
    on_error=on_error,
    on_close=on_close,
    on_open=on_open
)

ws.run_forever()
```

### Node.js

```javascript
const WebSocket = require('ws');

const ws = new WebSocket('ws://192.168.1.100:8080', 'gabbo');

ws.on('open', () => {
  console.log('Connected to SoundTouch');
});

ws.on('message', (data) => {
  console.log('Received:', data.toString());
  // Parse XML and handle update
});

ws.on('error', (error) => {
  console.error('WebSocket error:', error);
});

ws.on('close', () => {
  console.log('Connection closed');
});
```

## Notification Format

All notifications follow this basic structure:

```xml
<updates deviceID="{MACADDR}">
  <{notificationType}/>
  <!-- or -->
  <{notificationType}>
    <!-- notification-specific data -->
  </{notificationType}>
</updates>
```

## Notification Types

### Volume Change

Sent when volume or mute state changes.

**Notification:**
```xml
<updates deviceID="AABBCCDDEEFF">
  <volumeUpdated/>
</updates>
```

**Action:** Call `GET /volume` to get current volume and mute state.

**Alternative format (includes data):**
```xml
<updates deviceID="AABBCCDDEEFF">
  <volume>
    <targetvolume>30</targetvolume>
    <actualvolume>30</actualvolume>
  </volume>
</updates>
```

---

### Now Playing Change

Sent when the currently playing content changes.

**Notification:**
```xml
<updates deviceID="AABBCCDDEEFF">
  <nowPlayingUpdated>
    <nowPlaying deviceID="AABBCCDDEEFF" source="SPOTIFY">
      <ContentItem source="SPOTIFY" location="spotify:track:abc123"
                   sourceAccount="user@example.com" isPresetable="true">
        <itemName>Song Title</itemName>
      </ContentItem>
      <track>Song Title</track>
      <artist>Artist Name</artist>
      <album>Album Name</album>
      <stationName>My Playlist</stationName>
      <art artImageStatus="IMAGE_PRESENT">http://example.com/cover.jpg</art>
      <playStatus>PLAY_STATE</playStatus>
      <description>Album description</description>
      <stationLocation>New York</stationLocation>
    </nowPlaying>
  </nowPlayingUpdated>
</updates>
```

**Action:** The notification contains complete now playing data. Optionally call `GET /now_playing` for updates.

---

### Presets Updated

Sent when presets are added, removed, or modified.

**Notification:**
```xml
<updates deviceID="AABBCCDDEEFF">
  <presetsUpdated>
    <presets>
      <preset id="1" createdOn="1704672000000" updatedOn="1704672000000">
        <ContentItem source="PANDORA" location="R123456"
                     sourceAccount="user@example.com" isPresetable="true">
          <itemName>Today's Hits</itemName>
        </ContentItem>
      </preset>
      <preset id="2" createdOn="1704586000000" updatedOn="1704586000000">
        <ContentItem source="SPOTIFY" location="spotify:playlist:xyz"
                     sourceAccount="user@example.com" isPresetable="true">
          <itemName>Chill Vibes</itemName>
        </ContentItem>
      </preset>
      <!-- ... more presets ... -->
    </presets>
  </presetsUpdated>
</updates>
```

**Action:** The notification contains complete preset list. Use this data or call `GET /presets`.

---

### Bass Change

Sent when bass level changes.

**Notification:**
```xml
<updates deviceID="AABBCCDDEEFF">
  <bassUpdated/>
</updates>
```

**Action:** Call `GET /bass` to get current bass level.

---

### Zone Updated

Sent when multi-room zone configuration changes.

**Notification:**
```xml
<updates deviceID="AABBCCDDEEFF">
  <zoneUpdated/>
</updates>
```

**Action:** Call `GET /getZone` to get updated zone configuration.

#### Zone Change Scenarios

**Slave device joining a zone:**
```xml
<updates deviceID="112233445566">
  <zoneUpdated/>
</updates>
<updates deviceID="112233445566">
  <volumeUpdated/>
</updates>
<updates deviceID="112233445566">
  <volumeUpdated/>
</updates>
<updates deviceID="112233445566">
  <nowPlayingUpdated/>
</updates>
```

**Slave device leaving a zone:**
```xml
<updates deviceID="112233445566">
  <zoneUpdated/>
</updates>
<updates deviceID="112233445566">
  <nowPlayingUpdated/>
</updates>
```

**Master notifies when slave joins:**
```xml
<updates deviceID="AABBCCDDEEFF">
  <zoneUpdated/>
</updates>
<updates deviceID="112233445566">
  <nowPlayingUpdated/>
</updates>
```

**Master notifies when slave leaves:**
```xml
<updates deviceID="AABBCCDDEEFF">
  <zoneUpdated/>
</updates>
<updates deviceID="AABBCCDDEEFF">
  <zoneUpdated/>
</updates>
```

---

### Recents Updated

Sent when the recents list changes.

**Notification:**
```xml
<updates deviceID="AABBCCDDEEFF">
  <recentsUpdated>
    <recents>
      <recent deviceID="AABBCCDDEEFF" utcTime="1704672000000">
        <contentItem source="SPOTIFY" location="spotify:track:xyz"
                     sourceAccount="user@example.com" isPresetable="true">
          <itemName>Recently Played Song</itemName>
        </contentItem>
      </recent>
      <recent deviceID="AABBCCDDEEFF" utcTime="1704586000000">
        <contentItem source="PANDORA" location="R123456"
                     sourceAccount="user@example.com" isPresetable="true">
          <itemName>Recent Station</itemName>
        </contentItem>
      </recent>
      <!-- ... more recents ... -->
    </recents>
  </recentsUpdated>
</updates>
```

**Action:** Use the notification data or call `GET /recents` if available.

---

### Account Mode Changed

Sent when the device's cloud account association changes.

**Notification:**
```xml
<updates deviceID="AABBCCDDEEFF">
  <acctModeUpdated/>
</updates>
```

**Action:** Call `GET /info` to get updated account information.

---

### Sources Changed

Sent when available sources change.

**Notification:**
```xml
<updates deviceID="AABBCCDDEEFF">
  <sourcesUpdated/>
</updates>
```

**Action:** Call `GET /sources` to get updated source list.

---

### Now Selection Change

Sent when a preset is selected.

**Notification:**
```xml
<updates deviceID="AABBCCDDEEFF">
  <nowSelectionUpdated>
    <preset id="3">
      <ContentItem source="SPOTIFY" location="spotify:playlist:abc"
                   sourceAccount="user@example.com" isPresetable="true">
        <itemName>Workout Mix</itemName>
      </ContentItem>
    </preset>
  </nowSelectionUpdated>
</updates>
```

**Action:** The notification indicates which preset was selected.

---

### Network Connection Status

Sent when network connection state changes.

**Notification:**
```xml
<updates deviceID="AABBCCDDEEFF">
  <connectionStateUpdated/>
</updates>
```

**Action:** Monitor for connectivity changes.

---

### Info Changed

Sent when device information changes (e.g., device name).

**Notification:**
```xml
<updates deviceID="AABBCCDDEEFF">
  <infoUpdated/>
</updates>
```

**Action:** Call `GET /info` to get updated device information.

---

### Software Update Status Change

Sent during firmware updates.

**Notification:**
```xml
<updates deviceID="AABBCCDDEEFF">
  <swUpdateStatusUpdated/>
</updates>
```

**Action:** No action typically required. Informational only.

---

### Site Survey Results Change

Sent when Wi-Fi site survey results change.

**Notification:**
```xml
<updates deviceID="AABBCCDDEEFF">
  <siteSurveyResultsUpdated/>
</updates>
```

**Action:** No action typically required. Informational only.

---

### Error Notification

Sent when an error occurs.

**Format:** (Details not specified in original documentation)

```xml
<updates deviceID="AABBCCDDEEFF">
  <errorNotification>
    <!-- Error details -->
  </errorNotification>
</updates>
```

## Handling Notifications

### Complete Example

```javascript
class SoundTouchWebSocket {
  constructor(deviceIp) {
    this.deviceIp = deviceIp;
    this.ws = null;
    this.reconnectDelay = 1000;
    this.maxReconnectDelay = 30000;
  }

  connect() {
    this.ws = new WebSocket(`ws://${this.deviceIp}:8080`, 'gabbo');

    this.ws.onopen = () => {
      console.log('WebSocket connected');
      this.reconnectDelay = 1000; // Reset delay on successful connection
    };

    this.ws.onmessage = (event) => {
      this.handleMessage(event.data);
    };

    this.ws.onerror = (error) => {
      console.error('WebSocket error:', error);
    };

    this.ws.onclose = () => {
      console.log('WebSocket closed, reconnecting...');
      this.reconnect();
    };
  }

  handleMessage(xmlData) {
    const parser = new DOMParser();
    const xmlDoc = parser.parseFromString(xmlData, 'text/xml');

    const updates = xmlDoc.getElementsByTagName('updates')[0];
    const deviceID = updates.getAttribute('deviceID');

    // Check for different notification types
    if (updates.getElementsByTagName('volumeUpdated').length > 0) {
      this.onVolumeUpdate(deviceID);
    }

    if (updates.getElementsByTagName('nowPlayingUpdated').length > 0) {
      const nowPlaying = updates.getElementsByTagName('nowPlaying')[0];
      this.onNowPlayingUpdate(deviceID, nowPlaying);
    }

    if (updates.getElementsByTagName('presetsUpdated').length > 0) {
      const presets = updates.getElementsByTagName('presets')[0];
      this.onPresetsUpdate(deviceID, presets);
    }

    if (updates.getElementsByTagName('zoneUpdated').length > 0) {
      this.onZoneUpdate(deviceID);
    }

    // Add handlers for other notification types...
  }

  onVolumeUpdate(deviceID) {
    // Fetch current volume
    fetch(`http://${this.deviceIp}:8090/volume`)
      .then(res => res.text())
      .then(xml => {
        // Parse and handle volume data
        console.log('Volume updated:', xml);
      });
  }

  onNowPlayingUpdate(deviceID, nowPlayingElement) {
    // Extract now playing information from the notification
    const track = nowPlayingElement.getElementsByTagName('track')[0]?.textContent;
    const artist = nowPlayingElement.getElementsByTagName('artist')[0]?.textContent;
    const album = nowPlayingElement.getElementsByTagName('album')[0]?.textContent;

    console.log(`Now playing: ${track} by ${artist} from ${album}`);

    // Update UI
    this.updateNowPlayingUI(track, artist, album);
  }

  onPresetsUpdate(deviceID, presetsElement) {
    // Parse presets from notification
    const presets = Array.from(presetsElement.getElementsByTagName('preset'));
    console.log(`${presets.length} presets updated`);

    // Update UI
    this.updatePresetsUI(presets);
  }

  onZoneUpdate(deviceID) {
    // Fetch current zone configuration
    fetch(`http://${this.deviceIp}:8090/getZone`)
      .then(res => res.text())
      .then(xml => {
        console.log('Zone updated:', xml);
      });
  }

  reconnect() {
    setTimeout(() => {
      console.log('Attempting to reconnect...');
      this.connect();

      // Exponential backoff
      this.reconnectDelay = Math.min(
        this.reconnectDelay * 2,
        this.maxReconnectDelay
      );
    }, this.reconnectDelay);
  }

  disconnect() {
    if (this.ws) {
      this.ws.close();
    }
  }

  updateNowPlayingUI(track, artist, album) {
    // Implement UI update logic
  }

  updatePresetsUI(presets) {
    // Implement UI update logic
  }
}

// Usage
const soundtouch = new SoundTouchWebSocket('192.168.1.100');
soundtouch.connect();
```

## Best Practices

### 1. Implement Reconnection Logic

WebSocket connections can drop. Always implement automatic reconnection:

```javascript
function connectWithRetry(ip, maxRetries = Infinity) {
  let retries = 0;
  let delay = 1000;

  function connect() {
    const ws = new WebSocket(`ws://${ip}:8080`, 'gabbo');

    ws.onopen = () => {
      retries = 0;
      delay = 1000;
    };

    ws.onclose = () => {
      if (retries < maxRetries) {
        setTimeout(connect, delay);
        delay = Math.min(delay * 2, 30000);
        retries++;
      }
    };

    return ws;
  }

  return connect();
}
```

### 2. Parse XML Efficiently

```javascript
function parseNotification(xmlString) {
  const parser = new DOMParser();
  const doc = parser.parseFromString(xmlString, 'text/xml');

  // Check for parsing errors
  const parserError = doc.querySelector('parsererror');
  if (parserError) {
    console.error('XML parsing error:', parserError.textContent);
    return null;
  }

  return doc;
}
```

### 3. Debounce Rapid Updates

Some events may fire rapidly. Debounce updates to avoid excessive API calls:

```javascript
function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

// Usage
const debouncedVolumeUpdate = debounce((deviceID) => {
  fetchVolume(deviceID);
}, 300);
```

### 4. Handle Multiple Devices

If controlling multiple devices, maintain separate WebSocket connections:

```javascript
class MultiDeviceManager {
  constructor() {
    this.devices = new Map();
  }

  addDevice(deviceIp) {
    const ws = new SoundTouchWebSocket(deviceIp);
    ws.connect();
    this.devices.set(deviceIp, ws);
  }

  removeDevice(deviceIp) {
    const ws = this.devices.get(deviceIp);
    if (ws) {
      ws.disconnect();
      this.devices.delete(deviceIp);
    }
  }

  broadcast(command) {
    this.devices.forEach(ws => {
      // Send command to each device via HTTP
    });
  }
}
```

### 5. Combine with HTTP API

Use WebSockets for notifications and HTTP API for commands:

```javascript
class SoundTouchController {
  constructor(deviceIp) {
    this.deviceIp = deviceIp;
    this.baseUrl = `http://${deviceIp}:8090`;

    // WebSocket for notifications
    this.ws = new SoundTouchWebSocket(deviceIp);
    this.ws.connect();
  }

  // HTTP commands
  async setVolume(level) {
    const response = await fetch(`${this.baseUrl}/volume`, {
      method: 'POST',
      body: `<volume>${level}</volume>`
    });
    return response.text();
  }

  async play() {
    await this.sendKey('PLAY');
  }

  async pause() {
    await this.sendKey('PAUSE');
  }

  async sendKey(key) {
    await fetch(`${this.baseUrl}/key`, {
      method: 'POST',
      body: `<key state="press" sender="MyApp">${key}</key>`
    });

    await fetch(`${this.baseUrl}/key`, {
      method: 'POST',
      body: `<key state="release" sender="MyApp">${key}</key>`
    });
  }

  // WebSocket handlers are in this.ws
}
```

## Troubleshooting

### Connection Fails

- Verify device IP address
- Check firewall allows port 8080
- Ensure "gabbo" protocol is specified
- Confirm device is on same network

### No Notifications Received

- Check WebSocket is connected (onopen fired)
- Verify device state is actually changing
- Try triggering obvious changes (volume, source selection)

### Connection Drops Frequently

- Implement exponential backoff reconnection
- Check network stability
- Monitor for device reboots/updates

### High Latency

- WebSocket notifications should be near-instant
- Check network congestion
- Verify device firmware is up to date

## Summary

- Connect to `ws://{device-ip}:8080` with protocol `"gabbo"`
- Listen for XML-formatted notifications
- Implement reconnection logic for reliability
- Use notifications to trigger UI updates
- Combine WebSocket (notifications) with HTTP API (commands)
- Handle multiple notification types appropriately
