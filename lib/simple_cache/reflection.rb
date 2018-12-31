module SimpleCache
  class Reflection
    class << self
      def reflections
        @reflections ||= {}
      end
    end
  end
end
