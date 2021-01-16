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
