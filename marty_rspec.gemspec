# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'marty_rspec/version'

Gem::Specification.new do |spec|
  spec.name          = "marty_rspec"
  spec.version       = MartyRspec::VERSION
  spec.authors       = ["Masaki Matsuo"]
  spec.email         = 'masaki.matsuo@pnmac.com'
  spec.summary       = "RSpec helper methods for Marty"
  spec.homepage      = "TODO: Put your gem's website or public repo URL here."
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = Dir["{app,config,lib,spec}/**/*", "[A-Z]*"]
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "capybara"
end
