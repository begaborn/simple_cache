module SimpleCache
  module HasOne
    extend ActiveSupport::Concern

    module ClassMethods
      def has_one(name, scope = nil, **options)
        super name, scope, SimpleCache.sanitize(options)
        return unless use_cache?(options)
        add_inverse_reflections(name)
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
