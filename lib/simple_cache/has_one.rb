module SimpleCache
  module HasOne
    extend ActiveSupport::Concern

    module ClassMethods
      def has_one_cached(name, scope = nil, **options)

        has_one(name, scope, options)

        return unless SimpleCache.use? options

        SimpleCache::Reflection::Association.add_reflection(self, name)
        define_cache_method_for_one_to_one(name)
      end

      private

      def define_cache_method_for_one_to_one(method_name)
        define_method("cached_#{method_name}") do
          self.cache_association_model(method_name) do
            send(method_name)
          end
        end
      end
    end
  end
end
