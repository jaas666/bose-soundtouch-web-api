# Data Types

This document describes the special data types and enumerations used by the SoundTouch Web API.

## Primitive Types

### BOOL
Boolean value represented as a string.

**Valid values:**
- `"true"`
- `"false"`

**Example:**
```xml
<muteenabled>true</muteenabled>
<isPresetable>false</isPresetable>
```

### INT
A 32-bit signed integer.

**Range:** -2,147,483,648 to 2,147,483,647

**Example:**
```xml
<targetvolume>50</targetvolume>
<bass>0</bass>
```

### UINT
A 32-bit unsigned integer.

**Range:** 0 to 4,294,967,295

**Example:**
```xml
<step>5</step>
```

### UINT64
A 64-bit unsigned integer.

**Range:** 0 to 18,446,744,073,709,551,615

**Example:**
```xml
<createdOn>1704672000000</createdOn>
<utcTime>1704672000000</utcTime>
```

### STRING
Any valid XML-escaped string.

**Special characters must be escaped:**
- `&` → `&amp;`
- `<` → `&lt;`
- `>` → `&gt;`
- `"` → `&quot;`
- `'` → `&apos;`

**Example:**
```xml
<itemName>Rock &amp; Roll Station</itemName>
<artist>AC/DC</artist>
```

### IPADDR
An IP address represented as a string.

**Format:** IPv4 dotted decimal notation

**Example:**
```xml
<ipAddress>192.168.1.100</ipAddress>
```

### MACADDR
A MAC address represented as an uppercase string.

**Format:** 12 uppercase hexadecimal characters (no separators)

**Example:**
```xml
<macAddress>AABBCCDDEEFF</macAddress>
<deviceID>001122334455</deviceID>
```

### URL
A URL encoded as a string.

**Example:**
```xml
<art>http://example.com/album/cover.jpg</art>
<margeURL>https://worldwide.bose.com/</margeURL>
```

## Enumeration Types

### ART_STATUS

Album art availability status.

**Values:**
- `INVALID` - Art status is invalid/unknown
- `SHOW_DEFAULT_IMAGE` - Show default placeholder image
- `DOWNLOADING` - Art is currently being downloaded
- `IMAGE_PRESENT` - Art image is available

**Example:**
```xml
<art artImageStatus="IMAGE_PRESENT">http://example.com/cover.jpg</art>
```

### AUDIO_MODE

Audio processing mode for soundbars and home theater products.

**Values:**
- `AUDIO_MODE_DIRECT` - Direct audio mode (no processing)
- `AUDIO_MODE_NORMAL` - Normal audio mode
- `AUDIO_MODE_DIALOG` - Dialog enhancement mode
- `AUDIO_MODE_NIGHT` - Night mode (compressed dynamics)

**Example:**
```xml
<audiodspcontrols audiomode="AUDIO_MODE_DIALOG" videosyncaudiodelay="0"
                   supportedaudiomodes="AUDIO_MODE_NORMAL|AUDIO_MODE_DIALOG|AUDIO_MODE_NIGHT"/>
```

### KEY_VALUE

Remote control key values for the `/key` endpoint.

**Playback Control:**
- `PLAY` - Start playback
- `PAUSE` - Pause playback
- `STOP` - Stop playback
- `PLAY_PAUSE` - Toggle play/pause
- `PREV_TRACK` - Previous track
- `NEXT_TRACK` - Next track

**Volume Control:**
- `VOLUME_UP` - Increase volume
- `VOLUME_DOWN` - Decrease volume
- `MUTE` - Toggle mute

**Preset Selection:**
- `PRESET_1` - Select preset 1
- `PRESET_2` - Select preset 2
- `PRESET_3` - Select preset 3
- `PRESET_4` - Select preset 4
- `PRESET_5` - Select preset 5
- `PRESET_6` - Select preset 6

**Source Selection:**
- `AUX_INPUT` - Select AUX input

**Playback Modes:**
- `SHUFFLE_OFF` - Disable shuffle
- `SHUFFLE_ON` - Enable shuffle
- `REPEAT_OFF` - Disable repeat
- `REPEAT_ONE` - Repeat current track
- `REPEAT_ALL` - Repeat all tracks

**Content Actions:**
- `THUMBS_UP` - Like/thumbs up
- `THUMBS_DOWN` - Dislike/thumbs down
- `BOOKMARK` - Bookmark current content
- `ADD_FAVORITE` - Add to favorites
- `REMOVE_FAVORITE` - Remove from favorites

**Power:**
- `POWER` - Toggle power

**Other:**
- `INVALID_KEY` - Invalid key value

