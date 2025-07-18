# Specifications

This document contains a high level overview of the included roles.

## Applications / Backend Services

* homarr
   - Homepage with links to various services.
   - Exposed port @ `9091`
* transmission-seed
   - Seed various open source projects and/or files.
   - Exposed port @ `9092`
* minio
   - General block storage service. (S3 API Compatible)
   - Exposed port @ `9093`
* nextcloud
   - Suite of selfhosting utilities.
   - Exposed port @ `9095`
* node-red
   - Used for general automation.
   - Exposed port @ `9096`
* observe
   - Used for logging of servers, devices, and applications.
   - Exposed port @ `9098` (grafana)
   - Exposed port @ `3100` (loki)

## Container Service Roles Directory Layout

Most of the roles have a predefined structure, this is to help with creating scripts and ease of management. Below are the most common directoy names and there uses:

* `config` - Similar to `etc` Linux / Unix directory, used for placing config files unless specified.
* `data` - Directory for persistent data.

docker run \
  --name homarr \
  --restart unless-stopped \
  -p 9091:7575 \
  -v /opt/containers/configs:/app/data/configs \
  -v /opt/containers/icons:/app/public/icons \
  -d ghcr.io/ajnart/homarr:latest
