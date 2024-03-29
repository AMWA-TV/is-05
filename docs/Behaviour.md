# Behaviour

_(c) AMWA 2017, CC Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)_

## Re-Activating Senders & Receivers

If an explicit activation is performed against a Sender or Receiver, the API MUST request a re-application of settings to the underlying Sender or Receiver implementation whether the setting have changed or not. For example in the case of multicast Receivers it is suggested that this involves an explicit IGMP leave and join. For a Sender this might involve stopping and re-starting the stream.

## Transport Files & Caching

It is strongly RECOMMENDED that the following caching headers are included via the `/transportfile` endpoint (or whatever this endpoint redirects to).

```http
Cache-Control: no-cache
```

This is important to ensure that connection management clients do not cache the contents of transport files which are liable to change.

## Multi-Client Operation

In environments where multiple clients might be operating against a single Connection API, it is possible that staging of parameters could result in conflicts. There is intentionally no mechanism to prevent this in the API, however clients SHOULD examine the results of HTTP `PATCH` operations which will return the full complement of current settings, allowing the client to confirm that only the changes it had requested have been made.

## In-Progress Activations

When an implementation is in the process of activating a new set of transport parameters, concurrent requests to the API from other clients could result in unexpected results. In order to minimise these cases, implementations are RECOMMENDED to adopt the following practice:

- While an activation is in progress, concurrent `GET` requests to the `/active` resource SHOULD reflect the current configuration of the Sender or Receiver as accurately as possible at the instant of the request.
- If an API implementation receives a new `PATCH` request to the `/staged` resource while an activation is in progress it SHOULD block the request until the previous activation is complete. Any `GET` requests to `/staged` during this time MAY also be blocked until the activation is complete.

## Connection Status

The Connection API does not take any responsibility for monitoring the status of a connection between a Sender and a Receiver, for example whether a Receiver is currently receiving packets. As such a loss of packets at a connectionless Receiver (e.g. UDP) or a recoverable error on a connection-oriented transport (e.g. TCP) MUST NOT be indicated via changes to the `/active` resource. Where a connection-oriented transport encounters a recoverable error (such as a broken connection or timeout), the underlying Sender or Receiver SHOULD attempt to recover from the error unless otherwise configured not to do so. This could involve the use of exponential backoff up to a defined limit. Where a Sender or Receiver is permanently unable to recover a connection-oriented transport without user interaction, for example due to erroneous configuration which was not identified prior to activation, the implementation MAY set `master_enable` to `false` in the `/active` resource.

## 'Salvo' Operation

Where a server implementation supports concurrent application of settings changes to underlying Senders and Receivers, it could choose to perform 'bulk' resource operations in a parallel fashion internally. This is an implementation decision and is not a requirement of this specification.

If a 'bulk' request includes multiple sets of parameters for the same Sender or Receiver ID the behaviour is defined by the implementation. In order to maximise interoperability clients are encouraged not to include the same Sender or Receiver ID multiple times in the same 'bulk' request.

## Scheduled Activations

IS-05 provides a mechanism whereby the activation of staged transport parameters can be performed at a particular TAI time, or after a given interval.

In NMOS APIs, a TAI timestamp is represented as a string of the format: `<seconds>:<nanoseconds>`. Note the `:` as opposed to a `.`, indicating that the value `1439299836:10` is interpreted as 1439299836 seconds and 10 nanoseconds.

The primary use case for this behaviour is to allow the synchronisation of large salvo operations, where multiple systems carry out a change in transport parameters simultaneously. A controller will stage parameters with multiple IS-05 APIs with the same activation timestamp, and know that activation will occur at the same time on all devices regardless of the latency between the controller and the device. It is not intended to act as a mechanism for scheduling activations far in the future.

In the event of an error occurring between scheduling an activation and the activation time, the IS-05 transport parameters SHOULD reflect the current configuration of the device. For example, if a sender is no longer sending data at all it would set `master_enable` to `false`.

API clients SHOULD check back with the API after the expected activation time to ensure activations have completed successfully, and that the device is in the expected state. Note that a client would normally expect to see a change in the IS-04 `version` timestamp upon a successful activation of transport parameters, and SHOULD monitor for this `version` timestamp update via an IS-04 Query API WebSocket subscription where IS-05 is being used alongside IS-04.

## Externally Defined Parameters

IS-05 aims to provide a defined core set of parameters for each supported transport type. These parameters are based upon the standard(s) which define the transport type.

In some cases it is necessary to advertise and accept additional parameters in order to make a connection, for example where an external specification extends an existing transport type in order to fulfil its own requirements. In such cases, IS-05 provides the capability to define additional transport parameters which use the prefix `ext_`. These transport parameters are governed by the same constraints structure as any other parameter, but are intended to make IS-05 more extensible for these use cases.

Where `ext_` parameters are utilised, their naming, usage and versioning is defined externally to IS-05. Clients SHOULD ignore any such parameters they do not recognise.
