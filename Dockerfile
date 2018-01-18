FROM base/archlinux
COPY . /root/loadout
ENV DOCKERBUILD 1
RUN /bin/sh -c "echo 'en_US.UTF-8 UTF-8' > /etc/locale.gen; locale-gen; echo 'LANG=en_US.UTF-8' > /etc/locale.conf"
RUN /root/loadout/root.sh
# because it's in docker, sudo doesn't really matter, and we can't input the
# password during the build anyway (also there isn't a password)
RUN /bin/sh -c "echo 'mediocregopher ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/mediocregopher-all"
RUN /bin/su mediocregopher -c /home/mediocregopher/src/loadout/main.sh
RUN rm -rf /home/mediocregopher
CMD ["/bin/su", "-", "mediocregopher"]
