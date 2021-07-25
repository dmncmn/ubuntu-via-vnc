# version 0.1

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

RUN DEBIAN_FRONTEND=noninteractive apt install tigervnc-standalone-server tigervnc-common xfce4 xfce4-terminal expect vim mc net-tools htop git -qqy \
	&& apt clean \
	&& rm -rf /var/lib/apt/lists/*

RUN touch ${HOME}/.Xauthority \
	&& printf "allowed_users = anybody" > /etc/X11/Xwrapper.config

RUN mkdir -p ${HOME}/.vnc && printf '#!/bin/sh\n \
	exec startxfce4' >> ${HOME}/.vnc/xstartup \
	&& chmod 775 ${HOME}/.vnc/xstartup \
	&& chown ${USER} -R ${HOME}

RUN cd ${HOME} && git clone https://github.com/novnc/noVNC.git \
	&& cd noVNC/utils && git clone https://github.com/novnc/websockify.git

RUN printf '#!/usr/bin/expect\n \
	spawn /usr/bin/vncserver -localhost no :1 -geometry 1920x1080 -fg\n \
	expect "Password:"; send "$env(password)\r"\n \
	expect "Verify:"; send "$env(password)\r"\n \
	expect "Would you like to enter a view-only password (y/n)?"; send "n\r"\n \
	set timeout -1; expect eof\n' >> ${HOME}/startup.sh \
	&& chmod 775 ${HOME}/startup.sh

RUN printf '#!/bin/bash\n \
	/etc/update-motd.d/00-header\n \
	echo "VNC Workstation start, connect via VNC: locahost:5901"\n \
	expect ./startup.sh > /dev/null &\n \
	echo "Open in browser: http://$(hostname -I | xargs):6080/vnc.html?host=$(hostname -I | xargs)&port=6080"\n \
	echo "============"\n \
	~/noVNC/utils/novnc_proxy --vnc localhost:5901 >> /dev/null\n' >> ${HOME}/entrypoint.sh \
	&& chmod 775 ${HOME}/entrypoint.sh

WORKDIR ${HOME}
USER ${USER}
ENTRYPOINT ./entrypoint.sh
