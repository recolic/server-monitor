FROM ubuntu:20.04

MAINTAINER root@recolic.net

RUN apt update
RUN apt install -y curl netcat iputils-ping python3.8
# RUN pacman -Sy
# RUN pacman -S --noconfirm curl netcat iputils grep
# RUN pacman -S --noconfirm python

RUN mkdir /app
COPY . /app

WORKDIR /app
CMD ["./datafile.py.gen.d.py"]

# docker run -v /var/www/html/status.html:/app/status.html my_docker_image

