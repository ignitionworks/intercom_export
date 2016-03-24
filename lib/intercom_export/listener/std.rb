module IntercomExport
  module Listener
    class Std
      def initialize(stdout: STDOUT, stderr: STDERR)
        @stdout = stdout
        @stderr = stderr
      end

      def executing(command)
        puts "Importing: #{command.inspect}"
        puts
      end

      private

      attr_reader :stdout, :stderr
    end
  end
end
