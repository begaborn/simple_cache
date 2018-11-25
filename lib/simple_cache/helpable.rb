require 'simple_cache/helper'

module SimpleCache
  module Helpable
    extend ActiveSupport::Concern

    class << self
      def included(klass)
        klass.extend ClassMethods
      end
    end

    def simple_cache(method_name)
      @simple_cache ||= {}
      @simple_cache[method_name] ||= SimpleCache::Helper.new self.class, self.id, method_name
    end

    def cache_association_model(method_name, &block)
      method_name = method_name.to_sym
      simple_cache = simple_cache(method_name)
      @association_cache ||= {}
      @association_cache[method_name] ||= simple_cache.fetch(&block)
    end

    def reload
      remove_instance_variable(:@association_cache)
      super
    end

    module ClassMethods
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
    end
  end
end
