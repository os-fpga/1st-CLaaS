# Mandelbrot Explorer

## Demo

The Mandelbrot example is hosted [here](http://fractalvalley.net), by [Steve Hoover](mailto:stevehoover@redwoodeda.com), without hardware acceleration.
It includes an About page with general project information.

## Development

### Integration

There is no continuous integration testing. Just open it locally and test manually before making a pull request.

### Deployment

#### fractalvalley.net

Steve holds the button to redeploy your changes at http://fractalvalley.net. If he forgets, please [let him know](mailto:stevehoover@redwoodeda.com).

#### Your own site

To deploy at your own site on port 80 with F1 acceleration enabled:

Create an AWS account w/ F1 privileges. Remember: THIS SOFTWARE IS PROVIDED AS IS. WE ARE NOT RESPONSIBLE FOR AWS CHARGES YOU INCUR BY USING THIS SOFTWARE, INCLUDING CHARGES RESULTING FROM SOFTWARE BUGS.

Create a static F1 instance (based on the latest code in master):

Somewhere:
```
git clone https://github.com/alessandrocomodi/fpga-webserver.git
cd fpga-webserver
./init
aws configure  # Enter AWS keys and region.
cd apps/mandelbrot/build
make f1_instance   # PREBUILT=true only for main developers.
```
This will could run for an hour or more on the F1 instance while the FPGA image is created.

Launch the main webserver:

Log into your server and cd to a directory of your choice.
```
git clone https://github.com/alessandrocomodi/fpga-webserver.git
cd fpga-webserver
./init
aws configure  # Enter AWS keys and region.
cd apps/mandelbrot/build
make PASSWORD=XXX INSTANCE=i-XXX live
```

### Debug in GDB

To debug using GDB inside Atom.
  - Use [dbg-gdb Atom plugin](https://atom.io/packages/dbg-gdb)
  - in `mandelbrot/built`
    - `make host_debug`
    - `F5` in Atom (to run `out/sw/host_debug`), and set breakpoints.
    - `launch -h none sw`
    - In browser, `localhost:8888`

### TO DO

General TO DO items are kept here, where as the issue tracker is used for more specific items. Contact [Steve](mailto:stevehoover@redwoodeda.com) for more details if you are interested in working on any of these items.

#### Web Design

The web page is quick-n-dirty. It could use a designer's touch.

#### Web Dev

There are currently two views, map (using Open Layers) and full-image. Open Layers is great, but it assumes a static image.
It doesn't work for 3-D. And it doesn't refresh when parameters are changed. There is plenty of opportunity to build the
best of both.

#### Building Momentum

Get the word out there and build interest. Put together some flashy demos, fly-through videos.

#### 3-D

Play w/ 3-D controls. Create videos. Get this working in VR displays (like Dodo Case).

#### Algorithms

The current algorithms are brute-force ones. There are ways to optimize. [Some ideas](https://docs.google.com/document/d/1K0gPk9uK7av3IdA827IM3OaHT1pDNHdVi7VGKfMQwHc/edit?usp=sharing).

#### FPGA Optimizations

The current FPGA implementation is not optimized and utilizes a fraction of the available FPGA resources. It could be sped up substantially with a little effort. [Some ideas](https://docs.google.com/document/d/1K0gPk9uK7av3IdA827IM3OaHT1pDNHdVi7VGKfMQwHc/edit?usp=sharing).

