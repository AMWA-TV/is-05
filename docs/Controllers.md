# Controllers

_(c) AMWA 2022, CC Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)_

## Informative

A Controller is Client software that interacts with the NMOS APIs to discover, connect and manage devices within a networked media system.

* This document includes normative references to be followed when implementing a Controller.
* This document covers how the Controller interacts with the NMOS APIs only.
It does not cover other features of the Controller software, such as presentation.
* This document does not cover any requirements relating to where a Controller is additionally acting as a Node (e.g. receiving monitoring information via IS-07).

## General

### User
Where this document refers to the "user" of a Controller, this includes both human operators who drive the Controller manually and automation systems that drive the Controller programmatically.

### HTTP APIs
#### Trailing Slashes
APIs may advertise URLs with or without a trailing slash.
Controllers appending paths to `href` type attributes MUST support both cases, avoiding doubled or missing slashes.

Controllers performing requests other than GET or HEAD (i.e PUT, POST, DELETE, OPTIONS etc.) MUST use URLs with no trailing slash present.

#### API Version
Controllers are responsible for identifying the correct API version they require.

Implementers of Controllers are strongly recommended to support multiple versions of the NMOS APIs simultaneously in order to ease the upgrade process in live facilities.

Later API versions might use URNs which have not yet been defined and so Controllers MUST be tolerant to these.

