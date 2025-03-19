package main

import (
	"context"
	"math/rand/v2"
	"time"

	"github.com/VictoriaMetrics/metrics"
)

type Service struct {
}

func newService(addr string, interval time.Duration, instance string) (*Service, error) {
	pushURL := "http://" + addr + "/api/v1/import/prometheus"
	extraLabels := `instance="` + instance + `"`

	return &Service{}, metrics.InitPush(pushURL, interval, extraLabels, true)
}

func randFloat(min, max float64) float64 {
	return min + rand.Float64()*(max-min)
}

func (s *Service) run(ctx context.Context) error {
	h := metrics.NewHistogram(`request_duration_seconds{path="/foo/bar"}`)

	ticker := time.NewTicker(2 * time.Second)
	defer ticker.Stop()

	for {
		h.Update(randFloat(0, 10_100))

		select {
		case <-ctx.Done():
			return nil
		case <-ticker.C:
		}
	}
}
