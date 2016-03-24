require 'virtus'

module IntercomExport
  module Model
    class ZendeskTicket
      include Virtus.value_object

      values do
        attribute :id, Integer
        attribute :url, String
        attribute :external_id, String
        attribute :type, String
        attribute :subject, String
        attribute :raw_subject, String
        attribute :description, String
        attribute :priority, String
        attribute :status, String
        attribute :recipient, String
        attribute :requester_id, Integer
        attribute :submitter_id, Integer
        attribute :assignee_id, Integer
        attribute :organization_id, Integer
        attribute :group_id, Integer
        attribute :collaborator_ids, Array
        attribute :forum_topic_id, Integer
        attribute :problem_id, Integer
        attribute :has_incidents, Boolean
        attribute :due_at, Time
        attribute :tags, Array
        attribute :via
        attribute :custom_fields, Array
        attribute :satisfaction_rating
        attribute :sharing_agreement_ids, Array
        attribute :followup_ids, Array
        attribute :ticket_form_id, Integer
        attribute :brand_id, Integer
        attribute :created_at, Time
        attribute :updated_at, Time
      end
    end
  end
end
