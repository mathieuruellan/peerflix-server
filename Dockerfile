FROM node:buster-slim

# Update latest available packages,
# add 'app' user, and make temp directory

ENV DEBIAN_FRONTEND noninteractive

RUN apt update -yq \
    && apt install -yq ffmpeg git trickle bzip2 \
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

#bandwidth limites
ENV LIMIT_UPLOAD 50
ENV LIMIT_DOWNLOAD 9000

VOLUME [ "/tmp/torrent-stream" ]
EXPOSE 6881 9000

CMD ["sh", "-c", "trickle -u ${LIMIT_UPLOAD}} -d ${LIMIT_DOWNLOAD}} npm start"]
