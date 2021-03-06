package api

import (
	"net"
	"net/http"

	"github.com/kamilsk/guard/pkg/config"
	"github.com/kamilsk/guard/pkg/transport"
	"github.com/kamilsk/guard/pkg/transport/http/api/internal/chi"
)

// New TODO issue#docs
func New(cnf config.ServerConfig, service Service) transport.Server {
	return &server{config: cnf, service: service}
}

type server struct {
	config  config.ServerConfig
	service Service
}

// Serve TODO issue#docs
func (server *server) Serve(listener net.Listener) error {
	defer listener.Close()
	return (&http.Server{Addr: server.config.Interface, Handler: chi.Configure(server),
		ReadTimeout:       server.config.ReadTimeout,
		ReadHeaderTimeout: server.config.ReadHeaderTimeout,
		WriteTimeout:      server.config.WriteTimeout,
		IdleTimeout:       server.config.IdleTimeout,
	}).Serve(listener)
}
