module SimpleCache
  module HasMany
    extend ActiveSupport::Concern

    module ClassMethods
      def has_many_cached(name, scope = nil, **options, &extension)

        has_many(name, scope, options, extension)

        SimpleCache::Reflection::Association.add_reflection(self, name)
        define_cache_method_for_one_to_many(name, options)
      end

      private

      def define_cache_method_for_one_to_many(method_name, **options)
        define_method(method_name) do
          self.cache_association_model(method_name) do
            super().load
          end
        end
      end
    end
  end
end
