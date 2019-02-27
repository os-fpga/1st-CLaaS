"""
BSD 3-Clause License

Copyright (c) 2018, alessandrocomodi
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the copyright holder nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
"""


# Main application for the web server.

from server import *

"""
Generate a zooming video.
"""
def flythrough(x_center, y_center, x_radius, y_radius, img_width, img_height, max_depth, zoom_factor, num_frames):
  renderer = "FPGA"  # (most agressive available)
  for img_num in range(num_frames):
    img_data = get_img([x_center - x_radius,
                        y_center - y_radius,
                        (x_radius * 2.0) / img_width,
                        (y_radius * 2.0) / img_height,
                        img_width,
                        img_height,
                        max_depth],
                       renderer)
    file = open('video/tmp_frame' + str(img_num) + '.png', "w")
    file.write(img_data)
    file.close()
    # Zoom by zoom_factor.
    x_radius *= zoom_factor
    y_radius *= zoom_factor


def flythroughMain():
  initSocket()

  # Delete images.
  if (subprocess.call("rm video/tmp_frame*.png", shell=True)):
    sys.stderr.write("Failed to remove temporary image files.")

  flythrough(0.29609899100000003, 0.577698899030599, 1.4, 1.4, 1023, 1023, 1000, 0.94 ** 1, 400)

  # Delete existing video.
  subprocess.call("rm video/video.mp4", shell=True)
  # Create video from images.
  if (subprocess.call("ffmpeg -framerate 12 -i video/tmp_frame%d.png video/video.mp4", shell=True)):
    sys.stderr.write("ffmpeg command failed.")
    
  # Stay open until killed, to conform to web server use model.
  print('All done. You can Ctrl-C now.')
  while (True):
    time.sleep(10)

if __name__ == "__main__":
  flythroughMain()
