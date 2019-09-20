# 1st-CLaaS Screen-Capture Notes for ORConf 2019

## Clone/Init

  - Chrome. Search "1st-CLaaS FPGA". Click repo link.
  - Open "Getting Started".
  - Copy 3-lines of clone/cd/init.

## run Mandelbrot

  - Copy 2-lines of Run Mandelbrot Locally.
  - Chrome: open "localhost:8888"
  - Demo C++
  - Demo "FPGA" (sim)
  - Pull in pre-opened fractalvalley:8000
  - Start FPGA
  - Demo

## Make Custom App

```sh
cd apps/apps/vadd/build
make copy_app APP_NAME=toy
cd ../../toy/build
```

  - Atom: Modify to subtract.
  - `make launch`
  - Open in Chrome, and show that it does a subtract.
