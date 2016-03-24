require 'spec_helper'
require 'intercom_export/finder/intercom_zendesk'
require 'intercom_export/model/intercom_admin'
require 'intercom_export/model/intercom_user'
require 'intercom_export/model/intercom_conversation'

require 'zendesk_api'

RSpec.describe IntercomExport::Finder::IntercomZendesk do

  let(:zendesk_client) { double(ZendeskAPI::Client) }

  subject { IntercomExport::Finder::IntercomZendesk.new(zendesk_client) }

  describe '#find' do
    let(:zendesk_user_collection) { double(ZendeskAPI::Collection) }
    let(:zendesk_ticket_collection) { double(ZendeskAPI::Collection) }
    let(:expected_zendesk_user) { ZendeskAPI::User.new(nil, id: 123) }
    let(:expected_zendesk_ticket) { ZendeskAPI::Ticket.new(nil, id: 456) }

    before do
      allow(zendesk_client).to receive(:users).and_return(zendesk_user_collection)
      allow(zendesk_client).to receive(:tickets).and_return(zendesk_ticket_collection)
    end

    context 'for an intercom admin' do
      context 'when result exists' do
        it 'looks up using their email' do
          allow(zendesk_user_collection).to receive(:search).with(query: 'email:theo@example.com')
            .and_return([expected_zendesk_user])

          result = subject.find(IntercomExport::Model::IntercomAdmin.new('email' => 'theo@example.com'))
          expect(result).to eq(IntercomExport::Model::ZendeskUser.new(id: 123))
        end
      end
      context 'when result does not exist' do
        it 'returns nil' do
          allow(zendesk_user_collection).to receive(:search).with(query: 'email:theo@example.com')
            .and_return([])

          result = subject.find(IntercomExport::Model::IntercomAdmin.new('email' => 'theo@example.com'))
          expect(result).to be_nil
        end
      end
    end

    context 'for an intercom user' do
      context 'when result exists' do
        it 'looks up using their email' do
          allow(zendesk_user_collection).to receive(:search).with(query: 'email:theo@example.com')
            .and_return([expected_zendesk_user])

          result = subject.find(IntercomExport::Model::IntercomUser.new('email' => 'theo@example.com'))
          expect(result).to eq(IntercomExport::Model::ZendeskUser.new(id: 123))
        end
      end
      context 'when result does not exist' do
        it 'returns nil' do
          allow(zendesk_user_collection).to receive(:search).with(query: 'email:theo@example.com')
            .and_return([])

          result = subject.find(IntercomExport::Model::IntercomUser.new('email' => 'theo@example.com'))
          expect(result).to be_nil
        end
      end
    end

    context 'for an intercom conversation' do
      context 'when result exists' do
        it 'looks up using the external id' do
          allow(zendesk_ticket_collection).to receive(:search).with(
            query: 'external_id:intercom-conversation-123'
          ).and_return([expected_zendesk_ticket])

          result = subject.find(IntercomExport::Model::IntercomConversation.new('id' => '123'))
          expect(result).to eq(IntercomExport::Model::ZendeskTicket.new(id: 456))
        end
      end
      context 'when result does not exist' do
        it 'returns nil' do
          allow(zendesk_ticket_collection).to receive(:search).with(
            query: 'external_id:intercom-conversation-123'
          ).and_return([])

          result = subject.find(IntercomExport::Model::IntercomConversation.new('id' => '123'))
          expect(result).to be_nil
        end
      end
    end
  end
end
