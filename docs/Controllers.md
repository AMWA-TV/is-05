# Controllers

_(c) AMWA 2022, CC Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)_

## Introduction

A Controller is Client software that interacts with the NMOS APIs to discover, connect and manage resources (Nodes, Devices, Senders and Receivers) within a networked media system.

* This document includes normative references to be followed when implementing a Controller.
* This document covers how the Controller interacts with the NMOS APIs only.
  It does not cover other features of the Controller software, such as presentation.
* This document does not cover any requirements relating to where a Controller is additionally acting as a Node (e.g. receiving monitoring information via IS-07).

Where this document refers to a User, this can include both human operators who drive a Controller manually and automation systems that drive a Controller programmatically.

## General

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

#### Error Codes & Responses

The NMOS APIs use HTTP status codes to indicate success, failure and other cases to Controllers as per [RFC 7231](https://tools.ietf.org/html/rfc7231) and related standards.

As explicit handling of every possible HTTP response code is not expected, Controllers MUST implement generic handling for ranges of response codes (`1xx`, `2xx`, `3xx`, `4xx` and `5xx`).
However, where the API specifies explicit response codes the Controller SHOULD handle these cases explicitly.

When a Controller performs `GET` and `HEAD` requests, it MUST correctly handle a `301` (Moved Permanently) redirect to accommodate the API implementations permitted in the [APIs: URLs: Approach to Trailing Slashes](APIs.md#urls-approach-to-trailing-slashes) section of this specification.

If a Controller receives an HTTP `5xx` or `4xx` response code from the API, a failure has occurred.
The Controller SHOULD display the content of the response's `error` field to the User if possible.

## Connection Management

The Controller MUST implement connection management according to the [APIs section](APIs.md) of this specification.

The Controller MUST be able to perform immediate activations of Senders and Receivers to configure connections between them via the IS-05 Connection API.

The Controller MUST be able to perform an immediate activation to disable an active connection via the IS-05 Connection API.	

The Controller tracks the connection status of IS-05 Senders and Receivers being controlled.
[IS-04 provides a mechanism](#version-timestamp) to enable this.

* The Controller MUST identify that a connection to a Receiver has been activated. 
* The Controller MUST be able to identify that an NMOS Sender is connected to that Receiver.
* The Controller MUST identify when the Receiver connection has been deactivated. 

Where making requests to a large number of Senders and/or Receivers on the same Device, Controllers SHOULD make use of the `/bulk` endpoint to bundle them into a single request.

When altering the transport parameters in the `/staged` endpoint, the Controller SHOULD check the `/constraints` endpoint for the available choices for parameters accepted by the particular Sender or Receiver.

When `PATCH`ing the transport parameters, parameters could possibly have changed since the last `GET`.
Therefore the Controller SHOULD set parameters that are important for a connection (e.g. `master_enable` and `rtp_enable`) in the `PATCH` request, even if the Controller believes they are already set as required.

The Connection API includes a `sender_id` parameter in each Receiver's `/active` and `/staged` endpoints.
Similarly, it includes a `receiver_id` parameter in each Sender's `/active` and `/staged` endpoints.
When modifying `transport_params` or `transport_file` to configure a Receiver to connect with a specific NMOS Sender, for example, via unicast RTP or source-specific multicast, the Controller MUST set the `sender_id` parameter.
Similarly, when modifying `transport_params` to configure a Sender to connect with a specific NMOS Receiver, for example, via unicast RTP, the Controller MUST set the `receiver_id` parameter.
Otherwise, when modifying `transport_params` or `transport_file`, the Controller MUST set the `sender_id` or `receiver_id` parameter to `null`.

## Client Side Implementation Notes

Controllers MUST adhere to the [APIs: Client Side Implementation Notes](APIs%20-%20Client%20Side%20Implementation.md) described in this specification, such as the sections on Conformance to Schemas, RTP Operating Point, and Failure Modes.

## Interoperability

### Interoperability with IS-04

#### API Common Keys

Controllers MUST follow the requirements for common API keys specified in the [IS-04 APIs: Common Keys](https://specs.amwa.tv/is-04/releases/v1.3.2/docs/APIs_-_Common_Keys.html) document including the requirements regarding [use of URNs](https://specs.amwa.tv/is-04/releases/v1.3.2/docs/APIs_-_Common_Keys.html#use-of-urns).

### Interacting with Non-NMOS Devices

Controllers MUST follow the requirements for a Client interacting with non-NMOS Devices, as described in the [Interoperability: Non-NMOS Devices](Interoperability%20-%20Non-NMOS%20Devices.md) section of this Specification.

## Behaviour

### Operation with SMPTE 2022-7

When the Controller is interacting with Receivers that support SMPTE 2022-7 it MUST follow the requirements for Clients described in the [Behaviour: RTP Transport Type: Operation with SMPTE 2022-7](Behaviour%20-%20RTP%20Transport%20Type.md#operation-with-smpte-2022-7) section of this specification.

### Version Timestamp

The Controller SHOULD use an IS-04 Query API WebSocket connection to monitor version timestamp increments on Senders and Receivers being controlled.

A version timestamp increment indicates that the properties of a resource have changed, for example by the action of another Controller, and as such any information cached by the Controller could possibly be stale.

### Sender Multicast Address

The Controller MUST allow the User to configure the multicast transmit information (using IS-05 `transport_params`) before or in the same transaction as enabling the transmitter (setting `master_enable` to `true`).
This allows avoiding conflicts with other senders' configurations, in particular when a Sender is added to a new system.

### TCP Sessions

The Controller SHOULD use persistent TCP connections wherever possible,
to allow multiple operations to be performed without repeatedly closing and reopening connections for each operation.

If the Controller uses HTTP pipelining, the guidelines set out in [RFC 7230 section 6.3.2](https://datatracker.ietf.org/doc/html/rfc7230#section-6.3.2) apply.
