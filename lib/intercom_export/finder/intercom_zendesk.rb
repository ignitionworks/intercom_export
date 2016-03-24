require 'intercom_export/model/intercom_admin'
require 'intercom_export/model/intercom_user'
require 'intercom_export/model/intercom_conversation'
require 'intercom_export/model/zendesk_ticket'
require 'intercom_export/model/zendesk_user'

module IntercomExport
  module Finder
    class IntercomZendesk
      def initialize(zendesk_client)
        @zendesk_client = zendesk_client
      end

      def find(intercom_source)
        case intercom_source
        when IntercomExport::Model::IntercomUser, IntercomExport::Model::IntercomAdmin
          lookup_zendesk_user(intercom_source)
        when IntercomExport::Model::IntercomConversation
          lookup_zendesk_ticket(intercom_source)
        end
      end

      private

      attr_reader :zendesk_client

      def lookup_zendesk_user(intercom_user)
        IntercomExport::Model::ZendeskUser.new(
          zendesk_client.users.search(query: "email:#{intercom_user.email}").first.to_hash
        )
      end

      def lookup_zendesk_ticket(intercom_ticket)
        IntercomExport::Model::ZendeskTicket.new(
          zendesk_client.tickets.search(query: "external_id:#{intercom_ticket.reference.value}").first.to_hash
        )
      end
    end
  end
end
