#!/bin/bash

RELEASE=${1:-latest}

# docker pull docker.io/grafana/otel-lgtm:"${RELEASE}"

touch .env

docker run \
	--name pi-stack \
	-p 3000:3000 \
	-p 8428:8428 \
	--rm \
	-ti \
	-v "$PWD"/container/grafana:/data/grafana \
	-v "$PWD"/container/victoria:/data/victoria \
	-e GF_PATHS_DATA=/data/grafana \
	--env-file .env \
	garik/pi-stack:"${RELEASE}"
