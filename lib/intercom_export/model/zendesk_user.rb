require 'intercom_export/reference'
require 'virtus'
module IntercomExport
  module Model
    class ZendeskUser
      include Virtus.value_object

      values do
        attribute :id, Integer
        attribute :url, String
        attribute :name, String
        attribute :email, String
        attribute :created_at, Time
        attribute :updated_at, Time
        attribute :time_zone, String
        attribute :phone
        attribute :photo
        attribute :locale_id, Integer
        attribute :locale, String
        attribute :organization_id
        attribute :role, String
        attribute :verified, Boolean
        attribute :external_id
        attribute :tags, Array[String]
        attribute :alias, String
        attribute :active, Boolean
        attribute :shared, Boolean
        attribute :shared_agent, Boolean
        attribute :last_login_at, Time
        attribute :two_factor_auth_enabled
        attribute :signature, String
        attribute :details, String
        attribute :notes, String
        attribute :custom_role_id
        attribute :moderator, Boolean
        attribute :ticket_restriction
        attribute :only_private_comments, Boolean
        attribute :restricted_agent, Boolean
        attribute :suspended, Boolean
        attribute :chat_only, Boolean
        attribute :user_fields, Hash
      end
    end
  end
end
