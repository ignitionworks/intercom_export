require 'intercom_export/reference'

require 'virtus'

module IntercomExport
  module Model
    class IntercomConversation
      include Virtus.value_object

      values do
        attribute :id, String
        attribute :name, String
        attribute :user
        attribute :assignee
        attribute :conversation_message, Hash[Symbol => Object]
        attribute :created_at
        attribute :updated_at
        attribute :tags
        attribute :open
        attribute :conversation_parts, Array[Hash[Symbol => Object]]
      end

      def reference
        IntercomExport::Reference.new("intercom-conversation-#{id}")
      end
    end
  end
end
