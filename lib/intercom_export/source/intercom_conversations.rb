module IntercomExport
  module Source
    class IntercomConversations
      def initialize(client)
        @client = client
      end

      def each
        client.conversations.find_all({}).lazy.map { |c| client.conversations.find(id: c.id) }
      end

      private

      attr_reader :client
    end
  end
end
