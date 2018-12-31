module SimpleCache
  class Reflection::Association < Reflection
    class << self
      def add_reflection(klass, method_name)
        r = klass.reflections[method_name.to_s]
        reflections[r.klass.name.to_sym] ||= {}
        reflections[r.klass.name.to_sym][klass.name.to_sym] ||= []
        reflections[r.klass.name.to_sym][klass.name.to_sym] += [{
          method_name: method_name,
          foreign_key: r.foreign_key.to_sym
        }]
      end
    end
  end
end
