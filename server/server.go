package server

import (
	"log"
	"net/http"
	"os"

	"github.com/GreenTheColour1/go-blog/assets"
	"github.com/GreenTheColour1/go-blog/posts"
	"github.com/GreenTheColour1/go-blog/views"
	"github.com/a-h/templ"
)

type Server struct{}

func (s *Server) Start() {
	mux := http.NewServeMux()

	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		homePost, err := posts.GetPostBySlug("home")
		if err != nil {
			log.Printf("Error loading home post: %v", err)
		}
		views.Home(homePost).Render(r.Context(), w)
	})

	mux.Handle("/fastfood", templ.Handler(views.PostBySlug("fast-food")))
	mux.Handle("/diseases", templ.Handler(views.PostBySlug("side-effects-of-fast-food")))
	mux.Handle("/traps", templ.Handler(views.PostBySlug("dietary-traps")))
	mux.Handle("/nutritionalvalues", templ.Handler(views.PostBySlug("nutritional-values")))

	mux.HandleFunc("/post/", func(w http.ResponseWriter, r *http.Request) {
		slug := r.PathValue("slug")
		post, err := posts.GetPostBySlug(slug)
		if err != nil || post == nil {
			http.NotFound(w, r)
			return
		}
		views.PostBody(*post).Render(r.Context(), w)
	})

	mux.Handle("/assets/", disableCacheInDevMode(http.StripPrefix("/assets/", http.FileServer(http.FS(assets.Assets)))))

	http.ListenAndServe(":8080", mux)
}

func disableCacheInDevMode(next http.Handler) http.Handler {
	devEnv, _ := os.LookupEnv("ENVIRONMENT")
	if devEnv != "dev" {
		return next
	}
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Cache-Control", "no-store")
		next.ServeHTTP(w, r)
	})
}
