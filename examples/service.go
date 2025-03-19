package main

import (
	"context"
	"math/rand/v2"
	"time"

	"github.com/VictoriaMetrics/metrics"
)

type Service struct {
}

func newService(addr string, interval time.Duration) (*Service, error) {
	pushURL := "http://" + addr + "/api/v1/import/prometheus"
	extraLabels := `instance="self",job="service"`

	return &Service{}, metrics.InitPush(pushURL, interval, extraLabels, true)
}

func (s *Service) run(ctx context.Context) error {
	h := metrics.NewHistogram(`request_duration_seconds{path="/foo/bar"}`)

	ticker := time.NewTicker(2 * time.Second)
	defer ticker.Stop()

	for {
		h.Update(rand.Float64() * 10_100) //nolint:gosec

		select {
		case <-ctx.Done():
			return nil
		case <-ticker.C:
		}
	}
}
