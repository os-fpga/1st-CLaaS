#!/usr/bin/sh

# Initialization script for Accelerated Web Server.
#   o Call common init.sh.
#   o Setup passwordless ssh for localhost ssh. This is used for cron job which needs an environment, and the only reliable
#     way I can find to establish the right environment is to ssh.
#   o Establish cron @reboot command to start web server.
#   o Compile and start web server for manual testing at <IP>:80.
echo \
 && echo "Running config_static_f1_instance.sh" \
 && echo \
 && echo "Setting up localhost ssh." \
 && ssh-keygen -N '' -f ~/.ssh/id_rsa \
 && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys \
 && echo \
 && echo "Setting up cron job to start web server." \
 && sudo bash -c 'echo "@reboot centos /home/centos/src/project_data/fpga-webserver/framework/terraform/static_f1_reboot.sh" >> /etc/crontab' \
 && echo \
 && echo "Running reboot script to pre-build and start web server for manual testing." \
 && /home/centos/src/project_data/fpga-webserver/framework/terraform/static_f1_reboot.sh \
 && echo \
 && echo "YAY!!! The web server has been launched." \
 && echo -e "\e[1m\e[33mYOU HAVE 3 MINUTES to test it out at http://$1 (<Ctrl>-click), then the machine will be shutdown, if not stopped manually (but check to be sure).\e[0m" \
 && sleep 180;
STATUS=$?
nohup bash -c 'sleep 1 && sudo shutdown now &> /dev/null < /dev/null &'
exit $STATUS # Exit (before shutdown).
