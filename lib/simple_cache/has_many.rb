module SimpleCache
  module HasMany
    extend ActiveSupport::Concern

    module ClassMethods
      def has_many(name, scope = nil, **options, &extension)
        super name, scope, SimpleCache.sanitize(options), &extension
        return unless use_cache?(options)
        add_inverse_reflections(name)
        define_cache_method_for_one_to_many(name, options)
      end

      private 

      def define_cache_method_for_one_to_many(method_name, **options)
        define_method(method_name) do
          self.cache_association_model(method_name) do 
            association_collection_proxy = super() 
            association_collection_proxy.load_target
            association_collection_proxy
          end
        end
      end
    end
  end
end
