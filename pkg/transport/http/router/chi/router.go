package chi

import (
	"net/http"

	"github.com/go-chi/chi"
	"github.com/go-chi/chi/middleware"
	"github.com/kamilsk/guard/pkg/transport/http/router"
)

// Configure TODO issue#docs
func Configure(api router.API) http.Handler {
	r := chi.NewRouter()
	r.Use(middleware.Recoverer)
	r.Use(middleware.RealIP)
	r.Use(middleware.Logger)
	r.Route("/api/v1/license", func(r chi.Router) {
		r.Get("/check", api.CheckLicenseV1)
		r.Put("/extend", api.ExtendLicenseV1)
		r.Post("/register", api.RegisterLicenseV1)
	})
	return r
}