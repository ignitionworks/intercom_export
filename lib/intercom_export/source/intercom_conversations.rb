module IntercomExport
  module Source
    class IntercomConversations
      def initialize(client)
        @client = client
      end

      include Enumerable

      def each(&block)
        client.conversations.find_all({}).lazy.map { |c| client.conversations.find(id: c.id) }.each(&block)
      end

      private

      attr_reader :client
    end
  end
end
