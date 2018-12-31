module SimpleCache
  module Find
    extend ActiveSupport::Concern

    module ClassMethods
      def find(*args)
        return super unless @find_method_use_cache

        method_name = __method__
        ids = args.flatten.compact.uniq
        return super if ids.size != 1 || block_given? || args.first.kind_of?(Array)

        SimpleCache.cache.fetch(simple_cache_key(ids.first)) do
          super
        end
      end

      def find_method_use_cache(use)
        @find_method_use_cache = use
      end
    end
  end
end
