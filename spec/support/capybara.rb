require 'capybara/rspec'
require 'selenium-webdriver'

# Configure Capybara
Capybara.default_max_wait_time = 5

# Register a headless Chrome driver
Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--disable-gpu')
  options.add_argument('--window-size=1920,1080')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Use headless Chrome for JavaScript tests
Capybara.javascript_driver = :selenium_chrome_headless

# Configure server
Capybara.server = :puma, { Silent: true }
