require 'spec_helper'
require 'intercom_export/differ/intercom_zendesk'
require 'intercom_export/model/zendesk_user'
require 'intercom_export/model/zendesk_ticket'


RSpec.describe IntercomExport::Differ::IntercomZendesk do

  describe '#diff' do
    context 'when comparing tickets' do
      context 'when the remote object does not exist' do
        it 'returns the commands' do
          expect(
            subject.diff(
              IntercomExport::Model::IntercomConversation.new(
                id: '4347072250',
                created_at: 1458220933,
                updated_at: 1458290738,
                user: IntercomExport::Reference.new('someuser'),
                assignee: IntercomExport::Reference.new('someadmin'),
                open: false,
                read: true,
                tags: ['foo'],
                conversation_message: {
                  id: '23964139',
                  subject: '<p>Register</p>',
                  body: '<p>Sorry but Ive got to go</p>',
                  author: IntercomExport::Reference.new('someuser'),
                  attachments: []
                },
                conversation_parts: [
                  {
                    id: '82997204',
                    part_type: 'close',
                    body: '<p>Hello<br>There</p><p>Help</p>',
                    created_at: 1458221859,
                    updated_at: 1458221859,
                    notified_at: 1458221859,
                    assigned_to: IntercomExport::Reference.new('someadmin'),
                    author: IntercomExport::Reference.new('someadmin'),
                    attachments: []
                  },
                  {
                    id: '83193198',
                    part_type: 'comment',
                    body: '<p>Please fix this</p>',
                    created_at: 1458241272,
                    updated_at: 1458241272,
                    notified_at: 1458241272,
                    assigned_to: nil,
                    author: IntercomExport::Reference.new('someuser'),
                    attachments: []
                  },
                  {
                    id: '83405663',
                    part_type: 'note',
                    body: '<p>Done</p>',
                    created_at: 1458290721,
                    updated_at: 1458290721,
                    notified_at: 1458290721,
                    assigned_to: nil,
                    author: IntercomExport::Reference.new('someadmin'),
                    attachments: []
                  }
                ]
              ),
              nil
            )
          ).to eq([
            {
              name: :import_ticket,
              details: {
                external_id: 'intercom-conversation-4347072250',
                tags: ['foo'],
                status: 'closed',
                requester_id: IntercomExport::Reference.new('someuser'),
                assignee_id: IntercomExport::Reference.new('someadmin'),
                subject: 'Register',
                comments: [
                  {
                    author_id: IntercomExport::Reference.new('someuser'),
                    html_body: '<p>Sorry but Ive got to go</p>',
                    created_at: '2016-03-17T13:22:13Z'
                  },
                  {
                    author_id: IntercomExport::Reference.new('someadmin'),
                    value: "Hello\nThere\n\nHelp",
                    public: true,
                    created_at: '2016-03-17T13:37:39Z'
                  },
                  {
                    author_id: IntercomExport::Reference.new('someuser'),
                    value: 'Please fix this',
                    public: true,
                    created_at: '2016-03-17T19:01:12Z'
                  },
                  {
                    author_id: IntercomExport::Reference.new('someadmin'),
                    value: 'Done',
                    public: false,
                    created_at: '2016-03-18T08:45:21Z'
                  }
                ],
                created_at: '2016-03-17T13:22:13Z',
                updated_at: '2016-03-18T08:45:38Z',
              }
            }
          ])
        end
      end

      context 'when the remote object exists' do
        it 'returns no commands' do
          expect(
            subject.diff(
              IntercomExport::Model::IntercomConversation.new,
              IntercomExport::Model::ZendeskTicket.new
            )
          ).to eq([])
        end
      end
    end

    context 'when comparing users' do
      context 'when the remote object does exist' do
        it 'returns the correct commands' do
          expect(
            subject.diff(
              IntercomExport::Model::IntercomUser.new(
                id: 123, name: 'Theo', email: 'theo@example.com'
              ),
              IntercomExport::Model::ZendeskUser.new(
                id: 999, name: 'Theo', email: 'theo@example.com'
              )
            )
          ).to eq([
            {
              name: :reference,
              details: 999,
              reference: IntercomExport::Reference.new('intercom-user-123')
            }
          ])
        end
      end

      context 'when the remote object does not exist' do
        it 'returns the correct commands' do
          expect(
            subject.diff(
              IntercomExport::Model::IntercomUser.new(
                id: 123, name: 'Theo', email: 'theo@example.com'
              ),
              nil
            )
          ).to eq([
            {
              name: :import_user,
              details: { external_id: 'intercom-user-123', name: 'Theo', email: 'theo@example.com' },
              reference: IntercomExport::Reference.new('intercom-user-123')
            }
          ])
        end

        it 'copes with missing name the correct commands' do
          expect(
            subject.diff(
              IntercomExport::Model::IntercomUser.new(
                id: 1, name: nil, email: 't@example.com'
              ),
              nil
            )
          ).to eq([
            {
              name: :import_user,
              details: { external_id: 'intercom-user-1', name: 't@example.com', email: 't@example.com' },
              reference: IntercomExport::Reference.new('intercom-user-1')
            }
          ])
        end
      end
    end

    context 'when comparing admins' do
      context 'when the remote object does exist' do
        it 'returns the correct commands' do
          expect(
            subject.diff(
              IntercomExport::Model::IntercomAdmin.new(
                id: 123, name: 'Theo', email: 'theo@example.com'
              ),
              IntercomExport::Model::ZendeskUser.new(
                id: 999, name: 'Theo', email: 'theo@example.com'
              )
            )
          ).to eq([
            {
              name: :reference,
              details: 999,
              reference: IntercomExport::Reference.new('intercom-admin-123')
            }
          ])
        end
      end

      context 'when the remote object does not exist' do
        it 'returns the correct commands' do
          expect(
            subject.diff(
              IntercomExport::Model::IntercomAdmin.new(
                id: 123, name: 'Theo', email: 'theo@example.com'
              ),
              nil
            )
          ).to eq([
            {
              name: :import_user,
              details: { external_id: 'intercom-admin-123', name: 'Theo', email: 'theo@example.com' },
              reference: IntercomExport::Reference.new('intercom-admin-123')
            }
          ])
        end
      end
    end

  end
end
