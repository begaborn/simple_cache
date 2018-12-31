module SimpleCache
  module BelongsTo
    extend ActiveSupport::Concern

    module ClassMethods
      def belongs_to(name, scope = nil, **options)

        org_options = SimpleCache.sanitize(scope, options)

        super

        return unless SimpleCache.use?(org_options)

        define_cache_belongs_to(name, options)
      end

      private

      def define_cache_belongs_to(method_name, **options)
        define_method(method_name) do
          @simple_cache_belongs_to ||= {}
          @simple_cache_belongs_to[method_name] ||= begin
            key = self.simple_cache_inverse_association_key(method_name)
            SimpleCache.cache.fetch(key) do
              super()
            end
          end
        end
      end
    end
  end
end
