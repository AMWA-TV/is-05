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

Controllers appending paths to `href` type attributes MUST support URLs both with and without a trailing slash, to avoid doubled or missing slashes.

Controllers performing requests other than `GET` or `HEAD` (i.e `PUT`, `POST`, `DELETE`, `OPTIONS` etc.) MUST use URLs with no trailing slash present.

#### API Versions

The versioning format is `v<MAJOR>.<MINOR>`
* `MINOR` increments will be performed for non-breaking changes (such as the addition of attributes in a response)
* `MAJOR` increments will be performed for breaking changes (such as the renaming of a resource or attribute)

Versions MUST be represented as complete strings. Parsing MUST proceed as follows: separate into two strings, using the point (.) as a delimiter. Compare integer representations of `MAJOR`, `MINOR` version (such that v1.12 is greater than v1.5).

Implementers of Controllers are RECOMMENDED to support multiple versions of the NMOS APIs simultaneously in order to ease the upgrade process in live facilities.

#### API Common Keys

Controllers SHOULD follow the requirements for common APi keys specified in the [IS-04 APIs: Common Keys](APIs%20-%20Common%20Keys.md) document including the requirements regarding [use of URNs](APIs%20-%20Common%20Keys.md#use-of-urns).

#### Error Codes & Responses

The NMOS APIs use HTTP status codes to indicate success, failure and other cases to Controllers as per [RFC 7231](https://tools.ietf.org/html/rfc7231) and related standards.

As explicit handling of every possible HTTP response code is not expected, Controllers MUST implement generic handling for ranges of response codes (1xx, 2xx, 3xx, 4xx and 5xx).
However, where the RAML specification of an API specifies explicit response codes the Controller SHOULD handle these cases explicitly.

For Controllers performing `GET` and `HEAD` requests, using these methods SHOULD correctly handle a `301` (Moved Permanently) response.

When a 301 is supported, the Controller MUST follow the redirect in order to retrieve the required response payload.

If a Controller receives a HTTP 5xx or 4xx response code from the API, a failure has occurred.
The Controller SHOULD display the content of the response's error field to the user if possible, and indicate that the resource is likely to be in an unknown state.
The Controller SHOULD also refresh the endpoints of the relevant resources to ensure the Controller is accurately reflecting the current state of the API.

## Connection Management

The Controller SHALL implement connection management according to the [APIs section](APIs.md) of this specification.

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

## Client Side Implementation Notes

Controllers SHALL adhere the Client Side Implementation Notes described in this specification, namely the sections on [Conformance to Schemas](APIs%20-%20Client%20Side%20Implementation.md#conforming-to-schemas), [RTP Operating Point](APIs%20-%20Client%20Side%20Implementation.md#rtp-operating-point), and [Failure Modes](APIs%20-%20Client%20Side%20Implementation.md#failure-modes).

## Interoperability

### Identifying Active Connections

As is described in the [Identifying Active Connections section of the Interoperability: IS-04 document](Interoperability%20-%20IS-04.md#identifying-active-connections) in this specification,
in order to populate the subscription attribute of IS-04 Senders and Receivers, the Connection API includes keys for sender_id and receiver_id in its staged parameters.
These SHOULD be used to signal that a Sender or Receiver is being connected to another NMOS compatible Sender or Receiver. 
The NMOS Controller SHALL set and unset (using `null`) the `sender_id` or `receiver_id` parameters when modifying the transport_params or transport_file.

### Interacting with Non-NMOS Devices

Controllers MUST follow the requirements for a Client interacting with non-NMOS Devices, as described in the [Interoperability: Non-NMOS Devices document](Interoperability%20-%20Non-NMOS%20Devices.md) in this sepcficiation.

## Behaviour

### Operation with SMPTE 2022-7

When the Controller is interacting with Receivers that support SMPTE 2022-7 is MUST follow the requirements for Clients described in the [Operation with SMPTE 2022-7 section of the Behaviour - RTP Transport Type document](Behaviour%20-%20RTP%20Transport%20Type.md#operation-with-smpte-2022-7) in this specification.

### Version Timestamp

The Controller SHOULD use the IS-04 Query API websocket to monitor version timestamp increments on Devices being controlled.
A version timestamp increment indicates that another controller has possibly changed the transport parameters, and as such any information cached by the Controller may be stale.

### Sender Multicast Address

The NMOS Controller SHOULD allow allocation of multicast addresses which will allow avoidance of conflicts.
In that case, when a Sender is added to a new system, the NMOS Controller SHALL allow the use AMWA IS-05 to configure the multicast transmit information (`transport_params`) before or in the same transaction as enabling the transmitter (`master_enable` = `true`).

### TCP sessions

The NMOS Controller SHOULD use persistent TCP connections wherever possible,
to allow multiple operations to be performed without repeatedly closing and reopening connections for each operation.

The use of HTTP pipelining has been known to cause interoperability issues in some cases.
If the NMOS Controller uses HTTP pipelining, this should be done with great care, particularly when making API calls that can change the state of a resource.
