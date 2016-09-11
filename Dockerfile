# This image is based off of https://github.com/mkobit/docker-nifi. It maybe kept more up-to-date.

FROM openjdk:8-jre-alpine

ENV NIFI_VERSION 1.0.0
#ENV DIST_URL http://10.0.0.52:8000 # Used for testing
ENV DIST_URL https://www.apache.org/dist/nifi/$NIFI_VERSION

ENV NIFI_HOME /opt/nifi
ENV NIFI_USER nifi
ENV NIFI_USER_UID 1000

# Add install deps
RUN set -x \
        && apk add --update curl gnupg \

# Set up a user and group
        && adduser -DHh $NIFI_HOME -u $NIFI_USER_UID $NIFI_USER \

# Import the Apache NiFi release keys
        && curl -Lf https://dist.apache.org/repos/dist/release/nifi/KEYS -o /tmp/nifi-keys.txt \
        && gpg --import /tmp/nifi-keys.txt \

# Download the release
        && curl -Lf $DIST_URL/nifi-$NIFI_VERSION-bin.tar.gz -o /tmp/nifi-bin.tar.gz \
        && curl -Lf $DIST_URL/nifi-$NIFI_VERSION-bin.tar.gz.asc -o /tmp/nifi-bin.tar.gz.asc \
        && curl -Lf $DIST_URL/nifi-$NIFI_VERSION-bin.tar.gz.md5 -o /tmp/nifi-bin.tar.gz.md5 \
        && curl -Lf $DIST_URL/nifi-$NIFI_VERSION-bin.tar.gz.sha1 -o /tmp/nifi-bin.tar.gz.sha1 \
        && curl -Lf $DIST_URL/nifi-$NIFI_VERSION-bin.tar.gz.sha256 -o /tmp/nifi-bin.tar.gz.sha256 \
        && gpg --verify /tmp/nifi-bin.tar.gz.asc /tmp/nifi-bin.tar.gz \
        && echo "$(cat /tmp/nifi-bin.tar.gz.md5)  /tmp/nifi-bin.tar.gz" | md5sum -c - \
        && echo "$(cat /tmp/nifi-bin.tar.gz.sha1)  /tmp/nifi-bin.tar.gz" | sha1sum -c - \
        && echo "$(cat /tmp/nifi-bin.tar.gz.sha256)  /tmp/nifi-bin.tar.gz" | sha256sum -c - \

# Install downloaded tars
        && mkdir -p $(dirname $NIFI_HOME) \
        && tar -xzf /tmp/nifi-bin.tar.gz -C $(dirname $NIFI_HOME) \
        && mv $(dirname $NIFI_HOME)/nifi-$NIFI_VERSION $NIFI_HOME \
        && mkdir -p $NIFI_HOME/database_repository \
                    $NIFI_HOME/flowfile_repository \
                    $NIFI_HOME/content_repository \
                    $NIFI_HOME/provenance_repository \
        && sed -i -e "s|^nifi.ui.banner.text=.*$|nifi.ui.banner.text=Docker NiFi ${NIFI_VERSION}|" ${NIFI_HOME}/conf/nifi.properties \
        && chown $NIFI_USER:$NIFI_USER -R $NIFI_HOME \

# Clean up extra files
        && rm /tmp/nifi-bin.tar.gz \
              /tmp/nifi-bin.tar.gz.asc \
              /tmp/nifi-bin.tar.gz.md5 \
              /tmp/nifi-bin.tar.gz.sha1 \
              /tmp/nifi-bin.tar.gz.sha256 \
              /tmp/nifi-keys.txt \

# Remove install deps
        && apk del curl gnupg \
        && rm -rf /var/cache/apk/*

# These are the volumes (in order) for the following:
# 1) user access and flow controller history
# 2) FlowFile attributes and current state in the system
# 3) content for all the FlowFiles in the system
# 4) information related to Data Provenance
# You can find more information about the system properties here - https://nifi.apache.org/docs/nifi-docs/html/administration-guide.html#system_properties
VOLUME ["$NIFI_HOME/database_repository", \
        "$NIFI_HOME/flowfile_repository", \
        "$NIFI_HOME/content_repository", \
        "$NIFI_HOME/provenance_repository"]

# Open port 8081 for the HTTP listen
USER $NIFI_USER
WORKDIR $NIFI_HOME
EXPOSE 8080 8081
CMD ["bin/nifi.sh", "run"]
