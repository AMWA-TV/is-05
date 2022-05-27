# Interoperability: Non-NMOS Devices

_(c) AMWA 2017, CC Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)_

## Interacting with Non-NMOS Devices

In practical deployments it is expected that some Devices will exist which do not support the NMOS specifications, but which do support matching transport protocols. When connecting to one of these Devices via the Connection API, it is the client's responsibility to set the `sender_id` parameter or `receiver_id` parameter to `null`.

In cases where another connection management protocol is used to achieve this (for example RTSP in the case of the RTP transport), the Connection API MUST still be updated to reflect the running parameters which have been set via this alternative protocol.
