require 'pathname'

ROOT_DIR = Pathname.new('..').expand_path(__dir__) unless defined? ROOT_DIR
LIB_DIR = ROOT_DIR.join('lib') unless defined? LIB_DIR

$LOAD_PATH.unshift(LIB_DIR)

RSpec.configure do |config|
  config.order = :random
  config.disable_monkey_patching!

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
end
