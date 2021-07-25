# ubuntu-via-vnc
Dockerfile for building ubuntu workstation with VNC

ubuntu 20.04 + xfce4 + tigervnc + noVNC

Build:
```
docker build . -t ubuntu-vnc-ws
```
Run:
```
docker run -it --rm -e password='password' -p 5901:5901 ubuntu-vnc-ws
```
Use VNC client to connect (Remmina or others): 
```
localhost:5901
```
Or open in browser (see instructions after run): 
```
172.17.0.2:6080/vnc.html?host=172.17.0.2&port=6080
```

![Image alt](https://github.com/dmncmn/ubuntu-via-vnc/blob/main/pic1.png)
![Image alt](https://github.com/dmncmn/ubuntu-via-vnc/blob/main/pic2.png)

