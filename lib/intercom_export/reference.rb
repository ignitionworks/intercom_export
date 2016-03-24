module IntercomExport
  class Reference
    def initialize(value)
      @value = value
    end

    def ==(other)
      other.is_a?(self.class) && value == other.value
    end
    alias_method :eql?, :==

    def hash
      self.value.hash
    end

    attr_reader :value
  end
end
