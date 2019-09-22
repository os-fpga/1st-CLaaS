# 1st-CLaaS Screen-Capture Notes for ORConf 2019

## Clone/Init

  - Chrome. Search "1st-CLaaS FPGA". Click repo link.
  - Open "Getting Started".
  - Copy 3-lines of clone/cd/init.

## run Mandelbrot

  - In Terminal 2:
    - [AWS already set up]
      Create FPGA instance:
      `cd /tmp/fpga-webserver/apps/mandelbrot/build && make static_accelerated_instance PASSWORD=demo PREBUILT=true`
      (and let it run in background)
    - type "yes"
  - `make launch`
  - In Chrome, open `localhost:8888`
  - Demo C++
  - Demo "FPGA" (sim)
  - wait for F1 build
  - ? Open AWS Console ?
  - NO: Grab IP address
  - NO: Start FPGA
  - Demo FPGA

## Make Custom App

```sh
cd apps/apps/vadd/build
make copy_app APP_NAME=toy
cd ../../toy/build
```

  - Atom: Modify to subtract.
  - `make launch`
  - Open in Chrome, and show that it does a subtract.
