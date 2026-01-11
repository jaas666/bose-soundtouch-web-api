# Error Handling

This document describes error responses and handling in the SoundTouch Web API.

## Standard Response Format

### Success Response

For calls without a specific return payload, the API returns:

```xml
<status>OK</status>
```

### Error Response

When errors occur, the API returns:

```xml
<errors deviceID="{MACADDR}">
  <error value="{INT}" name="{STRING}" severity="{STRING}">
    {ERROR_MESSAGE}
  </error>
  ...
</errors>
```

**Fields:**
- `deviceID` (MACADDR): Device MAC address
- `error`: Error entry
  - `value` (INT): Error code
  - `name` (STRING): Error name/type
  - `severity` (STRING): Error severity level
  - Content (STRING): Human-readable error message

## Common Error Codes

### 1019 - CLIENT_XML_ERROR

**Description:** XML parsing error in the request.

**Common Causes:**
- Malformed XML syntax
- Invalid XML structure
- Missing required attributes
- Incorrect attribute values
- Special characters not properly escaped

**Example Error:**
```xml
<errors deviceID="AABBCCDDEEFF">
  <error value="1019" name="CLIENT_XML_ERROR" severity="Unknown">
    1019
  </error>
</errors>
```

**Example Malformed Request:**
```xml
<error>XML parse error (1:116): Error reading Attributes.</error>
```

**How to Fix:**
- Validate XML before sending
- Ensure all tags are properly closed
- Escape special characters: `&` → `&amp;`, `<` → `&lt;`, `>` → `&gt;`
- Check attribute syntax (use quotes around values)

## HTTP Status Codes

The API uses standard HTTP status codes:

| Code | Meaning | Description |
|------|---------|-------------|
| 200 | OK | Request successful |
| 400 | Bad Request | Invalid request (usually XML parsing error) |
| 404 | Not Found | Endpoint does not exist |
| 500 | Internal Server Error | Server error processing request |

## Error Scenarios

### XML Syntax Errors

**Problem:** Invalid XML syntax

**Example:**
```xml
<!-- Missing closing tag -->
<volume>50
```

**Response:**
```xml
<error>XML parse error (1:116): Error reading Attributes.</error>
<errors deviceID="AABBCCDDEEFF">
  <error value="1019" name="CLIENT_XML_ERROR" severity="Unknown">1019</error>
</errors>
```

**Solution:**
```xml
<!-- Properly closed tag -->
<volume>50</volume>
```

---

### Invalid Attribute Values

**Problem:** Wrong type or value for attribute

**Example:**
```xml
<!-- Invalid key state -->
<key state="invalid" sender="MyApp">PLAY</key>
```

**Solution:**
```xml
<!-- Valid key state: "press" or "release" -->
<key state="press" sender="MyApp">PLAY</key>
```

---

### Missing Required Attributes

**Problem:** Required attribute not provided

**Example:**
```xml
<!-- Missing 'state' attribute -->
<key sender="MyApp">PLAY</key>
```

**Solution:**
```xml
<!-- Include required 'state' attribute -->
<key state="press" sender="MyApp">PLAY</key>
```

---

### Invalid Enumeration Values

**Problem:** Using values not in the enumeration

**Example:**
```xml
<!-- Invalid KEY_VALUE -->
<key state="press" sender="MyApp">INVALID_BUTTON</key>
```

**Solution:**
```xml
<!-- Use valid KEY_VALUE from the enumeration -->
<key state="press" sender="MyApp">PLAY_PAUSE</key>
```

See [Data Types](data-types.md) for valid enumeration values.

---

### Unsupported Capabilities

**Problem:** Trying to use an endpoint not supported by the device

**Example:**
```bash
# Device doesn't support bass adjustment
curl -X POST http://192.168.1.100:8090/bass -d '<bass>5</bass>'
```

**Solution:**
Check capabilities first:
```bash
# Check if bass is supported
curl http://192.168.1.100:8090/bassCapabilities

# Check for optional endpoints
curl http://192.168.1.100:8090/capabilities
```

---

### Out of Range Values

**Problem:** Value outside acceptable range

**Example:**
```xml
<!-- Volume out of range (valid: 0-100) -->
<volume>150</volume>
```

**Solution:**
```xml
<!-- Use value within valid range -->
<volume>100</volume>
```

---

### Connection Errors

**Problem:** Cannot connect to device

**Possible Causes:**
- Device is offline or powered off
- Wrong IP address
- Network/firewall blocking port 8090
- Device on different subnet

**Troubleshooting:**
1. Verify device is powered on and connected to network
2. Check IP address (may have changed via DHCP)
3. Ping the device: `ping 192.168.1.100`
4. Check firewall rules for port 8090
5. Ensure client and device are on same network

---

## Best Practices

### 1. Validate Before Sending

Always validate your XML before sending:

```python
import xml.etree.ElementTree as ET

def validate_xml(xml_string):
    try:
        ET.fromstring(xml_string)
        return True
    except ET.ParseError as e:
        print(f"Invalid XML: {e}")
        return False
```

### 2. Escape Special Characters

Properly escape XML special characters:

