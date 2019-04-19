FROM archlinux/base

MAINTAINER root@recolic.net

RUN pacman -Sy
RUN pacman -S --noconfirm curl netcat iputils grep

COPY do.bash /
RUN chmod +x /do.bash


