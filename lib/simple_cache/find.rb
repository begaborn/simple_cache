module SimpleCache
  module Find
    extend ActiveSupport::Concern

    module ClassMethods
      def use_find_cache
        self.add_simple_cache_classses(self.name)

        define_singleton_method(:find_cache) do |id|
          raise 'Invalid Argument(id)' unless id.is_a? Integer
          SimpleCache.cache.fetch(simple_cache_key(id)) do
            find(id)
          end
        end

      end

    end
  end
end