```python
import xml.sax.saxutils as saxutils

def escape_xml(text):
    return saxutils.escape(text, {
        "'": "&apos;",
        '"': "&quot;"
    })

# Example
name = escape_xml("Rock & Roll")  # → "Rock &amp; Roll"
```

### 3. Handle Errors Gracefully

Always check for error responses:

```python
import requests
import xml.etree.ElementTree as ET

response = requests.get('http://192.168.1.100:8090/volume')

if response.status_code == 200:
    root = ET.fromstring(response.text)

    # Check if it's an error response
    if root.tag == 'errors':
        for error in root.findall('error'):
            code = error.get('value')
            name = error.get('name')
            message = error.text
            print(f"Error {code} ({name}): {message}")
    else:
        # Process successful response
        volume = root.find('actualvolume').text
        print(f"Volume: {volume}")
else:
    print(f"HTTP Error: {response.status_code}")
```

### 4. Implement Retry Logic

Handle transient network errors:

```python
import time
import requests

def api_call_with_retry(url, max_retries=3):
    for attempt in range(max_retries):
        try:
            response = requests.get(url, timeout=5)
            response.raise_for_status()
            return response
        except requests.exceptions.RequestException as e:
            if attempt < max_retries - 1:
                time.sleep(2 ** attempt)  # Exponential backoff
                continue
            else:
                raise
```

### 5. Check Capabilities

Before using optional endpoints, verify support:

```python
def check_capability(device_ip, capability_name):
    url = f'http://{device_ip}:8090/capabilities'
    response = requests.get(url)

    if response.status_code == 200:
        root = ET.fromstring(response.text)
        for cap in root.findall('capability'):
            if cap.get('name') == capability_name:
                return True
    return False

# Example
if check_capability('192.168.1.100', 'audiodspcontrols'):
    # Safe to use /audiodspcontrols endpoint
    pass
```

### 6. Verify Value Ranges

Check limits before setting values:

```python
def set_volume_safe(device_ip, volume):
    # Clamp to valid range
    volume = max(0, min(100, volume))

    xml_data = f'<volume>{volume}</volume>'
    response = requests.post(
        f'http://{device_ip}:8090/volume',
        data=xml_data
    )
    return response

def set_bass_safe(device_ip, bass_level):
    # Get capabilities first
    caps_response = requests.get(f'http://{device_ip}:8090/bassCapabilities')

    if caps_response.status_code == 200:
        root = ET.fromstring(caps_response.text)

        # Check if bass is supported
        if root.find('bassAvailable').text == 'true':
            min_bass = int(root.find('bassMin').text)
            max_bass = int(root.find('bassMax').text)

            # Clamp to valid range
            bass_level = max(min_bass, min(max_bass, bass_level))

            xml_data = f'<bass>{bass_level}</bass>'
            return requests.post(f'http://{device_ip}:8090/bass', data=xml_data)
```

## Debugging Tips

### Enable Verbose Logging

```python
import logging
import http.client as http_client

http_client.HTTPConnection.debuglevel = 1
logging.basicConfig()
logging.getLogger().setLevel(logging.DEBUG)
requests_log = logging.getLogger("requests.packages.urllib3")
requests_log.setLevel(logging.DEBUG)
requests_log.propagate = True
```

### Inspect Raw Responses

```python
response = requests.get('http://192.168.1.100:8090/info')
print("Status Code:", response.status_code)
print("Headers:", response.headers)
print("Body:", response.text)
```

### Test with curl

```bash
# Verbose output
curl -v http://192.168.1.100:8090/info

# Show headers
curl -i http://192.168.1.100:8090/info

# POST with verbose output
curl -v -X POST http://192.168.1.100:8090/volume \
  -d '<volume>50</volume>'
```

## Error Recovery

### Automatic Reconnection

```python
class SoundTouchClient:
    def __init__(self, ip, max_retries=3):
        self.ip = ip
        self.base_url = f'http://{ip}:8090'
        self.max_retries = max_retries

    def _make_request(self, method, endpoint, data=None):
        url = f'{self.base_url}{endpoint}'

        for attempt in range(self.max_retries):
            try:
                if method == 'GET':
                    response = requests.get(url, timeout=5)
                else:
                    response = requests.post(url, data=data, timeout=5)

                if response.status_code == 200:
                    root = ET.fromstring(response.text)
                    if root.tag == 'errors':
                        # Handle API errors
                        raise APIError(root)
                    return root
                else:
                    raise HTTPError(response.status_code)

            except requests.exceptions.Timeout:
                if attempt < self.max_retries - 1:
                    time.sleep(1)
                    continue
                raise
            except requests.exceptions.ConnectionError:
                if attempt < self.max_retries - 1:
                    time.sleep(2)
                    continue
                raise

class APIError(Exception):
    def __init__(self, error_xml):
        self.errors = []
        for error in error_xml.findall('error'):
            self.errors.append({
                'code': error.get('value'),
                'name': error.get('name'),
                'severity': error.get('severity'),
                'message': error.text
            })
        super().__init__(str(self.errors))
```

## Summary

- Always validate XML before sending
- Check HTTP status codes and parse error responses
- Verify device capabilities before using optional features
- Implement proper error handling and retry logic
- Escape special characters in XML content
- Respect value ranges and enumeration constraints
