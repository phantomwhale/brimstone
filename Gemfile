source "https://rubygems.org"

ruby "3.4.4"

# Rails 8.0
gem "rails", "~> 8.0.0"

# Database
gem "sqlite3", ">= 2.1"

# Web server
gem "puma", ">= 5.0"

# Rails 8 default gems
gem "propshaft"           # Modern asset pipeline (replaces Sprockets)
gem "importmap-rails"     # JavaScript with ESM import maps
gem "turbo-rails"         # Hotwire SPA-like page accelerator
gem "stimulus-rails"      # Hotwire modest JavaScript framework
gem "tailwindcss-rails"   # Tailwind CSS
gem "jbuilder"            # JSON APIs

# Solid Queue/Cache/Cable - Rails 8 defaults for production-ready setup
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Background job processing
gem "mission_control-jobs"

# Use Active Model has_secure_password
# gem "bcrypt", "~> 3.1.7"

# Windows timezone data
gem "tzinfo-data", platforms: %i[windows jruby]

# Reduces boot times through caching
gem "bootsnap", require: false

# Deploy with Kamal
gem "kamal", require: false

# HTTP asset caching
gem "thruster", require: false

# Use Active Storage variants
# gem "image_processing", "~> 1.2"

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "brakeman", require: false     # Security scanner
  gem "rubocop-rails-omakase", require: false  # Ruby style guide
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end
