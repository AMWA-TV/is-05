# AMWA IS-05 NMOS Device Connection Management Specification

[![Lint Status](https://github.com/AMWA-TV/nmos-device-connection-management/workflows/Lint/badge.svg)](https://github.com/AMWA-TV/nmos-device-connection-management/actions?query=workflow%3ALint)
[![Render Status](https://github.com/AMWA-TV/nmos-device-connection-management/workflows/Render/badge.svg)](https://github.com/AMWA-TV/nmos-device-connection-management/actions?query=workflow%3ARender)

[//]: # "INTRO-START"

### What does it do?

- Provides a transport-independent way of connecting Media Nodes
  - Supports RTP, WebSocket and MQTT connections
- Supports single + bulk connections, immediate + delayed connections

### Why does it matter?

- ST 2110 does not specify how to do this
  - So without IS-05 there is a danger of multiple proprietary approaches
  - ...and difficulty in adopting new stream formats.
- Provides support for new specifications
  - such as IS-07 event transport

### How does it work?

- Control application sends instructions to Media Nodes
- ``transport_params`` conveys the connection information

[//]: # "INTRO-END"

## Getting started

There is more information about the NMOS Specifications and their GitHub repos at <https://specs.amwa.tv/nmos>.
