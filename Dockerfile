from ekzhang/rustpad:latest AS rustpad

from archlinux:latest AS server
COPY . .
COPY --from=rustpad dist rustpad/dist
COPY --from=rustpad rustpad-server rustpad/rustpad-server
RUN yes | pacman -Syu
RUN yes | pacman -S nginx typst vim sqlite3
RUN mv nginx.conf /etc/nginx/nginx.conf.bak && \
	mv *.html /usr/share/nginx/html/ && \
	mkdir -p /pdf && \
	mv *.pdf /pdf
CMD [ "rustpad/rustpad-server & bash typst_watcher.sh" ]
