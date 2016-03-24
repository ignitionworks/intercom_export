require 'spec_helper'
require 'intercom_export/executor/zendesk'
require 'intercom_export/reference'

require 'zendesk_api'

RSpec.describe IntercomExport::Executor::Zendesk do

  let(:zendesk_client) { double('zendesk client') }
  let(:zendesk_collection_users) { double('ZendeskAPI::Collection') }
  let(:zendesk_collection_tickets) { double('ZendeskAPI::Collection') }

  subject { IntercomExport::Executor::Zendesk.new(zendesk_client) }

  before do
    allow(zendesk_client).to receive(:users).and_return(zendesk_collection_users)
    allow(zendesk_client).to receive(:tickets).and_return(zendesk_collection_tickets)
  end

  describe '#call' do
    context 'for users' do
      it 'creates a new record' do
        expect(zendesk_collection_users).to receive(:create!).with(
          external_id: '123', name: 'Theo', email: 'foo@bar.com'
        ).and_return(ZendeskAPI::User.new(zendesk_client, id: 999))

        subject.call([{
          name: :import_user,
          details: { external_id: '123', name: 'Theo', email: 'foo@bar.com' },
          reference: IntercomExport::Reference.new('123')
        }])
      end
    end

    context 'for tickets' do
      it 'creates a new record' do
        expect(zendesk_collection_users).to receive(:create!).with(
          external_id: '123', name: 'Theo', email: 'foo@bar.com'
        ).and_return(ZendeskAPI::User.new(zendesk_client, id: 999))

        expect(zendesk_collection_tickets).to receive(:import!).with(
          subject: 'This is totally broken',
          requester_id: 999,
          comments: [
            { author_id: 999, value: 'This is a comment' }
          ]
        )

        subject.call([
          {
            name: :import_user,
            details: { external_id: '123', name: 'Theo', email: 'foo@bar.com' },
            reference: IntercomExport::Reference.new('123')
          },
          {
            name: :import_ticket,
            details: {
              subject: 'This is totally broken',
              requester_id: IntercomExport::Reference.new('123'),
              comments: [
                { author_id: IntercomExport::Reference.new('123'), value: 'This is a comment' }
              ]
            }
          }
        ])
      end
    end

    context 'for tickets with existing users' do
      it 'creates a new record' do
        expect(zendesk_collection_tickets).to receive(:import!).with(
          subject: 'This is totally broken',
          requester_id: 998,
          comments: [
            { author_id: 998, value: 'This is a comment' }
          ]
        )

        subject.call([
          {
            name: :reference,
            details: 998,
            reference: IntercomExport::Reference.new('123')
          },
          {
            name: :import_ticket,
            details: {
              subject: 'This is totally broken',
              requester_id: IntercomExport::Reference.new('123'),
              comments: [
                { author_id: IntercomExport::Reference.new('123'), value: 'This is a comment' }
              ]
            }
          }
        ])
      end
    end
  end
end