#### Error Codes & Responses
The NMOS APIs use HTTP status codes to indicate success, failure and other cases to Controllers as per [RFC 7231](https://tools.ietf.org/html/rfc7231) and related standards.

As explicit handling of every possible HTTP response code is not expected, Controllers MUST implement generic handling for ranges of response codes (1xx, 2xx, 3xx, 4xx and 5xx).
However, where the RAML specification of an API specifies explicit response codes the Controller SHOULD handle these cases explicitly.

For Controllers performing GET and HEAD requests, using these methods SHOULD correctly handle a 301 (Moved Permanently) response.

When a 301 is supported, the Controller MUST follow the redirect in order to retrieve the required response payload.

If a Controller receives a HTTP 500 response code from the API, a failure has occurred.
The Controller SHOULD display the content of the response’s error field to the user if possible, and indicate that the Resource may be in an unknown state.
The Controller SHOULD also refresh the endpoints of the relevant Resources to ensure the Controller is accurately reflecting the current state of the API.

## Connection Management
The Controller SHALL implement connection management according to the [APIs section](APIs.md) of this specufucation.

The Controller SHALL be able to perform an immediate activation between a specified Sender and Receiver	via the IS-05 Connection API

The Controller SHALL allow removal of active connections via the IS-05 Connection API.	

The Controller SHALL monitor and update the connection status of all registered Devices. For instance:
* The Controller SHALL identify that a connection to a Receiver has been activated. 
* The Controller SHALL identify the Sender connected to that Receiver. 
* The Controller SHALL Identify when the Receiver connection has been deactivated. 

Where making requests to a large number or Senders/Receivers on the same Device, Controllers SHOULD make use of the /bulk endpoint to bundle them into a single request.

When altering the transport parameters in the /staged endpoint, the Controller SHOULD check the /constraints endpoint to check the available choices of parameters accepted by a particular sender and receiver.

When PATCHing to the transport parameters, parameters may have changed since the last get.
Therefore the Controller SHOULD set parameters that are important for a connection (e.g master_enable/rtp_enable) in the PATCH request, even if the Controller believes they are already set as required.

When working with an NMOS Sender the Controller SHOULD include the Sender UUID to the receiver using the sender_id parameter.
~~https://github.com/AMWA-TV/nmos/wiki/IS-05-Client~~

## Client Side Implementation Notes

Controllers SHALL adhere the Client Side Implementation Notes described in this specification, namely the sections on [Conformance to Schemas](APIs%20-%20Client%20Side%20Implementation.md#conforming-to-schemas), [RTP Operating Point](APIs%20-%20Client%20Side%20Implementation.md#rtp-operating-point), and [Failure Modes](APIs%20-%20Client%20Side%20Implementation.md#failure-modes).

~~Constraints
The Connection API schemas define sets of parameters for each supported transport type;
these are also described in pages in the Behaviour section of these documents.
These pages define which parameters are always present (core), and which are feature-dependent;
a client can determine what a Device supports by getting its /constraints resource, and SHOULD parse this resource in all cases as a Device might have a constrained range or enumeration of supported values, even for core parameters.~~ 

~~https://specs.amwa.tv/is-05/releases/v1.1.1/docs/2.1._APIs_-_Client_Side_Implementation.html#conforming-to-schemas~~

~~RTP Operating Point
"When establishing an RTP connection between two Devices that implement NMOS Connection Management, the expectation is that the primary means of connection will be to supply the SDP file from the Sender to the Receiver.
This ensures Receivers have the media information in the SDP file.
If desired the client can adjust individual transport parameters on the Receiver.
For example it could use the rtcp_enable parameter to toggle RTCP operation.~~

~~When receiving from a (non-NMOS) Device which does not provide an SDP file, a connection can be established using transport parameters alone.
In this case it might be necessary to provide media information out-of-band."~~

~~https://specs.amwa.tv/is-05/releases/v1.1.1/docs/2.1._APIs_-_Client_Side_Implementation.html#rtp-operating-point~~

~~Failure Modes - Bulk Interface
If an activation is triggered across multiple Senders and Receivers using the /bulk interface, Senders and Receivers will transition to their new active parameters, even if some Senders or Receivers in the same salvo fail to activate.
It is the responsibility of the client to recover from this situation if desired, including reverting Senders and Receivers that have successfully activated back to their original state where necessary.~~

~~https://specs.amwa.tv/is-05/releases/v1.1.1/docs/2.1._APIs_-_Client_Side_Implementation.html#failure-modes~~

## Interoperability
### Identifying Active Connections
As is described in the [Identifying Active Connections section of the Interoperability: IS-04 document](Interoperability%20-%20IS-04.md#identifying-active-connections) in this specification,
in order to populate the subscription attribute of IS-04 Senders and Receivers, the Connection API includes keys for sender_id and receiver_id in its staged parameters.
These SHOULD be used to signal that a Sender or Receiver is being connected to another NMOS compatible Sender or Receiver. 
The NMOS Controller SHALL set and unset (using `null`) the `sender_id` or `receiver_id` parameters when modifying the transport_params or transport_file.

~~https://specs.amwa.tv/is-05/releases/v1.1.1/docs/3.1._Interoperability_-_IS-04.html#identifying-active-connections~~

### Interacting with Non-NMOS Devices
Controllers MUST follow the requirements for a Client interacting with non-NMOS Devices, as described in the [Interoperability: Non-NMOS Devices document](Interoperability%20-%20Non-NMOS%20Devices.md) in this sepcficiation.

~~In practical deployments it is expected that some Devices will exist which do not support the NMOS specifications, but which do support matching transport protocols.
When connecting to one of these Devices via the Connection API, the sender_id and receiver_id parameters SHOULD be set to null by the client.~~

~~https://specs.amwa.tv/is-05/releases/v1.1.1/docs/3.2._Interoperability_-_Non-NMOS_Devices.html#interacting-with-non-nmos-devices~~
~~_change SHOULD to SHALL????_~~

## Behaviour
### Operation with SMPTE 2022-7
When the Controller is interacting with Receivers that support SMPTE 2022-7 is MUST follow the requirements for Clients described in the [Operation with SMPTE 2022-7 section of the Behaviour - RTP Transport Type document](Behaviour%20-%20RTP%20Transport%20Type.md#operation-with-smpte-2022-7) in this specification.

~~"Where a client request does not include a transport file and uses only transport_params to configure such a Receiver for a non-SMPTE 2022-7 stream, the request SHOULD explicitly set rtp_enabled in the second set of parameters to false.~~

~~In all cases, if a client request includes transport_params, it MUST have the same number of array elements (or ‘legs’) as specified in the constraints.
If no changes are needed to a specific leg it MUST be included as an empty object ({})."~~

~~https://specs.amwa.tv/is-05/releases/v1.1.1/docs/4.1._Behaviour_-_RTP_Transport_Type.html#operation-with-smpte-2022-7~~

### Version Timestamp
The Controller SHOULD use the IS-04 Query API websocket to monitor version timestamp increments on Devices being controlled.
A version timestamp increment indicates that another controller has possibly changed the transport parameters, and as such any information cached by the Controller may be stale.
~~https://github.com/AMWA-TV/nmos/wiki/IS-05-Client~~

### Sender Multicast Address
~~When a Sender Media Node is added to a new system, a management entity will use AMWA IS-05 to configure the multicast transmit information (transport_params) before or in the same transaction as enabling the transmitter (master_enable = true).
Allocation of multicast addresses and avoidance of conflicts is the responsibility of the management system.
[Matrox / Riedel]~~

The NMOS Controller SHOULD allow allocation of multicast addresses which will allow avoidance of conflicts.
In that case, when a Sender is added to a new system, the NMOS Controller SHALL allow the use AMWA IS-05 to configure the multicast transmit information (`transport_params`) before or in the same transaction as enabling the transmitter (`master_enable` = `true`).
~~https://static.jt-nm.org/documents/JT-NM_TR-1001-1_2020_v1.1.pdf~~

### TCP sessions
~~When communicating with Nodes it should be the NMOS Controller's responsibility to initiate the TCP connection and also to persist the connection so that multiple operations may be performed without the connection having to be closed and reopened for each operation.~~
~~[Sony]~~

The NMOS Controller SHOULD use persistent TCP connections wherever possible,
to allow multiple operations to be performed without repeatedly closing and reopening connections for each operation.

~~_Add words to say in the case where the Controller plans to reuse the connection soon. Not a universal reqt as Controller would then have a lot of connections remaining open.__~~

~~When communicating with Nodes, use of HTTP pipelining by the NMOS Controller has been known to cause issues and so is not recommended.~~
~~[Imagine]~~

The use of HTTP pipelining has been known to cause interoperability issues in some cases.
If the NMOS Controller uses HTTP pipelining, this should be done with great care, particularly when making API calls that can change the state of a resource.

~~_There will be situations where pipelining is good for optimisation, e.g. GETting lots of things from the Registry.
Should only recommend against it in certain cases. Use with care, not always well supported.
Ro~~
