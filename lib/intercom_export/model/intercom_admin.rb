require 'intercom_export/reference'

require 'virtus'

module IntercomExport
  module Model
    class IntercomAdmin
      include Virtus.value_object

      values do
        attribute :id, Integer
        attribute :name, String
        attribute :email, String
      end

      def reference
        IntercomExport::Reference.new("intercom-admin-#{id}")
      end
    end
  end
end
