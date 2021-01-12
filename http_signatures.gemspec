# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'http_digest_header/version'

Gem::Specification.new do |spec|
  spec.name          = "http_digest_header"
  spec.version       = HttpDigestHeader::VERSION
  spec.authors       = ["Michael Millard"]
  spec.email         = ["mike@livechart.me"]
  spec.summary       = "Create and verify HTTP Digest headers"
  spec.homepage      = "https://github.com"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 5.2"

  spec.add_development_dependency "actionpack", ">= 5.2"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "timecop"
  spec.add_development_dependency "rspec", "~> 3.0"
end
