require 'intercom_export/reference'
require 'intercom_export/model/intercom_conversation'
require 'intercom_export/model/intercom_user'
require 'intercom_export/model/intercom_admin'

module IntercomExport
  module Splitter
    class Intercom
      def initialize(client)
        @client = client
      end

      def split(conversation)
        conversation_hash = flatten(conversation)

        dependencies_for_conversation!(conversation_hash) + [
          IntercomExport::Model::IntercomConversation.new(conversation_hash)
        ]
      end

      private

      attr_reader :client

      def flatten(conversation)
        hash = conversation.to_hash
        hash['conversation_parts'] = hash.fetch('conversation_parts').map { |p| p.to_hash }
        hash['conversation_message'] = hash.fetch('conversation_message').to_hash
        hash
      end

      def model_for(object)
        case object
        when ::Intercom::User
          load_user(object)
        when ::Intercom::Admin
          load_admin(object)
        when ::Intercom::NobodyAdmin
          nil
        else
          raise "Unrecognised object #{object.inspect}"
        end
      end

      def load_user(object)
        IntercomExport::Model::IntercomUser.new(client.users.find(id: object.id).to_hash)
      end

      def load_admin(object)
        admin = client.admins.all.find { |a| a.id == Integer(object.id) }
        return unless admin
        IntercomExport::Model::IntercomAdmin.new(admin.to_hash)
      end

      def replace_reference!(hash, key)
        value = hash[key]
        return nil unless value
        model = model_for(value)
        hash[key] = model && model.reference
        model
      end

      def dependencies_for_conversation!(conversation_hash)
        dependencies = []

        conversation_hash['conversation_parts'] = conversation_hash.fetch('conversation_parts').select { |p|
          p.fetch('body', nil)
        }.map { |part|
          dependencies.push(replace_reference!(part, 'assigned_to'))
          dependencies.push(replace_reference!(part, 'author'))
          part
        }

        dependencies.push(replace_reference!(conversation_hash, 'user'))
        dependencies.push(replace_reference!(conversation_hash, 'assignee'))
        dependencies.push(replace_reference!(conversation_hash.fetch('conversation_message'), 'author'))
        dependencies.compact.uniq
      end
    end
  end
end
