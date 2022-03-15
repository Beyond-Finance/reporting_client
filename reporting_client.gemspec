# frozen_string_literal: true

require_relative 'lib/reporting_client/version'

Gem::Specification.new do |spec|
  spec.name          = 'reporting_client'
  spec.version       = ReportingClient::VERSION
  spec.authors       = ['Ashley Zagorski']
  spec.email         = ['azagorski@beyondfinance.com']

  spec.summary       = 'Consolidation of reporting API calls into a singular gem.'
  spec.description   = 'Consolidates any calls using reporting API into one place.'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'factory_bot'
  spec.add_development_dependency 'faker'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec_junit_formatter'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'webmock'

  spec.add_runtime_dependency 'faraday'
  spec.add_runtime_dependency 'faraday_middleware'
  spec.metadata['rubygems_mfa_required'] = 'true'
end
