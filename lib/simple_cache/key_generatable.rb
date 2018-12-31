module SimpleCache
  module KeyGeneratable
    extend ActiveSupport::Concern

    module ClassMethods
      def simple_cache_key(id)
        "#{SimpleCache.cache_namespace}:#{name}:#{id}"
      end
    end

    def simple_cache_key
      self.class.simple_cache_key(id)
    end

    def simple_cache_association_key(method_name)
      "#{SimpleCache.cache_namespace}:#{self.class.name}:#{id}:ass:#{method_name}"
    end

    def simple_cache_inverse_association_key(method_name)
      r = self.class.reflections[method_name.to_s]
      "#{SimpleCache.cache_namespace}:#{r.class_name}:#{self.send(r.foreign_key)}"
    end
  end
end
