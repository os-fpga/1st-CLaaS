# Framework Overview

The framework provided by [this repository](../README.md) enables an application to be developed as two components (at a minimum): the web/cloud application, and the FPGA kernel. Details for these two components can be found in:

  - [**Kernel Developer's Reference**](../KernelDevelopersReference.md)
  - [**Web Developer's Reference**](../WebDevReference.md)

This document describes general features that affect both of these components. Details are left to code comments to avoid misleading info here.

## REST API

The webserver provides, or can provide, the following REST API features.

  - Self identification: The webserver can determine its own IP to enable direct communication in scenarios where its content is served through a proxy.
  - Starting/Stopping an F1 instance for acceleration.
  