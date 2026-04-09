package posts

import (
	"bytes"
	"embed"
	"io/fs"
	"strings"

	chromahtml "github.com/alecthomas/chroma/v2/formatters/html"
	"github.com/yuin/goldmark"
	highlighting "github.com/yuin/goldmark-highlighting/v2"
	"github.com/yuin/goldmark/extension"
	"github.com/yuin/goldmark/renderer/html"
)

type Post struct {
	Title    string
	Filename string
	Slug     string
	Body     []byte
	RawHTML  string
}

//go:embed files/*.md
var PostAssets embed.FS

func GetAllPosts() ([]Post, error) {
	files, err := fs.Glob(PostAssets, "files/*.md")
	if err != nil {
		return nil, err
	}

	var posts []Post
	for _, file := range files {
		title := strings.TrimSuffix(file[6:], ".md")
		slug := strings.ToLower(strings.ReplaceAll(title, " ", "-"))
		posts = append(posts, Post{
			Title:    title,
			Filename: file,
			Slug:     slug,
		})
	}

	return posts, nil
}

func GetPostBySlug(slug string) (*Post, error) {
	posts, err := GetAllPosts()
	if err != nil {
		return nil, err
	}

	for _, post := range posts {
		if post.Slug == slug {
			body, err := PostAssets.ReadFile(post.Filename)
			if err != nil {
				return nil, err
			}
			post.Body = body
			post.ConvertBodyToHTML()
			return &post, nil
		}
	}

	return nil, nil
}

func (p *Post) ConvertBodyToHTML() {
	markdown := goldmark.New(
		goldmark.WithExtensions(
			extension.GFM,
			highlighting.NewHighlighting(
				highlighting.WithStyle("gruvbox"),
				highlighting.WithFormatOptions(
					chromahtml.WithLineNumbers(true),
				),
			),
		),
		goldmark.WithRendererOptions(
			html.WithUnsafe(),
		),
	)

	var buf bytes.Buffer

	if err := markdown.Convert(p.Body, &buf); err != nil {
		panic(err)
	}

	p.RawHTML = buf.String()
}
