FROM archlinux/base

MAINTAINER root@recolic.net

RUN pacman -Sy
RUN pacman -S --noconfirm curl netcat iputils grep
RUN pacman -S --noconfirm python

RUN mkdir /app
COPY . /app

CMD ["/app/datafile.py.gen.d.py"]

# docker run -v /var/www/html/status.html:/app/status.html my_docker_image

