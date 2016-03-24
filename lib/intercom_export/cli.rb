require 'optparse'
require 'intercom'
require 'zendesk_api'

require 'intercom_export/coordinator'
require 'intercom_export/differ/intercom_zendesk'
require 'intercom_export/executor/zendesk'
require 'intercom_export/executor/dry_run'
require 'intercom_export/finder/intercom_zendesk'
require 'intercom_export/source/intercom_conversations'
require 'intercom_export/splitter/intercom'
require 'intercom_export/listener/std'

module IntercomExport
  class Cli
    def initialize(
      program_name,
      argv,
      coordinator_class: IntercomExport::Coordinator,
      stdout: STDOUT,
      stderr: STDERR
    )
      @program_name = program_name
      @argv = argv
      @coordinator_class = coordinator_class
      @stdout = stdout
      @stderr = stderr
    end

    def run
      coordinator_class.new(
        source: IntercomExport::Source::IntercomConversations.new(intercom_client),
        splitter: IntercomExport::Splitter::Intercom.new(intercom_client),
        finder: IntercomExport::Finder::IntercomZendesk.new(zendesk_client),
        differ: IntercomExport::Differ::IntercomZendesk.new,
        executor: executor
      ).run
    rescue KeyError
      stderr.puts options_parser
    end

    private

    attr_reader :coordinator_class, :argv, :program_name, :stdout, :stderr

    def listener
      @listener ||= IntercomExport::Listener::Std.new(stdout: stdout, stderr: stderr)
    end

    def executor
      if options.fetch(:dry_run, false)
        IntercomExport::Executor::DryRun.new(listener)
      else
        IntercomExport::Executor::Zendesk.new(zendesk_client, listener)
      end
    end

    def zendesk_client
      @zendesk_client ||= ZendeskAPI::Client.new do |c|
        c.url = "https://#{options.fetch(:zendesk_address)}/api/v2"
        c.username = options.fetch(:zendesk_username)
        c.token = options.fetch(:zendesk_token)
      end
    end

    def intercom_client
      @intercom_client ||= Intercom::Client.new(
        api_key: options.fetch(:intercom_api_key),
        app_id: options.fetch(:intercom_app_id)
      )
    end

    def options
      # If a method has side-effects but no one can see it - is it really a query?
      @options ||= begin
        @opts = {}
        options_parser.parse(argv)
        @opts
      end
    end

    def options_parser
      @options_parser ||= OptionParser.new do |opts|
        opts.banner = "Usage: #{program_name} [options]"

        options_intercom(opts)
        options_zendesk(opts)
        options_generic(opts)
      end
    end

    def options_generic(opts)
      opts.on('-d', '--dry-run') do
        @opts[:dry_run] = true
      end

      opts.on('-h', '--help') do
        stderr.puts opts
      end
    end

    def options_intercom(opts)
      opts.on('--intercom-app-id APP_ID', 'Intercom App Id') do |v|
        @opts[:intercom_app_id] = v
      end

      opts.on('--intercom-api-key API_KEY', 'Intercom API Key') do |v|
        @opts[:intercom_api_key] = v
      end
    end

    def options_zendesk(opts)
      opts.on('--zendesk-address ADDRESS', 'Zendesk address e.g. example.zendesk.com') do |v|
        @opts[:zendesk_address] = v
      end

      opts.on('--zendesk-username USERNAME', 'Zendesk username e.g. admin@example.com') do |v|
        @opts[:zendesk_username] = v
      end

      opts.on('--zendesk-token TOKEN', 'Zendesk token') do |v|
        @opts[:zendesk_token] = v
      end
    end
  end
end
