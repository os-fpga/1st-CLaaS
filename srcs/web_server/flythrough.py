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
