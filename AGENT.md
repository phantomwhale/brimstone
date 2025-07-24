# Agent Guidelines for Brimstone

## Commands
- **Start dev server**: `bin/rails server` (or `bin/rails s`)
- **Run tests**: `bin/rails test` (or `bin/rails t`)
- **Run single test**: `bin/rails test test/controllers/heroes_controller_test.rb`
- **Run system tests**: `bin/rails test:system`
- **Database operations**: `bin/rails db:migrate`, `bin/rails db:seed`, `bin/rails db:reset`
- **Generate code**: `bin/rails generate controller Heroes` or `bin/rails g model Hero`
- **Console**: `bin/rails console` (or `bin/rails c`)

## Architecture
- **Framework**: Ruby on Rails 7.0.8 application on Ruby 3.4.4
- **Database**: SQLite3 (development.sqlite3, test.sqlite3, production.sqlite3)
- **Frontend**: Tailwind CSS, Stimulus, Turbo, Importmaps
- **Main resource**: Heroes with extensive attributes (health, sanity, agility, cunning, etc.)
- **Hero classes**: YAML configuration system in config/hero_classes.yml with 30+ predefined character classes
- **Key files**: app/models/hero.rb, app/controllers/heroes_controller.rb, config/routes.rb

## Code Style
- **Ruby**: Follow Rails conventions, snake_case for variables/methods, CamelCase for classes
- **Controllers**: Use before_action filters, strong parameters, respond_to blocks for JSON/HTML
- **Models**: Inherit from ApplicationRecord, use Rails callbacks and validations
- **Testing**: Use Rails test framework with fixtures, parallelize tests, inherit from ActionDispatch::IntegrationTest
- **File organization**: Standard Rails directory structure (app/models, app/controllers, app/views, test/)
- **Configuration**: Use YAML files for data (hero_classes.yml), Rails initializers for app config

## Shadows of Brimtsone
- Shadows of Brimstone is a board game
- This page https://github.com/akavel/awesome-shadows-of-brimstone has lots of links to various other pages with lots of information about the game
