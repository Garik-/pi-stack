#!/bin/bash

RELEASE=${1:-latest}

docker buildx build -f docker/Dockerfile docker --tag garik/pi-stack:"${RELEASE}"