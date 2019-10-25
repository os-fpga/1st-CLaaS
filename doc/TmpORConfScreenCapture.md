# 1st-CLaaS Screen-Capture Notes for ORConf 2019

## Prep

  ```sh
  cd /tmp/1st-CLaaS/apps/mandelbrot/build
  make destroy SETUP=1st-CLaaS_mandelbrot_accelerator
  rm -rf /tmp/1st-CLaaS
  ```
  
  - Terminals:
    - Terminal 1 in /tmp `*** Part 1: Install and Run ***`
    - Terminal 2 contains command `*** Part 2: FPGA ***`, `cd /tmp/1st-CLaaS/apps/mandelbrot/build`.
    - Terminal 3 contains command `*** Part 3: Custom Kernel ***`, `cd /tmp/1st-CLaaS/apps/vadd/build`.
  - Chrome window with EC2 Console and new tab (open).
  - Note: [---] waiting for machine; [...] waiting for presenter

## Terminal 1: Clone/Init; run Mandelbrot (sim)

  - In Chrome:
    - New tab. Search "1st-CLaaS". Click repo link.
    - Open "Getting Started".
    - Copy 3-lines of clone/cd/init and paste into Terminal 1. [-]
  - In Terminal 1, make launch:
    - `cd apps/mandelbrot/build`
    - `make launch`
  - In Chrome, demo:
    - Open `localhost:8888`
    - Demo C++ (velocity mode, zoom, enlarge)
    - Shrink; Demo "FPGA" (sim)
  - In Terminal 1:
    - <ctrl>-C

## Terminal 2: Build F1 and Demo
  - In Terminal 2, make static_accelerated_instance:
    - <Enter> to `cd /tmp/1st-CLaaS/apps/mandelbrot/build`
      `make static_accelerated_instance PREBUILT=true`
      [Create F1 instance. AWS already set up.]
    - Wait. Type "yes".
    - /STOP RECORDING/
    - /START RECORDING/
    - wait for F1 build
    - ctrl-click IP URL.
  - In Browser, Demo FPGA

## Make Custom App

  - In Terminal 3:
  
    ```sh
    cd /tmp/1st-CLaaS/apps/vadd/build
    make copy_app APP_NAME=toy
    cd ../../toy/build
    ```

  - In Atom:
    - Open /etc/1st-CLaaS/apps/toy/fpga/src/toy_kernel.sv` & edit
    - `make launch`
  - In Chrome:
    - Show that it does a subtract.
