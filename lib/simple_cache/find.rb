module SimpleCache
  module Find
    extend ActiveSupport::Concern

    module ClassMethods
      def find(*args)
        return super if @use_find_cache == false
        method_name = __method__
        ids = args.flatten.compact.uniq
        return super if ids.size != 1 || block_given? || args.first.kind_of?(Array)

        id = ids.first
        simple_cache = SimpleCache::Helper.new self, id, method_name
        return super unless simple_cache.cachable?

        SimpleCache.store.fetch(simple_cache.key, expires_in: SimpleCache.expires_in) do
          super
        end
      end

      def use_find_cache(use = true)
        @use_find_cache = use
      end
    end
  end
end
