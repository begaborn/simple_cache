module SimpleCache
  class Reflection
    class << self
      def reflections
        @reflections ||= {}
      end
    end
  end
end
Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'reflection/*.rb')].each { |f| require f }
