# frozen_string_literal: true

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "ordinalize_full"
  spec.version       = "1.6.0"
  spec.authors       = ["Roger Killer"]
  spec.email         = ["rogerkiller@gmail.com"]
  spec.summary       = "Turns a number into an ordinal string such as primary, secondary, tertiary or 1st, 2nd, 3rd."
  spec.description   = spec.summary
  spec.homepage      = "https://github.com/rkiller/ordinalize_full"
  spec.license       = "MIT"
  spec.metadata      = { "rubygems_mfa_required" => "true" }

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.0"

  spec.add_dependency "i18n", "~> 1.8"
end
