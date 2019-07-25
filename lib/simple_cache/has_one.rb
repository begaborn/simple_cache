module SimpleCache
  module HasOne
    extend ActiveSupport::Concern

    module ClassMethods
      def has_one_cached(name, scope = nil, **options)

        org_options = SimpleCache.sanitize(scope, options)

        super

        return unless SimpleCache.use?(org_options)

        SimpleCache::Reflection::Association.add_reflection(self, name)
        define_cache_method_for_one_to_one(name, options)
      end

      private

      def define_cache_method_for_one_to_one(method_name, **options)
        define_method(method_name) do
          self.cache_association_model(method_name) do
            super()
          end
        end
      end
    end
  end
end
