FROM centos
LABEL Name=1stclaas Version=0.0.1
COPY ./docker-image-init.sh /scripts/docker-image-init.sh
RUN chmod +x /scripts/docker-image-init.sh
RUN cd /etc/yum.repos.d/ && sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
RUN yum update -y && yum install git sudo which python3 -y && yum groupinstall 'Development Tools' -y
RUN pip3 install awscli
ENTRYPOINT [ "/scripts/docker-image-init.sh" ]