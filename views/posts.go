package views

import (
	"github.com/GreenTheColour1/go-blog/posts"
)

func getPostBySlug(slug string) (*posts.Post, error) {
	return posts.GetPostBySlug(slug)
}

func getHomePost() (*posts.Post, error) {
	return posts.GetPostBySlug("home")
}
