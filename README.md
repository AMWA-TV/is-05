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

## Usage

### Sequence Diagrams
When working with transport files it is possible to use the the API in one of two possible ways. The transport file may either be passed the the receiver by reference or directly. Where it is passed by reference the receiver is passed a URL pointing to the transport file. The receiver is then expected to retrieve the transport file itself.

The method of passing files by reference is preferred, as it allows the transport file to be directly acessed from its origin. The prevents the receiver being in posession of a stale copy.

In adittion the API may be used with or without the NMOS query API. The workflow when operating with the query API is slightly simpler but incurs the overhead of requiring a discovery and registration system.

Given below are two sequence diagrams that illustrate the various combinations of work-flow available for the API given these options.

![Diagram showing Connection Management API operating by reference.](docs/by_ref_seq_diagram.png)

![Diagram showing Connection Management API operating directly.](docs/direct_seq_diagram.png)
