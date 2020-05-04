# version 0.0.1
FROM ubuntu:20.04

ENV USER=user
ENV PASW=user
ENV HOME=/home/${USER}

RUN apt update && apt install sudo

RUN mkdir ${HOME} \ 
	&& addgroup wheel \ 
	&& useradd -p $(perl -e 'print crypt($ARGV[0], "password")' ${PASW}) -s /bin/bash ${USER} -d ${HOME} \
	&& usermod -aG wheel ${USER} \
	&& echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

RUN DEBIAN_FRONTEND=noninteractive apt install tigervnc-standalone-server tigervnc-common xfce4 xfce4-terminal expect -y \
	&& apt clean

RUN touch ${HOME}/.Xauthority \
	&& echo "allowed_users = anybody" > /etc/X11/Xwrapper.config

RUN mkdir -p ${HOME}/.vnc \
	&& echo '#!/bin/sh' > ${HOME}/.vnc/xstartup \
	&& echo 'exec startxfce4' >> ${HOME}/.vnc/xstartup \
	&& chmod 775 ${HOME}/.vnc/xstartup \
	&& chown ${USER} -R ${HOME}

RUN echo '#!/usr/bin/expect' > ${HOME}/startup.sh \
	&& echo 'spawn /usr/bin/vncserver -localhost no :1 -geometry 1920x1080 -fg' >> ${HOME}/startup.sh \
	&& echo 'expect "Password:"; send "$env(password)\r"' >> ${HOME}/startup.sh \
	&& echo 'expect "Verify:"; send "$env(password)\r"' >> ${HOME}/startup.sh \
	&& echo 'expect "Would you like to enter a view-only password (y/n)?"; send "n\r"' >> ${HOME}/startup.sh \
	&& echo 'set timeout -1; expect eof' >> ${HOME}/startup.sh \
	&& chmod 775 ${HOME}/startup.sh

WORKDIR ${HOME}
USER ${USER}
ENTRYPOINT ["expect", "./startup.sh"]