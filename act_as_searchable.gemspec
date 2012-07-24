$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "act_as_searchable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "act_as_searchable"
  s.version     = ActAsSearchable::VERSION
  s.authors     = ["Troels Knak-Nielsen"]
  s.email       = ["troelskn@gmail.com"]
  s.homepage    = "http://github.com/troelskn/act_as_searchable"
  s.summary     = "Adds a scope for searching in a model."
  s.description = "Adds a scope `search` which provides a full text search as well as options for various switches. Currently only for MySql."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.6"

  s.add_development_dependency "mysql2"
end
