# Behaviour: RTP Transport Type

_(c) AMWA 2017, CC Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)_

## Transport File Resource

The Sender `/transportfile` resource SHOULD use the following HTTP header when returning the transport file:

`Content-Type: application/sdp`

## Parameter Sets

Sender and Receiver Connection Management endpoints MUST support a core parameter set. In addition they MAY support multicast, FEC and/or RTCP parameter sets. Endpoints MUST support all parameters in a parameter set, or none at all.

### Receiver Parameter Sets

#### Core Parameters

- `source_ip`
- `interface_ip`
- `destination_port`
- `rtp_enabled`

#### Multicast Parameters

- `multicast_ip`

#### FEC Parameters

- `fec_enabled`
- `fec_destination_ip`
- `fec_mode`
- `fec1D_destination_port`
- `fec2D_destination_port`

#### RTCP Parameters

- `rtcp_enabled`
- `rtcp_destination_ip`
- `rtcp_destination_port`

### Sender Parameter Sets

#### Core Parameters

- `source_ip`
- `destination_ip`
- `source_port`
- `destination_port`
- `rtp_enabled`

#### FEC Parameters

- `fec_enabled`
- `fec_destination_ip`
- `fec_type`
- `fec_mode`
- `fec_block_width`
- `fec_block_height`
- `fec1D_destination_port`
- `fec2D_destination_port`
- `fec1D_source_port`
- `fec2D_source_port`

#### RTCP Parameters

- `rtcp_enabled`
- `rtcp_destination_ip`
- `rtcp_destination_port`
- `rtcp_source_port`

## Use of auto

Parameters which support use of `auto` are identified in the schemas. This section clarifies the use of `auto` in some cases that might be unclear.

### Sender `source_ip` and Receiver `interface_ip`

These parameters specify the interface binding to use for sending or receiving traffic. Use of `auto` here means the Device SHOULD determine for itself which of its interfaces is the most appropriate to use. In Devices where only one interface is available for media traffic this is trivial. In Devices with multiple media network interfaces Devices could use mechanisms such as routing tables, out-of-band controls or evaluation of loading on the interfaces.

### Sender `destination_ip`

If this parameter is set to `auto` the Sender is expected to automatically select an address to send on. This could be determined by an external network control system, or through technologies such as MADCAP (RFC 2730) or ZMAAP.

## Behaviour of SDP Media Information

SDP files contain both connection information and media information. When a parameter set is activated with an SDP file present in `data` the Receiver SHOULD use the media information in the SDP file.

## Interpretation of SDP Files

All Senders and Receivers SHOULD comply with RFC 4566 (Session Description Protocol) when creating and parsing SDP files. Multicast Senders and Receivers SHOULD additionally comply with RFC 4570 (SDP Source Filters). Three examples are given below, showing an SDP file and the transport parameters that would be presented at the `/staged` endpoint by a single-legged Receiver that has parsed the file.

A Receiver sets the `rtp_enabled` parameter to `true` for each leg it has configured from the SDP file, unless overridden by the requested `transport_params` as noted below.

In the event that a Receiver is presented with an SDP file and a set of transport parameters that
contradict each other in the same `PATCH` request, the transport parameters take priority
over the SDP file and MUST be the parameters used for activation. This only applies
in the case where there is contradiction between the SDP file and transport parameters within
a single `PATCH` request, in all other cases the most recently received `PATCH` request takes priority.

### Unicast

```
v=0
o=- 2890844526 2890842807 IN IP4 10.47.16.5
s=SDP Example
c=IN IP4 10.46.16.34/127
t=2873397496 2873404696
a=recvonly
m=video 51372 RTP/AVP 99
a=rtpmap:99 h263-1998/90000
```

```json
"transport_params": [
    {
        "source_ip": null,
        "multicast_ip": null,
        "interface_ip": "10.46.16.34",
        "destination_port": 51372,
        "rtp_enabled": true
    }
]
```

### Source Specific Multicast

```
v=0
o=- 1497010742 1497010742 IN IP4 172.29.26.24
s=SDP Example
t=2873397496 2873404696
m=video 5000 RTP/AVP 103
c=IN IP4 232.21.21.133/32
a=source-filter: incl IN IP4 232.21.21.133 172.29.226.24
a=rtpmap:103 raw/90000
```

```json
"transport_params": [
    {
        "source_ip": "172.29.226.24",
        "multicast_ip": "232.21.21.133",
        "interface_ip": "auto",
        "destination_port": 5000,
        "rtp_enabled": true
    }
]
```

