require 'pathname'

ROOT_DIR = Pathname.new('.').expand_path(__dir__)
BIN_DIR = ROOT_DIR.join('bin')
LIB_DIR = ROOT_DIR.join('lib')
SPEC_DIR = ROOT_DIR.join('spec')

$LOAD_PATH.push(LIB_DIR)
require 'intercom_export/version'

Gem::Specification.new do |s|
  s.name        = 'intercom_export'
  s.version     = IntercomExport::VERSION
  s.licenses    = ['MIT']
  s.summary     = 'Export Intercom.io data to Zendesk'
  s.description = 'System to help export Intercom.io conversations into Zendesk tickets'
  s.authors     = ['Theo Cushion']
  s.email       = 'theo@ignition.works'
  s.homepage    = 'https://rubygems.org/gems/intercom_export'

  s.bindir = BIN_DIR.relative_path_from(ROOT_DIR)
  s.executables = Pathname.glob(BIN_DIR.join('*')).map(&:basename).map(&:to_s)
  s.files = [
    BIN_DIR.join('**/*'),
    LIB_DIR.join('**/*.rb'),
    SPEC_DIR.join('**/*')
  ].flat_map { |p| Pathname.glob(p) }.map { |p| p.relative_path_from(ROOT_DIR).to_s }

  s.add_runtime_dependency 'intercom', '~> 3.4.0'
  s.add_runtime_dependency 'zendesk_api', '~> 1.13.0'
  s.add_runtime_dependency 'virtus', '~> 1.0.5'
  s.add_runtime_dependency 'nokogiri', '~> 1.6.7'

  s.add_development_dependency 'rspec', '~> 3.4.0'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rubocop'
end