**Example:**
```xml
<key state="press" sender="MyApp">PLAY_PAUSE</key>
<key state="release" sender="MyApp">PLAY_PAUSE</key>
```

### KEY_STATE

State of a key press event.

**Values:**
- `press` - Key is pressed down
- `release` - Key is released

**Example:**
```xml
<key state="press" sender="MyApp">VOLUME_UP</key>
```

### PLAY_STATUS

Current playback state.

**Values:**
- `PLAY_STATE` - Currently playing
- `PAUSE_STATE` - Paused
- `STOP_STATE` - Stopped
- `BUFFERING_STATE` - Buffering content
- `INVALID_PLAY_STATUS` - Invalid or unknown state

**Example:**
```xml
<playStatus>PLAY_STATE</playStatus>
```

### PRESET_ID

Preset identifier.

**Type:** Integer from 1 to 6 inclusive

**Example:**
```xml
<preset id="1">
  <ContentItem source="PANDORA" location="123456">
    <itemName>My Favorite Station</itemName>
  </ContentItem>
</preset>
```

### SOURCE_STATUS

Availability status of a content source.

**Values:**
- `UNAVAILABLE` - Source is not available
- `READY` - Source is ready to use

**Example:**
```xml
<sourceItem source="SPOTIFY" status="READY">Spotify</sourceItem>
<sourceItem source="PANDORA" status="UNAVAILABLE">Pandora</sourceItem>
```

## Common Data Structures

### ContentItem

Represents a playable content item (source, station, playlist, etc.).

**Attributes:**
- `source` (STRING) - Source identifier (e.g., "SPOTIFY", "BLUETOOTH", "AUX")
- `location` (STRING) - Source-specific location/ID (optional)
- `sourceAccount` (STRING) - Account identifier for the source (optional)
- `isPresetable` (BOOL) - Whether this item can be saved as a preset

**Child Elements:**
- `<itemName>` (STRING) - Display name of the content

**Examples:**
```xml
<!-- Bluetooth source -->
<ContentItem source="BLUETOOTH"></ContentItem>

<!-- AUX input -->
<ContentItem source="AUX" sourceAccount="AUX"></ContentItem>

<!-- Spotify track -->
<ContentItem source="SPOTIFY" location="spotify:track:abc123"
             sourceAccount="user@example.com" isPresetable="true">
  <itemName>My Favorite Song</itemName>
</ContentItem>

<!-- Pandora station -->
<ContentItem source="PANDORA" location="R123456"
             sourceAccount="user@example.com" isPresetable="true">
  <itemName>Today's Hits Radio</itemName>
</ContentItem>
```

### Common Sources

**Built-in Sources:**
- `BLUETOOTH` - Bluetooth audio input
- `AUX` - Auxiliary audio input (may have account like "AUX3" for multiple inputs)
- `PRODUCT` - Product-specific source (e.g., sourceAccount="TV" for soundbars)

**Streaming Services:**
- `SPOTIFY` - Spotify Connect
- `PANDORA` - Pandora Radio
- `AMAZON` - Amazon Music
- `DEEZER` - Deezer
- `IHEART` - iHeartRadio
- `SIRIUSXM` - SiriusXM
- `LOCAL_MUSIC` - Local music library
- `STORED_MUSIC` - Stored music on device
- `INTERNET_RADIO` - Internet radio stations

## Data Type Summary Table

| Type | Description | Example Value |
|------|-------------|---------------|
| BOOL | Boolean string | `"true"`, `"false"` |
| INT | 32-bit signed integer | `-100`, `0`, `50` |
| UINT | 32-bit unsigned integer | `0`, `100`, `255` |
| UINT64 | 64-bit unsigned integer | `1704672000000` |
| STRING | XML-escaped string | `"Living Room"` |
| IPADDR | IP address string | `"192.168.1.100"` |
| MACADDR | Uppercase MAC address | `"AABBCCDDEEFF"` |
| URL | URL string | `"http://example.com"` |
| ART_STATUS | Album art status | `IMAGE_PRESENT` |
| AUDIO_MODE | Audio processing mode | `AUDIO_MODE_DIALOG` |
| KEY_VALUE | Remote control key | `PLAY_PAUSE` |
| KEY_STATE | Key press state | `press`, `release` |
| PLAY_STATUS | Playback state | `PLAY_STATE` |
| PRESET_ID | Preset number | `1` to `6` |
| SOURCE_STATUS | Source availability | `READY` |

## Notes

- All XML responses use these data types
- Always validate data before sending to the API
- The API is case-sensitive for enumeration values
- MAC addresses must be uppercase without separators
- Timestamps (UINT64) are typically Unix epoch time in milliseconds
