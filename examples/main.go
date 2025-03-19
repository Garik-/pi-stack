package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"time"
)

const (
	defaultAddr         = "localhost:8428"
	defaultPushInterval = 5 * time.Second
)

func main() {
	if err := run(); err != nil {
		log.Fatalln(err)
	}
}

func run() (err error) {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt)
	defer stop()

	log.Printf("start service with addr=%s interval=%s\n", defaultAddr, defaultPushInterval)
	srv, err := newService(defaultAddr, defaultPushInterval)
	if err != nil {
		return
	}

	srvErr := make(chan error, 1)
	go func() {
		srvErr <- srv.run(ctx)
	}()

	// Wait for interruption.
	select {
	case err = <-srvErr:
		return
	case <-ctx.Done():
		// Wait for first CTRL+C.
		// Stop receiving signal notifications as soon as possible.
		stop()
	}

	return
}
