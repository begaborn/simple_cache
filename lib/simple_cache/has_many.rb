module SimpleCache
  module HasMany
    extend ActiveSupport::Concern

    module ClassMethods
      def has_many(name, scope = nil, **options, &extension)

        org_options = {}

        if options == {} && scope.is_a?(Hash)
          org_options = scope.dup
          SimpleCache.sanitize(scope) 
        else
          org_options = options.dup
          SimpleCache.sanitize(options) 
        end

        super

        return unless use_cache?(org_options)
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
