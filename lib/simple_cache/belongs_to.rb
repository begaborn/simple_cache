module SimpleCache
  module BelongsTo
    extend ActiveSupport::Concern

    module ClassMethods
      def belongs_to_cached(name, scope = nil, **options)

        belongs_to(name, scope, options)

        return unless SimpleCache.use? options

        r = self.reflections[name.to_s]

        add_simple_cache_classes(r.class_name)

        define_cache_belongs_to(name)
      end

      def use_simple_cache(use = true)
        @use_simple_cache = use
      end

      def use_simple_cache?
        !!@use_simple_cache
      end

      private

      def define_cache_belongs_to(method_name)
        define_method("cached_#{method_name}") do
          @simple_cache_belongs_to ||= {}
          @simple_cache_belongs_to[method_name] ||= begin
            key = self.simple_cache_inverse_association_key(method_name)
            SimpleCache.cache.fetch(key) do
              obj = send(method_name)
              obj.class.find(obj.id)
            end
          end
        end
      end
    end
  end
end
