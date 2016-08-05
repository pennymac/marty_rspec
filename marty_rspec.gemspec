# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'marty_rspec/version'

Gem::Specification.new do |spec|
  spec.name          = "marty_rspec"
  spec.version       = MartyRSpec::VERSION
  spec.authors       = ["Masaki Matsuo"]
  spec.email         = 'masaki.matsuo@pnmac.com'
  spec.summary       = "RSpec helper methods for Marty"
  spec.homepage      = "https://github.com/pennymac/marty_rspec"
  spec.license       = "MIT"

  spec.files         = Dir["{app,config,lib,spec}/**/*", "[A-Z]*"]
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "capybara"
  spec.add_runtime_dependency "rspec-by"
end
