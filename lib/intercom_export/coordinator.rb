module IntercomExport
  class Coordinator

    module EnumeratorLazyUniqParts
      refine Enumerator::Lazy do
        require 'set'
        def uniq
          set = Set.new
          select { |part|
            val = "#{part.class.to_s}-#{part.id}"
            !set.include?(val).tap { |exists| set << val unless exists }
          }
        end
      end
    end

    using EnumeratorLazyUniqParts

    def initialize(source:, splitter:, finder:, differ:, executor:)
      @source = source
      @splitter = splitter
      @finder = finder
      @differ = differ
      @executor = executor
    end

    def run
      source.lazy.flat_map { |source|
        splitter.split(source)
      }.uniq.map { |source_object|
        [source_object, finder.find(source_object)]
      }.map { |source_object, remote_object|
        differ.diff(source_object, remote_object)
      }.each { |commands|
        executor.call(commands)
      }
    end

    private

    attr_reader :source, :finder, :splitter, :differ, :executor
  end
end




