# Fast Food & Nutrition Info Site

A simple Go web application that serves markdown content as HTML. Built with [templ](https://templ.guide/) for server-side rendering and Tailwind CSS for styling.

## Features

- Markdown files rendered as HTML pages
- Server-side rendering for fast, clean performance
- Dark/light theme support
- Responsive design
- No database required

## Pages

- **Home** - Overview of fast food consumption in Canada
- **Fast Food** - General information about fast food
- **Side Effects** - Health risks associated with fast food consumption
- **Dietary Traps** - Common pitfalls in healthy eating
- **Nutritional Values** - Calorie comparison with healthy alternatives

## Development

```bash
# Enter development environment
nix develop

# Run with hot-reload
air

# Or run directly
go run ./cmd/blog/main.go
```

Visit `http://localhost:8080` to view the site.

## Tech Stack

- Go
- [templ](https://templ.guide/) - HTML templating
- [goldmark](https://github.com/yuin/goldmark) - Markdown parsing
- [Tailwind CSS](https://tailwindcss.com/)
- [templui](https://templui.io/) - UI components
