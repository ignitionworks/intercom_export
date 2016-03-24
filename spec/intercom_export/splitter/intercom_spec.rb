require 'spec_helper'
require 'intercom_export/splitter/intercom'

require 'intercom'

RSpec.describe IntercomExport::Splitter::Intercom do

  let(:intercom_client) { instance_double(Intercom::Client) }
  let(:intercom_admin_service) { instance_double(Intercom::Service::Admin) }
  let(:intercom_user_service) { instance_double(Intercom::Service::User) }

  subject { IntercomExport::Splitter::Intercom.new(intercom_client) }

  describe '#split' do
    before do
      Intercom::Utils.define_lightweight_class('ConversationMessage')
      Intercom::Utils.define_lightweight_class('ConversationPart')

      allow(intercom_client).to receive(:admins).and_return(intercom_admin_service)
      allow(intercom_client).to receive(:users).and_return(intercom_user_service)

      allow(intercom_admin_service).to receive(:all).and_return(intercom_admins_full)
      allow(intercom_user_service).to receive(:find).with(id: '56c186c20655c319400233a4').and_return(
        intercom_user_full
      )
    end

    let(:intercom_user_partial) do
      Intercom::User.new(id: '56c186c20655c319400233a4')
    end

    let(:intercom_user_full) do
      Intercom::User.new(id: '56c186c20655c319400233a4', name: 'Bob', email: 'bob@example.com')
    end

    let(:intercom_admin_partial) do
      Intercom::Admin.new(id: '266817')
    end

    let(:intercom_admins_full) do
      [
        Intercom::Admin.new(id: 1, name: 'Wrong', email: 'wrong@example.com'),
        Intercom::Admin.new(id: 266817, name: 'Theo', email: 'theo@example.com')
      ]
    end

    let(:message) do
      Intercom::Message.new(
        author: intercom_user_partial,
        body: 'I love this site',
        id: '22294826',
        subject: ''
      )
    end

    let(:parts) do
      [
        Intercom::ConversationPart.new(
          assigned_to: intercom_admin_partial,
          attachments: [],
          author: intercom_admin_partial,
          body: 'Yes it is',
          created_at: 1456784671,
          id: '75615723',
          notified_at: 1456784671,
          part_type: 'close',
          updated_at: 1456784671
        ),
        Intercom::ConversationPart.new(
          assigned_to: nil,
          attachments: [],
          author: intercom_user_partial,
          body: 'Thanks',
          created_at: 1456829509,
          id: '75809480',
          notified_at: 1456829509,
          part_type: 'close',
          updated_at: 1456829509
        )
      ]
    end

    let(:conversation) do
      Intercom::Conversation.new(
        id: '2016534877',
        created_at: 1456761281,
        updated_at: 1456829509,
        user: intercom_user_partial,
        assignee: intercom_admin_partial,
        conversation_message: message,
        open: true,
        read: true,
        conversation_parts: parts,
        tags: []
      )
    end

    it 'returns the parts in order they need to be recreated' do
      expect(subject.split(conversation)).to eq([
        IntercomExport::Model::IntercomAdmin.new(
          id: '266817', name: 'Theo', email: 'theo@example.com'
        ),
        IntercomExport::Model::IntercomUser.new(
          id: '56c186c20655c319400233a4', name: 'Bob', email: 'bob@example.com'
        ),
        IntercomExport::Model::IntercomConversation.new(
          id: '2016534877',
          created_at: 1456761281,
          updated_at: 1456829509,
          user: IntercomExport::Reference.new('intercom-user-56c186c20655c319400233a4'),
          assignee: IntercomExport::Reference.new('intercom-admin-266817'),
          conversation_message: {
            author: IntercomExport::Reference.new('intercom-user-56c186c20655c319400233a4'),
            body: 'I love this site',
            id: '22294826',
            subject: ''
          },
          open: true,
          read: true,
          conversation_parts: [
            {
              assigned_to: IntercomExport::Reference.new('intercom-admin-266817'),
              attachments: [],
              author: IntercomExport::Reference.new('intercom-admin-266817'),
              body: 'Yes it is',
              created_at: 1456784671,
              id: '75615723',
              notified_at: 1456784671,
              part_type: 'close',
              updated_at: 1456784671
            },
            {
              assigned_to: nil,
              attachments: [],
              author: IntercomExport::Reference.new('intercom-user-56c186c20655c319400233a4'),
              body: 'Thanks',
              created_at: 1456829509,
              id: '75809480',
              notified_at: 1456829509,
              part_type: 'close',
              updated_at: 1456829509
            }
          ],
          tags: []
        )
      ])
    end
  end
end
