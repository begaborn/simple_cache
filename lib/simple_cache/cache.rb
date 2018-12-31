module SimpleCache
  class Cache
    def read(key)
      SimpleCache.logger.debug "[SimpleCache] read #{key}"
      SimpleCache.store.read(key)
    end

    def write(key, obj)
      SimpleCache.logger.debug "[SimpleCache] write #{key}"
      SimpleCache.store.write(key, obj, expires_in: SimpleCache.expires_in)
    end

    def fetch(key, &block)
      cached_obj = read(key)
      if cached_obj.nil?
        SimpleCache.logger.debug "[SimpleCache] miss #{key}"

        # Address an issue that cause TypeError when caching the association model in RABL.
        obj = block.call
        write(key, obj)
        obj
      elsif cached_obj == SimpleCache::LOCK_VAL
        block.call
      else
        cached_obj
      end
    end

    def delete(key)
      SimpleCache.logger.debug "[SimpleCache] delete #{key}"
      SimpleCache.store.delete(key)
    end

    def lock(key)
      SimpleCache.logger.debug "[SimpleCache] lock #{key}"
      SimpleCache.store.write(key, SimpleCache::LOCK_VAL, expires_in: 2.minutes)
    end

    def lock_associations_of(base_class)
      keys = []
      cached_associations_of(base_class) do |obj, method_name|
        key = obj.simple_cache_association_key(method_name)
        keys << key
        lock(key)
      end
      keys
    end

    def lock_inverse_associations_of(base)
      r = SimpleCache::Reflection::InverseAssociation.reflections[base.class.name.to_sym] || []
      r.each_with_object([]) do |model_name, keys|
        binding.pry if model_name == 'CreditCard'
        key = base.simple_cache_inverse_association_key(model_name)
        keys << key
        lock(key)
      end
    end

    def delete_all(keys)
      keys.each do |key|
        delete(key)
      end
    end

    private

    def cached_associations_of(base)
      locked_cache_model = []
      r = Reflection::Association.reflections[base.class.name.to_sym] || []
      r.each do |a_kls, arr|
        arr.each do |e|
          foreign_key = base.id.nil? ? e[:foreign_key] : "#{e[:foreign_key]}_was"
          target_model = a_kls.to_s.safe_constantize.find_by(id: base.send(foreign_key))
          next if target_model.nil?
          locked_cache_model += [{model: target_model, method_name: e[:method_name]}]
          yield(target_model, e[:method_name])
        end
      end
      locked_cache_model
    end
  end
end