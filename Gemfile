source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Declare your gem's dependencies in action_blocks.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.

# To use a debugger
# gem 'byebug', group: [:development, :test]

# Needed to run 'rake db:create'
gem 'pg'
gem 'devise'
gem 'devise-jwt'
gem 'faker'
gem 'pry'
gem 'rails-erd', group: :development

group :test do
  # gem 'capybara', '>= 2.15', '< 4.0'
  gem 'factory_bot_rails'
  # gem 'selenium-webdriver'
  # Easy installation and use of chromedriver to run system tests with Chrome
  # gem 'chromedriver-helper'
  gem 'minitest-ci'
  gem 'minitest-reporters'
  gem 'pp_sql'
end
