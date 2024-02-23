# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sower/version'

Gem::Specification.new do |spec|
  spec.name          = "sower"
  spec.version       = Sower::VERSION
  spec.authors       = ["Zachary Belzer"]
  spec.email         = ["zbelzer@gmail.com"]
  spec.summary       = %q{Simple multi format seeder.}
  spec.description   = %q{Given a seeds directory and a file name, it will try to import the most expedient format available.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "csv"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
