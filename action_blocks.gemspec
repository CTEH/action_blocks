$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "action_blocks/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "action_blocks"
  s.version     = ActionBlocks::VERSION
  s.authors     = ["J. Hicks", "K. Brandwijk", "A. Avguchenko"]
  s.email       = ["jrhicks@cteh.com"]
  s.homepage    = "https://github.com/CTEH/action_blocks"
  s.summary     = "Ruby On Rails engine for building administrative database-driven applications."
  s.description = "Automates Backend and Frontend Development.  Supports Granular Authorization.  Leverages PostgreSQL for Performance.  Encourages Task Oriented UI"
  s.license     = "MIT"
  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  s.add_dependency "rails", "~> 5.2.0"
end
