module SimpleCache
  module Helpable
    extend ActiveSupport::Concern

    def cache_association_model(method_name, &block)
      @association_simple_cache ||= {}
      @association_simple_cache[method_name] ||= begin
        cache_key = simple_cache_association_key(method_name.to_sym)
        begin
          SimpleCache.cache.fetch(cache_key, &block)
        rescue => ex
          # Address an issue that cause TypeError when caching the association model in RABL.
          return self.class.find(id).send(method_name)
        end
      end
    end

    def cache_association_ids(method_name, &block)
      cache_key = "#{simple_cache_association_key(method_name.to_sym)}:ids"
      SimpleCache.cache.fetch(cache_key, &block)
    end

    def reload(*)
      remove_instance_variable(:@association_simple_cache) if @association_simple_cache
      remove_instance_variable(:@simple_cache_belongs_to) if @simple_cache_belongs_to
      super
    end
  end
end
