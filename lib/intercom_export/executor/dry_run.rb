module IntercomExport
  module Executor
    class DryRun
      def initialize(stdout:)
        @stdout = stdout
      end

      def call(commands)
        commands.each do |c|
          stdout.puts c.inspect
        end
      end

      private

      attr_reader :stdout
    end
  end
end
