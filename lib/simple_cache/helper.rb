module SimpleCache
  class Helper
    attr_reader :kls
    attr_reader :kls_name
    attr_reader :id
    attr_reader :method_name

    def initialize(kls, id, method_name)
        if kls.is_a?(Symbol) || kls.is_a?(String)
          @kls = kls.to_s.constantize
          @kls_name = kls
        else
          @kls = kls
          @kls_name = kls.name.split('::').first.underscore
        end

      @id = id
      @method_name = method_name
    end

    def read
      SimpleCache.store.read(key)
    end

    def write(obj)
      SimpleCache.store.write(key, obj, expires_in: SimpleCache.expires_in)
    end

    def fetch(&block)
      cached_obj = read
      if cached_obj.nil?
        # Address an issue that cause TypeError when caching the association model in RABL.
        begin
          obj = block.call
          Marshal.dump(obj)
          write(obj)
        rescue => ex
          # Reload and store the objects again.
          return kls.find(id).send(method_name)
        end
        obj
      elsif cached_obj == SimpleCache::LOCK_VAL
        block.call
      else
        cached_obj
      end
    end

    def delete
      SimpleCache.store.delete(key)
    end

    def cachable?
      read != SimpleCache::LOCK_VAL
    end

    def lock
      SimpleCache.store.write(key, SimpleCache::LOCK_VAL, expires_in: 2.minutes)
    end

    def lock_associations(base)
      base.class.inverse_reflections.each do |a_kls, arr|
        arr.each do |e|
          target_model = a_kls.safe_constantize.find_by(id: base.send("#{e[:foreign_key]}_was"))
          return if target_model.nil?
          self.locked_cache_model += [{model: target_model, name: e[:name]}]
          SimpleCache.lock(target_model.class, target_model.id, e[:name])
        end
      end
    end

    def delete_associations
      self.locked_cache_model.each do |e|
        SimpleCache.delete(e[:model].class, e[:model].id,  e[:name])
      end
      self.reset_locked_cache_model
    end

    def key
      @cache_key ||= "simple_cache:#{kls_name}.#{id}.#{method_name}"
    end

    def key=(k)
      @cache_key = k
    end

    def locked_cache_model
      @locked_cache_model ||= []
    end

    def locked_cache_model=(arr)
      @locked_cache_model = arr
    end

    def reset_locked_cache_model
      @locked_cache_model = nil
    end
  end

  def self.sanitize(options)
    options.delete(:cache)
    options || {}
  end

  def self.use?(options = {})
    if auto_cache?
      (options[:cache].nil? || options[:cache])
    else
      (options[:cache].present? && options[:cache])
    end && (options.keys & not_allowed_options).size.zero?
  end

  def self.cachable?(kls, id, method_name)
    store.read(key(kls, id, method_name)) != -1
  end

  def self.delete(kls, id, method_name)
    store.delete(key(kls, id, method_name))
  end

  def self.lock(kls, id, method_name)
    store.write(key(kls, id, method_name), -1, expires_in: 2.minutes)
  end

  def self.key(kls, id, method_name)
    "simple_cache:#{kls.name.split('::').first.underscore}.#{id}.#{method_name}"
  end
end
