#!/bin/bash

source ./logging.sh

run_with_logging "VictoriaMetrics ${VICTORIA_METRICS_VERSION}" "${ENABLE_LOGS_VICTORIA_METRICS:-false}" ./victoria-metrics/victoria-metrics-prod \
  -storageDataPath=/data/victoria-metrics \
  -retentionPeriod=14d \
  -maxConcurrentInserts=4 \
  -httpListenAddr=:8428 \
  -search.latencyOffset=30s \
  -memory.allowedPercent=50 \
  -selfScrapeInterval=10s