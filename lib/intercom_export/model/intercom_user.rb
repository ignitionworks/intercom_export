require 'intercom_export/reference'

require 'virtus'

module IntercomExport
  module Model
    class IntercomUser
      include Virtus.value_object

      values do
        attribute :id, String
        attribute :name, String
        attribute :email, String
      end

      def reference
        IntercomExport::Reference.new("intercom-user-#{id}")
      end
    end
  end
end
