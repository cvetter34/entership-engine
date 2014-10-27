$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "entership_shared/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "entership_shared"
  s.version     = EntershipShared::VERSION
  s.authors     = [""]
  s.email       = [""]
  s.homepage    = "http://entership.net/"
  s.summary     = "Rails engine for EnterShip model."
  s.description = "ActiveRecord model classes for the EnterShip site (shared between site and admin)."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.1.6"
  s.add_dependency "pg"
  s.add_dependency "activesupport"
  s.add_dependency "bcrypt"
  s.add_dependency "kramdown"
  s.add_dependency "country_select"
  s.add_dependency "money-rails"
  s.add_dependency "mini_magick"
  s.add_dependency "fog"
  s.add_dependency "paperclip"
  s.add_dependency "friendly_id"
  s.add_dependency "rails-timeago"
  s.add_dependency "browser"
  s.add_dependency "gretel"
  s.add_dependency "local_time"
end
