module SimpleCache
  module BelongsTo
    extend ActiveSupport::Concern

    module ClassMethods
      def belongs_to(name, scope = nil, **options)

        org_options = {}

        if options == {} && scope.is_a?(Hash)
          org_options = scope.dup
          SimpleCache.sanitize(scope)
        else
          org_options = options.dup
          SimpleCache.sanitize(options)
        end

        super

        return unless SimpleCache.use?(org_options)

        SimpleCache::Helper.add_reflections_for_belongs_to(self.name, name)
        define_cache_belongs_to(name, options)
      end

      private

      def define_cache_belongs_to(method_name, **options)
        define_method(method_name) do
          @simple_cache_belongs_to ||= {}
          @simple_cache_belongs_to[method_name] ||= begin
            r = self.class.reflections[method_name.to_s]
            key = SimpleCache.key(r.class_name.constantize, self.send(r.foreign_key), "has_many.#{self.class.name}")
            cached_objects = SimpleCache.store.read(key)
            if cached_objects.nil?
              cached_objects = super()
              SimpleCache.store.write(key, cached_objects, expires_in: SimpleCache.expires_in)
            end
            cached_objects
          end
        end
      end
    end
  end
end
