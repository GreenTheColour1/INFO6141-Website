package views

import "github.com/a-h/templ"

func PostBySlug(slug string) templ.Component {
	post, err := getPostBySlug(slug)
	if err != nil || post == nil {
		return NotFound()
	}
	return PostBody(*post)
}

func NotFound() templ.Component {
	return StaticPage("Page Not Found")
}
