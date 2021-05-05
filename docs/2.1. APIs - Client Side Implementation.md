# APIs: Client Side Implementation Notes

_(c) AMWA 2017, CC Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)_

## Conforming to Schemas

The Connection API schemas define sets of parameters for each supported transport type; these are also described in pages in the [Behaviour](4.0.%20Behaviour.md) section of these documents. These pages define which parameters are always present (core), and which are feature-dependent; a client can determine what a Device supports by getting its `/constraints` resource, and SHOULD parse this resource in all cases as a Device might have a constrained range or enumeration of supported values, even for core parameters.

## RTP Operating Point

When establishing an RTP connection between two Devices that implement NMOS Connection Management, the expectation is that the primary means of connection will be to supply the SDP file from the Sender to the Receiver. This ensures Receivers have the media information in the SDP file. If desired the client can adjust individual transport parameters on the Receiver. For example it could use the `rtcp_enable` parameter to toggle RTCP operation.

When receiving from a (non-NMOS) Device which does not provide an SDP file, a connection can be established using transport parameters alone. In this case it might be necessary to provide media information out-of-band.

## Failure Modes

If a client receives an HTTP `500` (Internal Server Error) response code from the API a failure has occurred and the `error` field can be used to indicate to a user that the Device might be in a bad state. In such a case the client SHOULD refresh the values in the `/staged` and `/active` endpoints to reflect the current state of the API.

If an activation is triggered across multiple Senders and Receivers using the `/bulk` interface, Senders and Receivers will transition to their new active parameters, even if some Senders or Receivers in the same salvo fail to activate. It is the responsibility of the client to recover from this situation if desired, including reverting Senders and Receivers that have successfully activated back to their original state where necessary.