### Any Source Multicast

```
v=0
o=- 1497010742 1497010742 IN IP4 172.29.26.24
s=SDP Example
t=2873397496 2873404696
m=video 5000 RTP/AVP 103
c=IN IP4 239.21.21.133/32
a=rtpmap:103 raw/90000
```

```json
"transport_params": [
    {
        "source_ip": null,
        "multicast_ip": "239.21.21.133",
        "interface_ip": "auto",
        "destination_port": 5000,
        "rtp_enabled": true
    }
]
```

## Operation with SMPTE 2022-5

SMPTE 2022-5 describes RTP streams with forward error correction (FEC), and is supported by the Connection Management Specification. This support takes the form of the FEC transport parameter set described in [Parameter Sets](#parameter-sets). Note that Senders have additional parameters used to specify the type of FEC to be used and matrix rows and columns, which are not present on the Receiver side. In SMPTE 2022-5 this information is conveyed in the FEC stream headers, and as such does not need to be conveyed separately in Connection Management.

Connection APIs supporting SMPTE 2022-5 MUST comply with RFC 6364 when creating and interpreting SDP files. Implementers are advised to consider the guidance given in VSF TR-04. An example SDP file from RFC 6364 is shown below, followed by the transport parameters that would be presented on the `/staged` endpoint by a Receiver that has parsed the file.

```
v=0
o=ali 1122334455 1122334466 IN IP4 172.29.26.24
s=FEC Framework Examples
t=0 0
a=group:FEC-FR S1 R1
m=video 30000 RTP/AVP 100
c=IN IP4 233.252.0.1/127
a=rtpmap:100 MP2T/90000
a=fec-source-flow: id=0
a=mid:S1
m=application 30000 UDP/FEC
c=IN IP4 233.252.0.2/127
a=fec-repair-flow: encoding-id=10; ss-fssi=n:7,k:5
a=mid:R1
```

```json
"transport_params": [
    {
        "source_ip": null,
        "multicast_ip": "233.252.0.1",
        "interface_ip": "auto",
        "destination_port": 30000,
        "rtp_enabled": true,
        "fec_enable": true,
        "fec_mode": "auto",
        "fec1D_destination_port": 30000,
        "fec2D_destination_port": "auto",
        "fec_destination_ip": "233.252.0.2"
    }
]
```

## Operation with SMPTE 2022-7

SMPTE 2022-7 describes redundant streams for RTP connections, and is supported by the Connection Management Specification. This manifests itself in the fact that the JSON which describes constraints and transport parameters resides within an array. Where SMPTE-2022-7 is not supported this array contains only one object. Where SMPTE-2022-7 is supported the array contains two entries. The first entry contains information pertaining to Path 1, the second information pertaining to Path 2.

Where a Receiver supports SMPTE 2022-7 but receives a request with a non-SMPTE 2022-7 transport file, the Receiver SHOULD set `rtp_enabled` in the second set of parameters to `false` and transport parameters in the SDP file SHOULD be mapped onto that first set of parameters in the array with `rtp_enabled` set to `true` (bearing in mind that the `transport_params` values in the same request take priority).

Where a client request does not include a transport file and uses only `transport_params` to configure such a Receiver for a non-SMPTE 2022-7 stream, the request SHOULD explicitly set `rtp_enabled` in the second set of parameters to `false`.

Where a Receiver does not support SMPTE 2022-7 but receives a SMPTE 2022-7 transport file containing two sets of transport parameters it is RECOMMENDED that it parses the first set of transport parameters found in the file and joins the stream as if it were a non-SMPTE 2022-7 stream. This ensures compatibility with Senders which do not support operation in a non-SMPTE 2022-7 mode.

In all cases, if a client request includes `transport_params`, it MUST have the same number of array elements (or 'legs') as specified in the constraints. If no changes are needed to a specific leg it MUST be included as an empty object (`{}`).

Connection APIs supporting SMPTE 2022-7 MUST comply with RFC 7104 when creating and interpreting SDP files. Implementers are advised to consider the guidance given in VSF TR-04. The stream listed first in the SDP file SHOULD be interpreted as being Path 1, and be populated to the first transport parameter object in `/staged`, with the inverse being true for Path 2.

The three examples given in RFC 7104 are shown below, followed by the transport parameters that would be presented on the `/staged` endpoint by a Receiver that has parsed the file.

### Separate Source Addresses

```
v=0
o=ali 1122334455 1122334466 IN IP4 dup.example.com
s=DUP Grouping Semantics
t=0 0
m=video 30000 RTP/AVP 100
c=IN IP4 233.252.0.1/127
a=source-filter: incl IN IP4 233.252.0.1 198.51.100.1 198.51.100.2
a=rtpmap:100 MP2T/90000
a=ssrc:1000 cname:ch1@example.com
a=ssrc:1010 cname:ch1@example.com
a=ssrc-group:DUP 1000 1010
a=mid:Ch1
```

```json
"transport_params": [
    {
        "source_ip": "198.51.100.1",
        "multicast_ip": "233.252.0.1",
        "interface_ip": "auto",
        "destination_port": 30000,
        "rtp_enabled": true
    }, {
        "source_ip": "198.51.100.2",
        "multicast_ip": "233.252.0.1",
        "interface_ip": "auto",
        "destination_port": 30000,
        "rtp_enabled": true
    }
]
```

### Separate Destination Addresses

```
v=0
o=ali 1122334455 1122334466 IN IP4 dup.example.com
s=DUP Grouping Semantics
t=0 0
a=group:DUP S1a S1b
m=video 30000 RTP/AVP 100
c=IN IP4 233.252.0.1/127
a=source-filter: incl IN IP4 233.252.0.1 198.51.100.1
a=rtpmap:100 MP2T/90000
a=mid:S1a
m=video 30000 RTP/AVP 101
c=IN IP4 233.252.0.2/127
a=source-filter: incl IN IP4 233.252.0.2 198.51.100.1
a=rtpmap:101 MP2T/90000
a=mid:S1b
```

```json
"transport_params": [
    {
        "source_ip": "198.51.100.1",
        "multicast_ip": "233.252.0.1",
        "interface_ip": "auto",
        "destination_port": 30000,
        "rtp_enabled": true
    }, {
        "source_ip": "198.51.100.1",
        "multicast_ip": "233.252.0.2",
        "interface_ip": "auto",
        "destination_port": 30000,
        "rtp_enabled": true
    }
]
```

### Temporal Redundancy

```
v=0
o=ali 1122334455 1122334466 IN IP4 dup.example.com
s=Delayed Duplication
t=0 0
m=video 30000 RTP/AVP 100
c=IN IP4 233.252.0.1/127
a=source-filter: incl IN IP4 233.252.0.1 198.51.100.1
a=rtpmap:100 MP2T/90000
a=ssrc:1000 cname:ch1a@example.com
a=ssrc:1010 cname:ch1a@example.com
a=ssrc-group:DUP 1000 1010
a=duplication-delay:50
a=mid:Ch1
```

```json
"transport_params": [
    {
        "source_ip": "198.51.100.1",
        "multicast_ip": "233.252.0.1",
        "interface_ip": "auto",
        "destination_port": 30000,
        "rtp_enabled": true
    }, {
        "source_ip": "198.51.100.1",
        "multicast_ip": "233.252.0.1",
        "interface_ip": "auto",
        "destination_port": 30000,
        "rtp_enabled": true
    }
]
```

## Operation with RTCP

RTCP provides various functions to support the operation of RTP, principally QoS reporting. RTCP is defined in Section 6 of RFC 3550, which suggests that the next highest odd port after the RTP port is used for its transmission. Where RTCP and forward error correction are both in use the RTP port SHOULD be chosen to be even, to satisfy the recommendations of both RFC 3550 and SMPTE 2022-5 without resulting in port collisions.

Senders and Receivers supporting RTCP SHOULD comply with RFC 3605 when creating and receiving SDP files. An RFC 3605 compliant SDP file is shown below, along with the transport parameters that would be presented on the `/staged` endpoint by a Receiver that has parsed the file.

```
v=0
o=- 1497010742 1497010742 IN IP4 172.29.26.24
s=SDP Example
t=2873397496 2873404696
m=video 5000 RTP/AVP 103
c=IN IP4 232.21.21.133/32
a=source-filter: incl IN IP4 232.21.21.133 172.29.226.24
a=rtpmap:103 raw/90000
a=rtcp:5001 IN IP4 232.21.21.133
```

```json
"transport_params": [
    {
        "source_ip": "172.29.226.24",
        "multicast_ip": "232.21.21.133",
        "interface_ip": "auto",
        "destination_port": 5000,
        "rtcp_enabled": true,
        "rtcp_destination_ip": "232.21.21.133",
        "rtcp_destination_port": 5001,
        "rtp_enabled": true
    }
]
```
