module SimpleCache
  module HasMany
    extend ActiveSupport::Concern

    module ClassMethods
      def has_many_cached(name, scope = nil, **options, &extension)

        has_many(name, scope, options, &extension)

        return unless SimpleCache.use? options

        SimpleCache::Reflection::Association.add_reflection(self, name)
        define_cache_method_for_one_to_many(name)
      end

      private

      def define_cache_method_for_one_to_many(method_name, **options)
        define_method("cached_#{method_name}") do
          self.cache_association_model(method_name) do
            send(method_name).load
          end
        end

        define_method("cached_#{method_name.to_s.singularize}_ids") do
          self.cache_association_ids(method_name) do
            send("#{method_name.to_s.singularize.to_s}_ids")
          end
        end
      end
    end
  end
end
