# Agent Instructions for go-blog

This is a Go blog application using the [templ](https://templ.guide/) framework for server-side rendering with Tailwind CSS.

## Project Structure

```
.
├── cmd/blog/          # Main application entry point
├── posts/             # Markdown post handling and serving
├── server/            # HTTP server and routing
├── views/             # Templ components and templates
│   ├── components/   # Reusable UI components (button, dialog, etc.)
│   └── modules/       # Page-level components (navbar, themeSwitcher)
├── utils/             # Utility functions (TwMerge, If, etc.)
├── assets/           # Static assets (CSS, JS)
└── tmp/               # Build output
```

## Build Commands

### Development
```bash
# Generate templ code and build the application
templ generate && go build -o ./tmp/bin/main ./cmd/blog/main.go

# Run with hot-reload (uses .air.toml)
air

# Run directly
go run ./cmd/blog/main.go
```

### Production
```bash
templ generate
go build -o ./bin/blog ./cmd/blog/main.go
./bin/blog
```

### Docker
```bash
docker compose up --build
```

### Nix (Recommended)
```bash
# Enter development shell with all dependencies
nix develop

# Build the project
nix build

# Run the Docker image
docker load < $(nix build .#blog-image --print-out-paths)
```

## Linting and Formatting

```bash
# Format code (imports, spacing, etc.)
go fmt ./...

# Run go vet for static analysis
go vet ./...

# Generate templ code (always required after editing .templ files)
templ generate
```

## Testing

```bash
# Run all tests
go test ./...

# Run a single test function
go test -run TestFunctionName ./...

# Run tests with verbose output
go test -v ./...

# Run tests with coverage
go test -cover ./...
```

## Code Style Guidelines

### General Go Conventions

- **Error Handling**: Return errors with descriptive messages using `fmt.Errorf("Failed to [action]: %w", err)`. Never silently ignore errors. Use `log.Fatal` only in main initialization code.
- **Naming**: Use camelCase for variables and functions, PascalCase for exported types and functions. Package names should be short and lowercase.
- **Imports**: Group imports: stdlib first, then third-party packages, then internal packages. Use `go fmt` to organize.
- **Context**: Pass `context.Context` as the first parameter for functions that perform I/O operations.

### Code Organization

```go
package packagename

import (
    "context"
    "fmt"
    "net/http"
    "os"

    "github.com/example/pkg"
    "github.com/GreenTheColour1/go-blog/posts"
)
```

### HTTP Server Patterns

- Use `http.NewServeMux()` for routing
- Use `http.StripPrefix` for static file serving
- Use environment variables for configuration (e.g., `ENVIRONMENT`)
- Cache control headers should be disabled in dev mode

### Posts

- Markdown files are embedded at compile time in `posts/posts.go`
- Posts are served by reading from the embedded filesystem
- Use `GetAllPosts()` to list all posts and `GetPostBySlug()` to fetch a single post

### Templ Components

#### File Structure
- Source templ files use `.templ` extension (e.g., `button.templ`)
- Generated Go files end in `_templ.go` (do not edit these)
- Components belong in `views/components/<name>/` or `views/modules/`

#### Component Pattern
```go
package componentname

import "github.com/GreenTheColour1/go-blog/utils"

type Props struct {
    Class      string
    Variant    string
    Attributes templ.Attributes
}

templ Component(props ...Props) {
    {{ var p Props }}
    if len(props) > 0 {
        {{ p = props[0] }}
    }
    <button
        class={ utils.TwMerge("base-classes", p.Class) }
        { p.Attributes... }
    >
        { children... }
    </button>
}
```

#### Props Conventions
- Use `Props` struct with optional fields
- Use variadic `Props` for optional props: `func Button(props ...Props)`
- Helper methods should be on `Props` type (e.g., `p.variantClasses()`)
- Use `utils.TwMerge()` for Tailwind class conflicts
- Use `utils.If(condition, "class")` for conditional classes
- Use `utils.IfElse(condition, trueVal, falseVal)` for ternary-like behavior

#### Naming
- Component files: lowercase, singular (e.g., `button.templ`, `dialog.templ`)
- Component functions: PascalCase (e.g., `templ Button(...)`)
- Helper files: same as component file (e.g., `button.go` for button helpers)
- Generated files: suffixed with `_templ.go`

### UI Component Library

The project uses [templui](https://templui.io/) for UI components:
- Configuration in `.templui.json`
- Components: button, dialog, sheet, separator
- Utilities in `utils/templui.go`

### Tailwind CSS

- Use Tailwind utility classes directly in templ files
- Dark mode: use `dark:` prefix with `class="..."` pattern
- Use `class={}` syntax for conditional/merged classes
- Alpine.js for client-side interactivity (theme switching, dialogs)

### Assets

- Embed CSS/JS with `//go:embed css/*.css js/*.js` in `assets/assets.go`
- Serve from `/assets/` prefix via `http.FileServer(http.FS(assets.Assets))`
- Post files embedded with `//go:embed files/*.md` in `posts/posts.go`

### Environment Variables

| Variable | Purpose | Example |
|----------|---------|---------|
| `ENVIRONMENT` | Set to `dev` for development | `dev` |

## Dependencies

Key dependencies:
- `github.com/a-h/templ` - Templating framework
- `github.com/Oudwins/tailwind-merge-go` - Tailwind class merging
- `github.com/yuin/goldmark` - Markdown to HTML
- `github.com/alecthomas/chroma/v2` - Syntax highlighting

## Development Workflow

1. Enter development shell with `nix develop` (recommended)
2. Edit `.templ` files for UI changes
3. Run `templ generate` to regenerate Go code
4. Use `air` for hot-reload development
5. Test changes in browser at `http://localhost:8080`

## Key Notes

- **Do not edit `*_templ.go` files** - they are auto-generated
- Always run `templ generate` before building or testing
- The project uses server-side rendering with minimal JavaScript
- Markdown posts are stored in `posts/files/*.md` and embedded at compile time
- Nix is the recommended development environment (see flake.nix)
