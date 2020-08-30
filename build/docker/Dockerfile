#Base Image
FROM centos:centos7

#Install eFa
COPY build.bash /
RUN bash /build.bash

#Remove startup script; /usr/sbin/eFa-Init
RUN sed -i "/^\/usr\/sbin\/eFa-Init/d" /root/.bashrc

#Debug. Remove when done
RUN yum install -y joe less mlocate

#Replace systemd with one that does not rely on non-existent 'D-Bus'
RUN mv /usr/bin/systemctl /usr/bin/systemctl.old
RUN curl https://raw.githubusercontent.com/gdraheim/docker-systemctl-replacement/master/files/docker/systemctl.py > /usr/bin/systemctl
RUN chmod +x /usr/bin/systemctl

#Volume mappings don't use union fs and are empty. Move contents to a placeholder folder
RUN mv /var/dcc /var/dcc.orig

#Startup script
COPY start.sh /
CMD '/start.sh'
