FROM centos
LABEL Name=1stclaas Version=0.0.1
COPY ./docker-image-init.sh /scripts/docker-image-init.sh
RUN chmod +x /scripts/docker-image-init.sh
RUN yum update -y && yum install git sudo which python3 -y && yum groupinstall 'Development Tools' -y
RUN pip3 install awscli
ENTRYPOINT [ "/scripts/docker-image-init.sh" ]