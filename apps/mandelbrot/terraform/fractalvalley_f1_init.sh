#!/bin/sh

# Initialization script for fractalvalley F1 server.
#   o Establish cron @reboot command to start webserver.
#   o Compile and start webserver for manual testing at <IP>:80.
# If all's well, after running this via terraform, manually rename server to "fractalvalley.net-F1" and this will be the server used by fractalvaalley.net.
(echo \
 && echo "Running fractalvalley_f1_init.sh" \
 && echo \
 && echo "Setting up cron job to start webserver." \
 && sudo bash -c 'echo "@reboot /home/centos/src/project_data/fpga-webserver/apps/mandelbrot/terraform/fractalvalley_reboot.sh" >> /etc/crontab' \
 && echo \
 && echo "Running reboot script to pre-build and start webserver for manual testing." \
 && /home/centos/src/project_data/fpga-webserver/apps/mandelbrot/terraform/fractalvalley_reboot.sh \
 && echo "Done $0" \
 && echo)
