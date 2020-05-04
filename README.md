Dockerfile for building ubuntu workstation with VNC

ubuntu 20.04 + xfce4 + tigervnc

Building:
	docker build . -t ubuntu-20.04-vnc-workstation

Run:
	docker run -it --rm -e password='password' -p 5901:5901 ubuntu-20.04-vnc-workstation