# Docker Apache NiFi

This is an unofficial Apache NiFi Docker image. This image is based off of [mkobit/docker-nifi](https://github.com/mkobit/docker-nifi). The main difference is this image uses [Apline linux](https://alpinelinux.org/) as its base.

## Running Image
To try out NiFi on Docker:
1. Pull the `latest` image

    docker pull wesclemens/nifi

2. Run image and expose the default ports to the host

    docker run -it --rm -p 8080-8081:8080-8081 wesclemens/nifi

## Environment Valuables

It can be helpful changes these if you plan on mounting a local directory.

NIFI_HOME - Location to install NiFi *Default: /opt/nifi*

NIFI_USER - Username of NiFi User *Default: nifi*

NIFI_USER_ID - User ID of NiFi User *Default: 1000*

## Volumes

These are the default locations as specified by the Apache NiFi properties. You can find more information about each of these repositories on the System Administration Guide.

$NIFI_HOME/database_repository - user access and flow controller history

$NIFI_HOME/flowfile_repository - FlowFile attributes and current state in the system

$NIFI_HOME/content_repository - content for all the FlowFiles in the system

$NIFI_HOME/provenance_repository - information related to Data Provenance

## ListenHTTP Processor

The standard library has a built-in processor for an HTTP endpoint listener. That processor is named ListenHTTP. You should set the Listening Port of the instantiated processor to 8081 if you follow the instructions from above.
