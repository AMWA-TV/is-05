# **[Work In Progress]** AMWA Device Connection Management Specification

This repository contains details of this AMWA Specification for controlling aspects of NMOS Devices to effect connection management between Senders and Receivers.

## Getting started

Readers are advised to be familiar with:
* The JT-NM Reference Architecture (http://jt-nm.org/)
* The [overview of Networked Media Open Specifications](https://github.com/AMWA-TV/nmos)
* The [NMOS Discovery and Registration Specification](https://github.com/AMWA-TV/nmos-discovery-registration) (IS-04)

Readers should then read the [documentation](docs/) in this repository, and the [APIs](APIs/), which are written in RAML -- if a suitable tool is not available for reading this, then [this](APIs/generateHTML) will create HTML versions.

## Contents

* README.md -- This file
* [docs/](docs/) -- Documentation targeting those implementing APIs and clients.
* [APIs/](APIs/) -- Normative specifications of APIs
* [examples/](examples/) -- Example JSON requests and responses for APIs
* [LICENSE](LICENSE) -- Licenses for software and text documents
* [NOTICE](NOTICE) -- Disclaimer

### Un-initialised Senders and Receivers

When a sender or receiver is first started it may not have all the parameters it needs to operate. For example IP addresses and port numbers may not be set. In this instance:

* Senders and receivers should present sensible default values on transport parameter endpoints. Suggested defaults are given in the relevant schemas. Parameters such as port numbers may have defaults in various RFCs that should be followed. Parameters where no sensible defaults exist, such as source IP address on a receiver, should be set to null.
* Senders that are not configured (for example have a null source IP address value), should return 404 on their active transport file endpoint, until a usable set of parameters has been activated.

### Interaction with the Node API###

The Connection Management API supersedes the now deprecated method of updating the "subscription" parameter on Node API receivers in order to establish connection. The two methods of operation are likely to co-exist until Version 2.0 of TR-04. As such the following best practice should be followed when both are in use:

* Where a client updates the Node API subscription the result on connection management should be the same as if the client had first staged the parameters and then called an immediate activation. That is to say that the new parameters will be reflected both in the staged and active endpoints of the receiver.
* Where a client updates a Connection Management API receiver the active ```sender_id``` parameter should be populated in the Node API subscription parameter with key ```sender_id```.
* After a Connection Management API activation the corresponding sender's/receiver's ```version``` property should be updated to the instant of the activation.
