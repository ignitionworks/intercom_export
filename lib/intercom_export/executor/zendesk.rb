module IntercomExport
  module Executor
    class Zendesk
      ReferenceResult = Struct.new(:id)

      def initialize(client, listener=nil)
        @client = client
        @listener = listener
        @references = {}
      end

      def call(commands)
        commands.each do |command|
          executing(command)
          details = resolve_reference(command.fetch(:details))
          result = case command.fetch(:name)
          when :reference
            ReferenceResult.new(details)
          when :import_user
            import_user(details)
          when :import_ticket
            import_ticket(details)
          end
          save_reference(command[:reference].value, result.id) if command.fetch(:reference, nil)
        end
      end

      private

      attr_reader :client, :references, :listener

      def import_user(details)
        client.users.create!(details)
      end

      def import_ticket(details)
        client.tickets.import!(details)
      end

      def save_reference(local_id, remote_id)
        references[local_id] = remote_id
      end

      def deep_resolve_references(details)
        details.each do |key, value|
          resolved_value = resolve_reference(value)
          details[key] = resolved_value unless resolved_value === value
        end
      end

      def executing(command)
        return unless listener
        listener.executing(command)
      end

      def resolve_reference(value)
        case value
        when Hash
          deep_resolve_references(value)
        when Array
          value.map { |v| resolve_reference(v) }
        when Reference
          references.fetch(value.value)
        else
          value
        end
      end
    end
  end
end
