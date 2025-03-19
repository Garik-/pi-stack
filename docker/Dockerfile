FROM redhat/ubi9:9.5

ENV GRAFANA_VERSION=v11.5.2
ENV VICTORIA_METRICS_VERSION=v1.113.0

# TARGETARCH is automatically detected and set by the Docker daemon during the build process. If the build starts
# on an amd64 architecture, than the TARGETARCH will be set to `amd64`.
# More details on the variables can be found here: https://docs.docker.com/desktop/extensions-sdk/extensions/multi-arch/
ARG TARGETARCH
ENV TARGETARCH=${TARGETARCH}

RUN mkdir /pi-stack
WORKDIR /pi-stack

RUN yum install -y dos2unix && yum clean all

RUN bash -c 'ARCHIVE=grafana-"${GRAFANA_VERSION:1}".linux-"${TARGETARCH}".tar.gz && \
    curl -sOL https://dl.grafana.com/oss/release/"${ARCHIVE}" && \
    tar xfz "${ARCHIVE}" && \
    rm "${ARCHIVE}" && \
    mv grafana-"${GRAFANA_VERSION}" grafana/'


RUN bash -c 'ARCHIVE=victoria-metrics-linux-"${TARGETARCH}"-"${VICTORIA_METRICS_VERSION}".tar.gz && \
    curl -sOL https://github.com/VictoriaMetrics/VictoriaMetrics/releases/download/"${VICTORIA_METRICS_VERSION}"/"${ARCHIVE}" && \
    mkdir victoria-metrics && \
    tar xfz "${ARCHIVE}" -C victoria-metrics/ && \
    rm "${ARCHIVE}"'


COPY run-all.sh .

RUN find . -maxdepth 1 -type f | xargs dos2unix



CMD ["/pi-stack/run-all.sh"]