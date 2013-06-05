# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rest-more-mad_mimi/version'

Gem::Specification.new do |gem|
  gem.name          = "rest-more-mad_mimi"
  gem.version       = Rest::More::MadMimi::VERSION
  gem.authors       = ["GoodLife", "lulalala"]
  gem.email         = ["mark@goodlife.tw"]
  gem.description   = "Mad Mimi client built with [rest-core][].\n\n[rest-core]: https://github.com/cardinalblue/rest-core"
  gem.summary       = gem.description
  gem.homepage      = 'https://github.com/lulalala/rest-more-mad_mimi'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  if gem.respond_to? :specification_version then
    gem.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      gem.add_runtime_dependency(%q<rest-core>, [">= 2.0.3"])
    else
      gem.add_dependency(%q<rest-core>, [">= 2.0.3"])
    end
  else
    gem.add_dependency(%q<rest-core>, [">= 2.0.3"])
  end

  gem.add_development_dependency 'bacon'
  gem.add_development_dependency 'rr'
  gem.add_development_dependency 'webmock'
end
