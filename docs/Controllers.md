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

Versions MUST be represented as complete strings. Parsing MUST proceed as follows: separate into two strings, using the point (`.`) as a delimiter. Compare integer representations of `MAJOR`, `MINOR` version (such that v1.12 is greater than v1.5).

Implementers of Controllers are RECOMMENDED to support multiple versions of the NMOS APIs simultaneously in order to ease the upgrade process in live facilities.

#### API Common Keys

Controllers SHOULD follow the requirements for common API keys specified in the [IS-04 APIs: Common Keys](APIs%20-%20Common%20Keys.md) document including the requirements regarding [use of URNs](APIs%20-%20Common%20Keys.md#use-of-urns).

#### Error Codes & Responses

The NMOS APIs use HTTP status codes to indicate success, failure and other cases to Controllers as per [RFC 7231](https://tools.ietf.org/html/rfc7231) and related standards.

As explicit handling of every possible HTTP response code is not expected, Controllers MUST implement generic handling for ranges of response codes (`1xx`, `2xx`, `3xx`, `4xx` and `5xx`).
However, where the RAML specification of an API specifies explicit response codes the Controller SHOULD handle these cases explicitly.

For Controllers performing `GET` and `HEAD` requests, using these methods SHOULD correctly handle a `301` (Moved Permanently) response.

When a `301` is supported, the Controller MUST follow the redirect in order to retrieve the required response payload.

If a Controller receives an HTTP `5xx` or `4xx` response code from the API, a failure has occurred.
The Controller SHOULD display the content of the response's error field to the User if possible, and indicate that the resource is likely to be in an unknown state.
The Controller SHOULD also refresh the endpoints of the relevant resources to ensure the Controller is accurately reflecting the current state of the API.

## Connection Management

The Controller MUST implement connection management according to the [APIs section](APIs.md) of this specification.

The Controller MUST be able to perform an immediate activation between a specified Sender and Receiver via the IS-05 Connection API.

The Controller MUST allow removal of active connections via the IS-05 Connection API.	

The Controller MUST monitor and update the connection status of all discovered IS-05 Senders and Receivers. For instance:
* The Controller MUST identify that a connection to a Receiver has been activated. 
* The Controller MUST be able to identify when an NMOS Sender is connected to that Receiver.
* The Controller MUST identify when the Receiver connection has been deactivated. 

Where making requests to a large number of Senders and/or Receivers on the same Device, Controllers SHOULD make use of the `/bulk` endpoint to bundle them into a single request.

When altering the transport parameters in the `/staged` endpoint, the Controller SHOULD check the `/constraints` endpoint for the available choices of parameters accepted by the particular Sender or Receiver.

When `PATCH`ing to the transport parameters, parameters could possibly have changed since the last `GET`.
Therefore the Controller SHOULD set parameters that are important for a connection (e.g. `master_enable` and `rtp_enable`) in the `PATCH` request, even if the Controller believes they are already set as required.

When connecting a Receiver to an NMOS Sender, the Controller SHOULD communicate the Sender UUID to the receiver using the `sender_id` parameter of the `/staged` endpoint.

## Client Side Implementation Notes

Controllers MUST adhere to the [Client Side Implementation Notes]((APIs%20-%20Client%20Side%20Implementation.md) described in this specification, such as the sections on Conformance to Schemas, RTP Operating Point, and Failure Modes.

## Interoperability

### Identifying Active Connections

As is described in the [Identifying Active Connections section of the Interoperability: IS-04 document](Interoperability%20-%20IS-04.md#identifying-active-connections) in this specification,
in order to populate the subscription attribute of IS-04 Senders and Receivers, the Connection API includes keys for `sender_id` and `receiver_id` in its `/active` and `/staged` parameters.
These are used to signal that a Sender or Receiver is connected to an NMOS Receiver or Sender. 
The Controller MUST set and unset (using `null`) the `sender_id` or `receiver_id` parameters when modifying the `transport_params` or `transport_file`.

### Interacting with Non-NMOS Devices

Controllers MUST follow the requirements for a Client interacting with non-NMOS Devices, as described in the [Interoperability: Non-NMOS Devices](Interoperability%20-%20Non-NMOS%20Devices.md) section of this Specification.

## Behaviour

### Operation with SMPTE 2022-7

When the Controller is interacting with Receivers that support SMPTE 2022-7 it MUST follow the requirements for Clients described in the [Operation with SMPTE 2022-7 section of the Behaviour - RTP Transport Type document](Behaviour%20-%20RTP%20Transport%20Type.md#operation-with-smpte-2022-7) in this specification.

### Version Timestamp

The Controller SHOULD use an IS-04 Query API WebSocket connection to monitor version timestamp increments on Senders and Receivers being controlled.

A version timestamp increment indicates that another Controller has possibly changed resource parameters, and as such any information cached by the Controller could possibly be stale.

### Sender Multicast Address

The Controller MUST allow the User to configure the multicast transmit information (using IS-05 `transport_params`) before or in the same transaction as enabling the transmitter (setting `master_enable` to `true`).
This allows avoiding conflicts with other senders' configurations, in particular when a Sender is added to a new system.

### TCP Sessions

The Controller SHOULD use persistent TCP connections wherever possible,
to allow multiple operations to be performed without repeatedly closing and reopening connections for each operation.

The use of HTTP pipelining has been known to cause interoperability issues in some cases.

If the Controller uses HTTP pipelining, it SHOULD follow the guidelines set out in [RFC 7230 section 6.3.2](https://datatracker.ietf.org/doc/html/rfc7230#section-6.3.2).
