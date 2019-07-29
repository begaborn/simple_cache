module SimpleCache

  LOCK_VAL = -1
  mattr_accessor :cache_namespace
  self.cache_namespace = "SC:#{CACHE_VERSION}".freeze

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
        obj = block.call
        klass = obj.class
        if klass < Array
          write(key, obj)
        end
        obj
      elsif cached_obj == SimpleCache::LOCK_VAL
        SimpleCache.logger.debug "[SimpleCache] locking #{key}"
        block.call
      else
        begin
          if cached_obj.is_a? Array
            cached_obj
          else
            SimpleCache.logger.debug "[SimpleCache] invalid objest #{key}"
            obj = block.call
            klass = obj.class
            if klass < Array
              write(key, obj)
            end
            obj
          end
        rescue => e
          SimpleCache.logger.debug "[SimpleCache] failed to fetch #{key}"
          obj = block.call
          write(key, m_obj)
          klass = obj.class
          if klass < Array
            write(key, obj)
          end
          obj
        end
      end
    end

    def delete(key)
      SimpleCache.logger.debug "[SimpleCache] delete #{key}"
      SimpleCache.store.delete(key)

      SimpleCache.logger.debug "[SimpleCache] delete #{key}:ids"
      SimpleCache.store.delete("#{key}:ids")
    end

    def lock(key)
      SimpleCache.logger.debug "[SimpleCache] lock #{key}"
      SimpleCache.store.write(key, SimpleCache::LOCK_VAL, expires_in: 2.minutes)

      SimpleCache.logger.debug "[SimpleCache] lock #{key}:ids"
      SimpleCache.store.write("#{key}:ids", SimpleCache::LOCK_VAL, expires_in: 2.minutes)
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
