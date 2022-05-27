# Interoperability: IS-04

_(c) AMWA 2017, CC Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)_

The Connection API shares a data model with the IS-04 specification, and as a result it is designed to be used alongside it. The following sub-sections identify correct behaviour for doing this.

When this API is used alongside IS-04 in a deployment, the IS-04 APIs SHOULD be operating at version 1.2 or greater in order to ensure full interoperability.

## Discovery

The Connection API SHOULD be advertised as a control endpoint when publishing a compliant NMOS Device.
Control interfaces can identify all Devices which implement the Connection API by a `type` Uniform Resource Name (URN) having the base `urn:x-nmos:control:sr-ctrl` followed by a `/` character and the API version.
The associated `href` is the URL of the Connection API base resource.

**Example:** The `controls` attribute of a single NMOS Device

```json
...
"controls": [
  {
    "type": "urn:x-nmos:control:sr-ctrl/v1.1",
    "href": "http://192.168.10.3/x-nmos/connection/v1.1/"
  }
]
...
```

As shown above the API version is included in the `type`, and in the `href`. Further control endpoints for the Connection API MAY be advertised for Devices which support multiple versions simultaneously, or have multiple network interfaces.

More details about multi-version support can be found in [Upgrade Path](Upgrade%20Path.md).

A given instance of the Connection API MAY offer control of multiple Devices in a Node from a single URI. Alternatively there MAY be multiple instances of the API on one Node, each corresponding to one Device. A separate endpoint for each Device's Connection Management instance MUST be advertised in the Device's `controls`, even if the URI is the same.

API implementations MAY list an `href` with or without a trailing slash, provided that the trailing slash policy in [APIs](APIs.md#urls-approach-to-trailing-slashes) is adhered to. Implementers of clients need to avoid double or missing slashes when appending paths onto `href`s.

## Sender & Receiver IDs

The UUIDs used to advertise Senders and Receivers in the Connection API MUST match those used in a corresponding IS-04 implementation.

## Version Increments

In order to prevent unnecessary polling of the Connection API, changes to active connection parameters are signalled via the IS-04 versioning mechanism. When the active parameters of a Sender or Receiver are modified, or when a re-activation of the same parameters is performed, the `version` attribute of the relevant IS-04 Sender or Receiver MUST be incremented.

## Identifying Active Connections

The Connection API includes a `master_enable` parameter in the `/active` endpoint of each Sender and Receiver.
The Receiver endpoint also includes a `sender_id` parameter that can be used to indicate that the Receiver is connected to a specific NMOS Sender, for example, via unicast RTP or source-specific multicast.
Similarly, the Sender endpoint includes a `receiver_id` parameter that can be used to indicate that the Sender is connected to a specific NMOS Receiver, for example, via unicast RTP.
The API implementation MUST use these parameters to populate the `subscription` attribute of the corresponding IS-04 Sender or Receiver, according to the [Behaviour: Nodes](https://specs.amwa.tv/is-04/releases/v1.3.1/docs/4.3._Behaviour_-_Nodes.html) section of the IS-04 specification.
It is the client's responsibility to set or unset (using `null`) the `sender_id` or `receiver_id` parameters when modifying the `transport_params` or `transport_file`.

## Support For Legacy IS-04 Connection Management

The Connection API supersedes the now deprecated method of updating the `/target` resource on Node API Receivers in order to establish connections. The two methods of operation are likely to co-exist until Version 2.0 of IS-04. As such the following best practice SHOULD be followed when both are in use:

- Where a client establishes a connection via the Node API `/target` resource, which updates the Receiver's `subscription` object, the result on the Connection API SHOULD be as if the client had staged the parameters and requested an immediate activation to enable the Receiver. That is to say that the new parameters, including the `sender_id` and with `master_enable` set to `true`, will be reflected in both the `/staged` and `/active` endpoints of the Receiver.
- When the active parameters of a Sender or Receiver are modified via a Connection API activation, the Node API Sender or Receiver `subscription` object SHOULD be updated to reflect the active state. That is to say that the `active` attribute and the `receiver_id` or `sender_id` of the `subscription` object will match the `master_enable` and `receiver_id` or `sender_id` values in the Connection API `/active` endpoint.
- The `version` attribute of the Node API resource is also updated on every activation, as described in [Version Increments](#Version-Increments).

If staged modifications are present when a legacy activation is performed, these parameters MUST be discarded in favour of those provided via the Node API interface.
