module SimpleCache
  module Find
    extend ActiveSupport::Concern

    module ClassMethods
      def find_cache(id)
        raise 'Invalid Argument(id)' unless id.is_a? Integer
        SimpleCache.cache.fetch(simple_cache_key(id)) do
          find(id)
        end
      end
    end
  end
end
