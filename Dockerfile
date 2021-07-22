FROM ubuntu:20.04

MAINTAINER root@recolic.net

RUN apt update
RUN DEBIAN_FRONTEND=noninteractive apt install -y curl netcat iputils-ping python3.8 dnsutils
RUN ln -s /usr/bin/python3.8 /usr/bin/python3
# RUN pacman -Sy
# RUN pacman -S --noconfirm curl netcat iputils grep
# RUN pacman -S --noconfirm python

RUN mkdir /app
COPY . /app

WORKDIR /app
CMD ["./datafile.py.gen.d.py"]

# docker run -v /var/www/html/status.html:/app/status.html my_docker_image

