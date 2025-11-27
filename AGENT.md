# Agent Guidelines for Brimstone

## Commands
- **Start dev server**: `bin/dev` (runs Rails + Tailwind watcher) or `bin/rails server` (Rails only)
- **Run tests**: `bin/rails test` (or `bin/rails t`)
- **Run single test**: `bin/rails test test/controllers/heroes_controller_test.rb`
- **Run system tests**: `bin/rails test:system`
- **Database operations**: `bin/rails db:migrate`, `bin/rails db:seed`, `bin/rails db:prepare`
- **Generate code**: `bin/rails generate controller Heroes` or `bin/rails g model Hero`
- **Console**: `bin/rails console` (or `bin/rails c`)
- **Background jobs**: `bin/jobs` (runs Solid Queue worker)

## Architecture
- **Framework**: Ruby on Rails 8.0 on Ruby 3.4.4
- **Database**: SQLite3 (stored in `storage/` directory)
- **Asset Pipeline**: Propshaft (modern, zero-config asset serving)
- **Frontend**: Tailwind CSS v4, Stimulus, Turbo, Importmaps
- **Background Jobs**: Solid Queue (database-backed, no Redis needed)
- **Caching**: Solid Cache (database-backed)
- **WebSockets**: Solid Cable (database-backed Action Cable)
- **Main resource**: Heroes with extensive attributes (health, sanity, agility, cunning, etc.)
- **Hero classes**: YAML configuration system in config/hero_classes.yml with 55+ predefined character classes
- **Key files**: app/models/hero.rb, app/controllers/heroes_controller.rb, config/routes.rb

## Code Style
- **Ruby**: Follow Rails conventions, snake_case for variables/methods, CamelCase for classes
- **Controllers**: Use before_action filters, strong parameters, respond_to blocks for JSON/HTML
- **Models**: Inherit from ApplicationRecord, use Rails callbacks and validations
- **Testing**: Use Rails test framework with fixtures, parallelize tests, inherit from ActionDispatch::IntegrationTest
- **File organization**: Standard Rails directory structure (app/models, app/controllers, app/views, test/)
- **Configuration**: Use YAML files for data (hero_classes.yml), Rails initializers for app config

## Frontend Practices (Rails 8 Modern Stack)

### Tailwind CSS v4
- **Version**: Tailwind CSS v4.x (CSS-based configuration, not JS)
- **Primary styling approach**: Use Tailwind utility classes directly in views
- **Custom styles**: `app/assets/stylesheets/application.tailwind.css`
- **Theme configuration**: Use `@theme { }` block in CSS (not tailwind.config.js)
- **Custom utilities**: Use `@utility` directive for custom utilities
- **Component classes**: Write plain CSS classes (not `@layer components`)
- **Build command**: `bundle exec tailwindcss --input app/assets/stylesheets/application.tailwind.css --output app/assets/builds/tailwind.css`

### Tailwind Theme (Western/Brimstone)
Custom colors defined in `@theme { }` block in application.tailwind.css:
- `--color-parchment-*`: Light backgrounds (light, default, dark, border)
- `--color-wood-*`: Dark accents (light, default, dark)
- `--color-gold-*`: Accent/highlight color (light, default, dark)
- `--color-health-*`: Red tones for health UI
- `--color-sanity-*`: Teal tones for sanity UI
- `--color-blood`, `--color-ink`, `--color-leather`: Additional theme colors

Custom fonts:
- `--font-western`: Rye (decorative headers)
- `--font-display`: Cinzel (labels, stats)
- `--font-body`: IM Fell English (body text, inputs)

### Hotwire (Turbo + Stimulus)
- **Turbo Drive**: Enabled by default for fast page navigation
- **Turbo Frames**: Use `<%= turbo_frame_tag %>` for partial page updates
- **Turbo Streams**: Use for real-time updates over WebSockets or after form submissions
- **Stimulus**: JavaScript controllers in `app/javascript/controllers/`
  - Name convention: `hello_controller.js` → `data-controller="hello"`
  - Register in `app/javascript/controllers/index.js`

### Importmaps
- **Configuration**: `config/importmap.rb`
- **No build step**: JavaScript served directly via import maps
- **Pin packages**: `bin/importmap pin <package-name>`
- **Vendor JS**: Place in `vendor/javascript/`

### Propshaft (Asset Pipeline)
- **Replaces Sprockets**: Zero-config asset serving
- **No compilation**: Assets served directly with digest fingerprinting
- **CSS/JS**: Place in `app/assets/` directories
- **Images**: Place in `app/assets/images/`

### View Best Practices
- Use ERB with Tailwind classes for styling
- Prefer inline Tailwind utilities over custom CSS classes
- Use Rails form helpers (`form_with`, `form.label`, `form.text_field`, etc.)
- Use partials for reusable view components
- Keep views semantic with proper HTML5 elements

## Rails 8 Features

### Solid Queue (Background Jobs)
- Database-backed job queue (no Redis required)
- Config: `config/queue.yml`
- Run worker: `bin/jobs`
- Monitor: `/jobs` (Mission Control dashboard)

### Solid Cache
- Database-backed cache store
- Config: `config/cache.yml`
- Enabled in production by default

### Solid Cable (Action Cable)
- Database-backed WebSocket connections
- Config: `config/cable.yml`
- No Redis required for development/production

### Database Configuration
- Primary database: `storage/<env>.sqlite3`
- Cache database: `storage/<env>_cache.sqlite3`
- Queue database: `storage/<env>_queue.sqlite3`
- Cable database: `storage/<env>_cable.sqlite3`

### Health Check
- Endpoint: `/up`
- Returns 200 if app is healthy

## Shadows of Brimstone
- Shadows of Brimstone is a board game
- This page https://github.com/akavel/awesome-shadows-of-brimstone has lots of links to various other pages with lots of information about the game
- Hero sheet reference images in project root: `HeroSheet_Blank_SOBS_Portrait_*.jpg`
