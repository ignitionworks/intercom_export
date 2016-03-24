require 'spec_helper'
require 'intercom_export/cli'
require 'intercom_export/coordinator'

RSpec.describe IntercomExport::Cli do

  let(:coordinator_class) { class_double(IntercomExport::Coordinator) }
  let(:expected_coordinator) { instance_double(IntercomExport::Coordinator) }

  subject do
    IntercomExport::Cli.new(
      'the_program_name',
      [
        '--intercom-app-id', 'foobar',
        '--intercom-api-key', 'asdf',
        '--zendesk-address', 'example.zendesk.com',
        '--zendesk-username', 'admin@example.com',
        '--zendesk-token', 'secret'
      ],
      coordinator_class: coordinator_class
    )
  end

  describe '#run' do
    let(:expected_intercom_client) { instance_double(Intercom::Client) }
    let(:expected_zendesk_client) { instance_double(ZendeskAPI::Client) }
    let(:expected_intercom_conversation_source) {
      instance_double(IntercomExport::Source::IntercomConversations)
    }
    let(:expected_intercom_splitter) { instance_double(IntercomExport::Splitter::Intercom) }
    let(:expected_intercom_zendesk_finder) { instance_double(IntercomExport::Finder::IntercomZendesk) }
    let(:expected_intercom_zendesk_differ) { instance_double(IntercomExport::Differ::IntercomZendesk) }
    let(:expected_zendesk_executor) { instance_double(IntercomExport::Executor::Zendesk) }

    before do
      allow(Intercom::Client).to receive(:new)
        .with(app_id: 'foobar', api_key: 'asdf')
        .and_return(expected_intercom_client)

      allow(ZendeskAPI::Client).to receive(:new)
        .and_return(expected_zendesk_client)

      allow(IntercomExport::Source::IntercomConversations).to receive(:new)
        .with(expected_intercom_client)
        .and_return(expected_intercom_conversation_source)

      allow(IntercomExport::Splitter::Intercom).to receive(:new)
        .with(expected_intercom_client)
        .and_return(expected_intercom_splitter)

      allow(IntercomExport::Finder::IntercomZendesk).to receive(:new)
        .with(expected_zendesk_client)
        .and_return(expected_intercom_zendesk_finder)

      allow(IntercomExport::Differ::IntercomZendesk).to receive(:new)
        .and_return(expected_intercom_zendesk_differ)

      allow(IntercomExport::Executor::Zendesk).to receive(:new)
        .with(expected_zendesk_client, anything)
        .and_return(expected_zendesk_executor)
    end

    it 'takes the arguments and initializes the coordinator' do
      allow(coordinator_class).to receive(:new).with(
        source: expected_intercom_conversation_source,
        splitter: expected_intercom_splitter,
        finder: expected_intercom_zendesk_finder,
        differ: expected_intercom_zendesk_differ,
        executor: expected_zendesk_executor
      ).and_return(expected_coordinator)

      expect(expected_coordinator).to receive(:run)

      subject.run
    end

    context 'when the required arguments arent specified' do
      let(:stderr) { StringIO.new }

      subject do
        IntercomExport::Cli.new(
          'the_program_name', ['--intercom-app-id', 'foobar'],
          stderr: stderr
        )
      end

      it 'prints the help' do
        subject.run

        expect(stderr.tap(&:rewind).read.length).to be > 10
      end
    end
  end
end
