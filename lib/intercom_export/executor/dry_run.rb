module IntercomExport
  module Executor
    class DryRun
      def initialize(listener)
        @listener = listener
      end

      def call(commands)
        commands.each do |c|
          listener.executing c
        end
      end

      private

      attr_reader :listener
    end
  end
end
