module SimpleCache
  class Reflection::InverseAssociation < Reflection
    class << self
      def add_reflection(klass, method_name)
        r = klass.reflections[method_name.to_s]
        reflections[klass.name.to_sym] ||= []
        reflections[klass.name.to_sym] += [r.class_name, r.foreign_key]
      end
    end
  end
end
