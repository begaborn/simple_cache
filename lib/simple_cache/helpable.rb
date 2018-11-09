module SimpleCache
  module Helpable
    extend ActiveSupport::Concern

    class << self
      def included(klass)
        klass.extend ClassMethods
      end
    end

    def cache_association_model(method_name)
      @simple_cache ||= {}
      @simple_cache[method_name.to_sym] ||= SimpleCache.store.fetch(cache_key_by(method_name), expires_in: self.expires_in) do
        yield
      end
    end

    def reload
      remove_instance_variable(:@simple_cache)
      super
    end

    def cache_key_by(method_name) 
      self.class.cache_key_by(self.id, method_name)
    end

    def delete_cache(method_name)
      SimpleCache.store.delete(cache_key_by(method_name))
    end

    def expires_in
      @expires_in ||= (class_eval(SimpleCache.config['expires_in'] || '') || 1.hours)
    end 

    module ClassMethods
      def cache_key_by(id, method_name)
        "simple_cache:#{self.name.split('::').first.underscore}.#{id}.#{method_name}"
      end

      def delete_cache(id, method_name)
        SimpleCache.store.delete(cache_key_by(id, method_name))
      end

      def add_inverse_reflections(name)
        r = reflections[name.to_s]

        unless r.klass.respond_to?(:inverse_reflections)
          logger.warn 'The objects in the cache would not be updated unless SimpleCache::AutoUpdate is included' if logger
          return 
        end
        inverse_reflections = r.klass.inverse_reflections
        inverse_reflections[self.name] ||= [] 
        inverse_reflections[self.name] += [{
          name: name,
          foreign_key: r.foreign_key.to_sym
        }]
      end

      def use_cache?(options = {})
        (options[:cache].nil? || options[:cache]) && 
        (options.keys - allowed_options).size.zero? 
      end

      def allowed_options
        [:class_name, :foreign_key, :dependent, :counter_cache, :auto_save, :extend]
      end
    end
  end
end
