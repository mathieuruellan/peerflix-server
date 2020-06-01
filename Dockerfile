FROM node:buster-slim AS builder

# Update latest available packages,
# add 'app' user, and make temp directory

ENV DEBIAN_FRONTEND noninteractive

RUN apt update -yq \
    && apt install -yq git bzip2 \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN npm install -g grunt-cli bower && \
    useradd app && \
    mkdir /tmp/torrent-stream && \
    chown app:app /tmp/torrent-stream

WORKDIR /home/app
COPY . .
RUN chown app:app /home/app -R

# run as user app from here on
USER app
RUN npm install && \
    bower install && \
    grunt build


FROM node:buster-slim
RUN apt update -yq \
    && apt install -yq ffmpeg trickle \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

WORKDIR /home/app
COPY . .
RUN useradd app
COPY --from=builder /home/app/dist /home/app/dist
RUN chown app:app /home/app -R

USER app

RUN npm install --production

COPY /entrypoint.sh //home/app/entrypoint.sh

#bandwidth limites
ENV LIMIT_UPLOAD 50
ENV LIMIT_DOWNLOAD 9000

VOLUME [ "/tmp/torrent-stream", "/home/app/.config/peerflix-server" ]
EXPOSE 6881 9000

ENTRYPOINT [ "/home/app/entrypoint.sh" ]

