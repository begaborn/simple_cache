module SimpleCache
  module Find
    extend ActiveSupport::Concern

    module ClassMethods
      def find(*args)
        method_name = __method__
        ids = args.flatten.compact.uniq
        return super if ids.size != 1 || block_given? || args.first.kind_of?(Array)

        id = ids.first
        return super unless cachable?(id, method_name)

        SimpleCache.store.fetch(cache_key_by(id, method_name), expires_in: SimpleCache.expires_in) do
          super
        end
      end
    end
  end
end
