# Upgrade Path

_(c) AMWA 2017, CC Attribution-NoDerivatives 4.0 International (CC BY-ND 4.0)_

As is common with web APIs, over time changes will be made to support new use cases and deprecate old ways of working. The NMOS APIs are no different, and have been designed to permit in-service upgrades across a facility which could be running large amounts of equipment with support for different versions of these specifications.

API versioning is specified in the [APIs](APIs.md) documentation, with procedures for handling upgrades described below.

## Requirements for Connection APIs

Implementers of the Connection API MUST support at least one API version, and MAY support more than one at a time.

Where a transport type is added in a new version of the Connection API specification, earlier versioned APIs MUST NOT list any Senders or Receivers which make use of this new transport type. In these cases, requests to an inaccessible ID MUST return a `409` (Conflict) HTTP code.

Where new transport parameters are added to a pre-existing transport type in a new version of the Connection API, earlier versioned APIs MUST NOT list these parameters. New transport parameters SHOULD be defined such that a request which omits them can proceed without error. This ensures that servers implementing multiple versions of the Connection API can continue to process earlier versioned requests successfully.

Connection APIs do not need to provide for forwards compatibility as it might be impossible to generate data for new attributes in schemas.

## Requirements for Connection Management clients

Implementers of Connection Management clients are strongly RECOMMENDED to support multiple versions of the Connection API simultaneously in order to ease the upgrade process in live facilities.

## Performing Upgrades

The following procedure is suggested for a live system which needs to migrate between API versions.

- Upgrade API clients to their new versions, to support all Connection API versions you are currently using in your deployment.
- Upgrade Connection API implementations to support the new API version.
