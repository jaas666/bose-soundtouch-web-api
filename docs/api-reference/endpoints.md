# API Endpoints Reference

Complete reference for all SoundTouch Web API endpoints.

**Base URL:** `http://{device-ip}:8090`

## Table of Contents

- [Playback Control](#playback-control)
  - [/key](#key)
  - [/select](#select)
- [Sources](#sources)
  - [/sources](#sources-1)
- [Audio Settings](#audio-settings)
  - [/volume](#volume)
  - [/bass](#bass)
  - [/bassCapabilities](#basscapabilities)
  - [/audiodspcontrols](#audiodspcontrols)
  - [/audioproducttonecontrols](#audioproducttonecontrols)
  - [/audioproductlevelcontrols](#audioproductlevelcontrols)
- [Now Playing](#now-playing)
  - [/now_playing](#now_playing)
  - [/trackInfo](#trackinfo)
- [Presets](#presets)
  - [/presets](#presets-1)
- [Multi-Room Zones](#multi-room-zones)
  - [/getZone](#getzone)
  - [/setZone](#setzone)
  - [/addZoneSlave](#addzoneslave)
  - [/removeZoneSlave](#removezoneslave)
- [Device Information](#device-information)
  - [/info](#info)
  - [/name](#name)
  - [/capabilities](#capabilities)

---

## Playback Control

### /key

Send remote button presses to the device.

**Method:** `POST`

**Description:** Simulates pressing a button on the remote control. Send two separate POST requests (press and release) to fully simulate a button click.

**Request Body:**
```xml
<key state="{KEY_STATE}" sender="{sender-name}">{KEY_VALUE}</key>
```

**Parameters:**
- `state` (KEY_STATE): `"press"` or `"release"`
- `sender` (STRING): Identifier for your application (e.g., "MyApp")
- Content (KEY_VALUE): The key to press (see [Data Types](data-types.md#key_value))

**Example:**
```bash
# Press PLAY_PAUSE
curl -X POST http://192.168.1.100:8090/key \
  -d '<key state="press" sender="MyApp">PLAY_PAUSE</key>'

# Release PLAY_PAUSE
curl -X POST http://192.168.1.100:8090/key \
  -d '<key state="release" sender="MyApp">PLAY_PAUSE</key>'
```

**Available Keys:**
- Playback: `PLAY`, `PAUSE`, `STOP`, `PLAY_PAUSE`, `PREV_TRACK`, `NEXT_TRACK`
- Volume: `VOLUME_UP`, `VOLUME_DOWN`, `MUTE`
- Presets: `PRESET_1` through `PRESET_6`
- Others: `THUMBS_UP`, `THUMBS_DOWN`, `BOOKMARK`, `POWER`, etc.

**Response:**
```xml
<status>OK</status>
```

---

### /select

Select an audio source.

**Method:** `POST`

**Description:** Switch to a specific audio source (Bluetooth, AUX, streaming service, etc.).

**Request Body:**
```xml
<ContentItem source="{SOURCE}" sourceAccount="{ACCOUNT}"></ContentItem>
```

**Parameters:**
- `source` (STRING): Source identifier
- `sourceAccount` (STRING, optional): Account identifier for the source

**Examples:**

```bash
# Select Bluetooth
curl -X POST http://192.168.1.100:8090/select \
  -d '<ContentItem source="BLUETOOTH"></ContentItem>'

# Select AUX input
curl -X POST http://192.168.1.100:8090/select \
  -d '<ContentItem source="AUX" sourceAccount="AUX"></ContentItem>'

# Select AUX input 3
curl -X POST http://192.168.1.100:8090/select \
  -d '<ContentItem source="AUX" sourceAccount="AUX3"></ContentItem>'

# Select TV (for soundbars)
curl -X POST http://192.168.1.100:8090/select \
  -d '<ContentItem source="PRODUCT" sourceAccount="TV"></ContentItem>'
```

**Response:**
```xml
<status>OK</status>
```

**Note:** Available sources vary by product and account. Use `/sources` to query available sources for a device.

---

## Sources

### /sources

List all available content sources.

**Method:** `GET`

**Description:** Retrieves a list of all available audio sources for the device.

**Request:**
```bash
curl http://192.168.1.100:8090/sources
```

**Response:**
```xml
<sources deviceID="{MACADDR}">
  <sourceItem source="{SOURCE}" sourceAccount="{STRING}" status="{SOURCE_STATUS}">
    {Display Name}
  </sourceItem>
  ...
</sources>
```

**Response Fields:**
- `deviceID` (MACADDR): Device MAC address
- `sourceItem`: Individual source entry
  - `source` (STRING): Source identifier
  - `sourceAccount` (STRING, optional): Account identifier
  - `status` (SOURCE_STATUS): `READY` or `UNAVAILABLE`
  - Content (STRING): Display name

**Example Response:**
```xml
<sources deviceID="AABBCCDDEEFF">
  <sourceItem source="BLUETOOTH" status="READY">Bluetooth</sourceItem>
  <sourceItem source="AUX" sourceAccount="AUX" status="READY">AUX</sourceItem>
  <sourceItem source="SPOTIFY" status="READY">Spotify</sourceItem>
  <sourceItem source="PANDORA" status="UNAVAILABLE">Pandora</sourceItem>
  <sourceItem source="PRODUCT" sourceAccount="TV" status="READY">TV</sourceItem>
</sources>
```

---

## Audio Settings

### /volume

Get or set the volume level.

**Method:** `GET`, `POST`

**Description:** Control volume (0-100) and mute state.

#### GET Volume

**Request:**
```bash
curl http://192.168.1.100:8090/volume
```

**Response:**
```xml
<volume deviceID="{MACADDR}">
  <targetvolume>{INT}</targetvolume>
  <actualvolume>{INT}</actualvolume>
  <muteenabled>{BOOL}</muteenabled>
</volume>
```

**Response Fields:**
- `targetvolume` (INT): Desired volume level (0-100)
- `actualvolume` (INT): Current volume level (0-100)
- `muteenabled` (BOOL): Mute state

#### POST Volume

**Request Body:**
```xml
<volume>{INT}<muteenabled>{BOOL}</muteenabled></volume>
```

**Parameters:**
- Volume value (INT, 0-100): Volume level
- `muteenabled` (BOOL, optional): Mute state

**Examples:**
```bash
# Set volume to 30
curl -X POST http://192.168.1.100:8090/volume \
  -d '<volume>30</volume>'

# Set volume to 50 and unmute
curl -X POST http://192.168.1.100:8090/volume \
  -d '<volume>50<muteenabled>false</muteenabled></volume>'

# Mute (keep current volume)
curl -X POST http://192.168.1.100:8090/volume \
  -d '<volume><muteenabled>true</muteenabled></volume>'
```

**Note:** Mute is applied first. Setting volume higher than current will automatically unmute.

---

### /bass

Get or set bass level.

**Method:** `GET`, `POST`

**Description:** Adjust bass level. Check `/bassCapabilities` first to see if supported.

#### GET Bass

**Request:**
```bash
curl http://192.168.1.100:8090/bass
```

**Response:**
```xml
<bass deviceID="{MACADDR}">
  <targetbass>{INT}</targetbass>
  <actualbass>{INT}</actualbass>
</bass>
```

#### POST Bass

**Request Body:**
```xml
<bass>{INT}</bass>
```

**Example:**
```bash
# Set bass to +3
curl -X POST http://192.168.1.100:8090/bass \
  -d '<bass>3</bass>'
```

---

### /bassCapabilities

Get bass adjustment capabilities.

**Method:** `GET`

**Description:** Check if the device supports bass adjustment and get valid range.

**Request:**
```bash
curl http://192.168.1.100:8090/bassCapabilities
```

**Response:**
```xml
<bassCapabilities deviceID="{MACADDR}">
  <bassAvailable>{BOOL}</bassAvailable>
  <bassMin>{INT}</bassMin>
  <bassMax>{INT}</bassMax>
  <bassDefault>{INT}</bassDefault>
</bassCapabilities>
```

**Response Fields:**
- `bassAvailable` (BOOL): Whether bass adjustment is supported
- `bassMin` (INT): Minimum bass value
- `bassMax` (INT): Maximum bass value
- `bassDefault` (INT): Default bass value

**Example Response:**
```xml
<bassCapabilities deviceID="AABBCCDDEEFF">
  <bassAvailable>true</bassAvailable>
  <bassMin>-9</bassMin>
  <bassMax>0</bassMax>
  <bassDefault>0</bassDefault>
</bassCapabilities>
```

---

### /audiodspcontrols

Get or set DSP audio mode settings (soundbars/home theater).

**Method:** `GET`, `POST`

**Description:** Access system DSP settings. Only available if listed in `/capabilities`.

#### GET DSP Controls

**Request:**
```bash
curl http://192.168.1.100:8090/audiodspcontrols
```

**Response:**
```xml
<audiodspcontrols audiomode="{AUDIO_MODE}" videosyncaudiodelay="{UINT}"
                   supportedaudiomodes="{AUDIO_MODE}|{AUDIO_MODE}|..."/>
```

**Response Fields:**
- `audiomode` (AUDIO_MODE): Current audio mode
- `videosyncaudiodelay` (UINT): Audio delay in milliseconds
- `supportedaudiomodes` (STRING): Pipe-separated list of supported modes

#### POST DSP Controls

**Request Body:**
```xml
<audiodspcontrols audiomode="{AUDIO_MODE}" videosyncaudiodelay="{UINT}"/>
```

**Note:** Omitted fields will not be changed.

**Example:**
```bash
# Set to dialog mode
curl -X POST http://192.168.1.100:8090/audiodspcontrols \
  -d '<audiodspcontrols audiomode="AUDIO_MODE_DIALOG"/>'
```

---

### /audioproducttonecontrols

Get or set bass and treble controls.

**Method:** `GET`, `POST`

**Description:** Adjust bass and treble. Only available if listed in `/capabilities`.

#### GET Tone Controls

**Request:**
```bash
curl http://192.168.1.100:8090/audioproducttonecontrols
```

**Response:**
```xml
<audioproducttonecontrols>
  <bass value="{INT}" minValue="{INT}" maxValue="{INT}" step="{UINT}"/>
  <treble value="{INT}" minValue="{INT}" maxValue="{INT}" step="{UINT}"/>
</audioproducttonecontrols>
```

#### POST Tone Controls

**Request Body:**
```xml
<audioproducttonecontrols>
  <bass value="{INT}"/>
  <treble value="{INT}"/>
</audioproducttonecontrols>
```

**Note:** Omitted fields will not be changed.

---

### /audioproductlevelcontrols

Get or set speaker level controls (home theater systems).

**Method:** `GET`, `POST`

**Description:** Adjust front-center and rear-surround speaker levels. Only available if listed in `/capabilities`.

#### GET Level Controls

**Request:**
```bash
curl http://192.168.1.100:8090/audioproductlevelcontrols
```

**Response:**
```xml
<audioproductlevelcontrols>
  <frontCenterSpeakerLevel value="{INT}" minValue="{INT}"
                            maxValue="{INT}" step="{UINT}"/>
  <rearSurroundSpeakersLevel value="{INT}" minValue="{INT}"
                              maxValue="{INT}" step="{UINT}"/>
</audioproductlevelcontrols>
```

#### POST Level Controls

**Request Body:**
```xml
<audioproductlevelcontrols>
  <frontCenterSpeakerLevel value="{INT}"/>
  <rearSurroundSpeakersLevel value="{INT}"/>
</audioproductlevelcontrols>
```

---

## Now Playing

### /now_playing

Get currently playing media information.

**Method:** `GET`

**Description:** Retrieves complete information about the currently playing content.

**Request:**
```bash
curl http://192.168.1.100:8090/now_playing
```

**Response:**
```xml
<nowPlaying deviceID="{MACADDR}" source="{SOURCE}">
  <ContentItem source="{SOURCE}" location="{STRING}"
               sourceAccount="{STRING}" isPresetable="{BOOL}">
    <itemName>{STRING}</itemName>
  </ContentItem>
  <track>{STRING}</track>
  <artist>{STRING}</artist>
  <album>{STRING}</album>
  <stationName>{STRING}</stationName>
  <art artImageStatus="{ART_STATUS}">{URL}</art>
  <playStatus>{PLAY_STATUS}</playStatus>
  <description>{STRING}</description>
  <stationLocation>{STRING}</stationLocation>
</nowPlaying>
```

**Response Fields:**
- `deviceID` (MACADDR): Device MAC address
- `source` (STRING): Current source
- `ContentItem`: Content information
- `track` (STRING): Track name
- `artist` (STRING): Artist name
- `album` (STRING): Album name
- `stationName` (STRING): Station/playlist name
- `art` (URL): Album art URL
  - `artImageStatus` (ART_STATUS): Art availability
- `playStatus` (PLAY_STATUS): Playback state
- `description` (STRING): Content description
- `stationLocation` (STRING): Station location/genre

**Example Response:**
```xml
<nowPlaying deviceID="AABBCCDDEEFF" source="SPOTIFY">
  <ContentItem source="SPOTIFY" location="spotify:track:abc123"
               sourceAccount="user@example.com" isPresetable="true">
    <itemName>My Favorite Song</itemName>
  </ContentItem>
  <track>Song Title</track>
  <artist>Artist Name</artist>
  <album>Album Name</album>
  <art artImageStatus="IMAGE_PRESENT">http://example.com/cover.jpg</art>
  <playStatus>PLAY_STATE</playStatus>
</nowPlaying>
```

---

### /trackInfo

Get track information (similar to now_playing).

**Method:** `GET`

**Description:** Returns track information in the same format as `/now_playing`.

**Request:**
```bash
curl http://192.168.1.100:8090/trackInfo
```

**Response:** Same as `/now_playing`

---

## Presets

### /presets

Get list of configured presets.

**Method:** `GET`

**Description:** Retrieves all configured presets (1-6).

**Request:**
```bash
curl http://192.168.1.100:8090/presets
```

**Response:**
```xml
<presets>
  <preset id="{PRESET_ID}" createdOn="{UINT64}" updatedOn="{UINT64}">
    <ContentItem source="{SOURCE}" location="{STRING}"
                 sourceAccount="{STRING}" isPresetable="{BOOL}">
      <itemName>{STRING}</itemName>
    </ContentItem>
  </preset>
  ...
</presets>
```

**Response Fields:**
- `preset`: Individual preset entry
  - `id` (PRESET_ID): Preset number (1-6)
  - `createdOn` (UINT64): Creation timestamp
  - `updatedOn` (UINT64): Last update timestamp
  - `ContentItem`: The content assigned to this preset

**Example Response:**
```xml
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
</presets>
```

**Note:** To select a preset, use the `/key` endpoint with `PRESET_1` through `PRESET_6`.

---

## Multi-Room Zones

### /getZone

Get current multi-room zone configuration.

**Method:** `GET`

**Description:** Returns the current zone membership of the device.

**Request:**
```bash
curl http://192.168.1.100:8090/getZone
```

**Response:**
```xml
<zone master="{MACADDR}">
  <member ipaddress="{IPADDR}">{MACADDR}</member>
  ...
</zone>
```

**Response Fields:**
- `master` (MACADDR): Master device MAC address
- `member`: Zone member entry
  - `ipaddress` (IPADDR): Member IP address
  - Content (MACADDR): Member MAC address

**Example Response:**
```xml
<zone master="AABBCCDDEEFF">
  <member ipaddress="192.168.1.100">AABBCCDDEEFF</member>
  <member ipaddress="192.168.1.101">112233445566</member>
  <member ipaddress="192.168.1.102">FFEEDDCCBBAA</member>
</zone>
```

---

### /setZone

Create a multi-room zone.

**Method:** `POST`

**Description:** Creates a new multi-room zone with specified members.

**Request Body:**
```xml
<zone master="{MACADDR}" senderIPAddress="{IPADDR}">
  <member ipaddress="{IPADDR}">{MACADDR}</member>
  ...
</zone>
```

**Parameters:**
- `master` (MACADDR): Master device MAC address
- `senderIPAddress` (IPADDR): IP of the sender/controller
- `member`: Each zone member (including master)

**Example:**
```bash
curl -X POST http://192.168.1.100:8090/setZone \
  -d '<zone master="AABBCCDDEEFF" senderIPAddress="192.168.1.50">
        <member ipaddress="192.168.1.100">AABBCCDDEEFF</member>
        <member ipaddress="192.168.1.101">112233445566</member>
      </zone>'
```

---

### /addZoneSlave

Add a device to an existing zone.

**Method:** `POST`

**Description:** Adds one or more devices to the current zone.

**Request Body:**
```xml
<zone master="{MACADDR}">
  <member ipaddress="{IPADDR}">{MACADDR}</member>
  ...
</zone>
```

**Example:**
```bash
# Add device to zone
curl -X POST http://192.168.1.100:8090/addZoneSlave \
  -d '<zone master="AABBCCDDEEFF">
        <member ipaddress="192.168.1.102">FFEEDDCCBBAA</member>
      </zone>'
```

---

### /removeZoneSlave

Remove a device from a zone.

**Method:** `POST`

**Description:** Removes one or more devices from the current zone.

**Request Body:**
```xml
<zone master="{MACADDR}">
  <member ipaddress="{IPADDR}">{MACADDR}</member>
  ...
</zone>
```

**Example:**
```bash
# Remove device from zone
curl -X POST http://192.168.1.100:8090/removeZoneSlave \
  -d '<zone master="AABBCCDDEEFF">
        <member ipaddress="192.168.1.102">FFEEDDCCBBAA</member>
      </zone>'
```

---

## Device Information

### /info

Get device information.

**Method:** `GET`

**Description:** Retrieves static device information including type, software version, network info, etc.

**Request:**
```bash
curl http://192.168.1.100:8090/info
```

**Response:**
```xml
<info deviceID="{MACADDR}">
  <name>{STRING}</name>
  <type>{STRING}</type>
  <margeAccountUUID>{STRING}</margeAccountUUID>
  <components>
    <component>
      <componentCategory>{STRING}</componentCategory>
      <softwareVersion>{STRING}</softwareVersion>
      <serialNumber>{STRING}</serialNumber>
    </component>
    ...
  </components>
  <margeURL>{URL}</margeURL>
  <networkInfo type="{STRING}">
    <macAddress>{MACADDR}</macAddress>
    <ipAddress>{IPADDR}</ipAddress>
  </networkInfo>
  ...
</info>
```

**Response Fields:**
- `deviceID` (MACADDR): Device MAC address
- `name` (STRING): Device name
- `type` (STRING): Product type
- `margeAccountUUID` (STRING): Cloud account ID
- `components`: Hardware/software components
- `margeURL` (URL): Bose cloud service URL
- `networkInfo`: Network interface information

**Example Response:**
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
  <margeURL>https://worldwide.bose.com/</margeURL>
  <networkInfo type="SMSC">
    <macAddress>AABBCCDDEEFF</macAddress>
    <ipAddress>192.168.1.100</ipAddress>
  </networkInfo>
</info>
```

---

### /name

Set the device name.

**Method:** `POST`

**Description:** Changes the friendly name of the device.

**Request Body:**
```xml
<name>{STRING}</name>
```

**Example:**
```bash
# Set device name
curl -X POST http://192.168.1.100:8090/name \
  -d '<name>Living Room Speaker</name>'
```

**Response:**
```xml
<status>OK</status>
```

---

### /capabilities

Get device capabilities.

**Method:** `GET`

**Description:** Retrieves a list of optional capabilities/URLs supported by the device.

**Request:**
```bash
curl http://192.168.1.100:8090/capabilities
```

**Response:**
```xml
<capabilities deviceID="{MACADDR}">
  <capability name="{STRING}" url="/{STRING}" info="{STRING}"/>
  <capability name="{STRING}" url="/{STRING}" info="{STRING}"/>
  ...
</capabilities>
```

**Response Fields:**
- `capability`: Individual capability entry
  - `name` (STRING): Capability identifier
  - `url` (STRING): Endpoint path
  - `info` (STRING, optional): Additional information

**Example Response:**
```xml
<capabilities deviceID="AABBCCDDEEFF">
  <capability name="audiodspcontrols" url="/audiodspcontrols"/>
  <capability name="audioproducttonecontrols" url="/audioproducttonecontrols"/>
  <capability name="audioproductlevelcontrols" url="/audioproductlevelcontrols"/>
</capabilities>
```

**Note:** Only attempt to access URLs if they are listed in the capabilities response.

---

## Summary Table

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/key` | POST | Send remote button press |
| `/select` | POST | Select audio source |
| `/sources` | GET | List available sources |
| `/volume` | GET, POST | Get/set volume and mute |
| `/bass` | GET, POST | Get/set bass level |
| `/bassCapabilities` | GET | Get bass adjustment range |
| `/audiodspcontrols` | GET, POST | DSP audio mode settings |
| `/audioproducttonecontrols` | GET, POST | Bass and treble controls |
| `/audioproductlevelcontrols` | GET, POST | Speaker level controls |
| `/now_playing` | GET | Get currently playing info |
| `/trackInfo` | GET | Get track information |
| `/presets` | GET | List configured presets |
| `/getZone` | GET | Get zone configuration |
| `/setZone` | POST | Create multi-room zone |
| `/addZoneSlave` | POST | Add device to zone |
| `/removeZoneSlave` | POST | Remove device from zone |
| `/info` | GET | Get device information |
| `/name` | POST | Set device name |
| `/capabilities` | GET | Get device capabilities |
