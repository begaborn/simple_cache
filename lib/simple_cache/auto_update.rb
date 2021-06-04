module SimpleCache
  module AutoUpdate
    extend ActiveSupport::Concern

    included do
      before_save do |_record|
        self.locked_simple_cache_key = SimpleCache.cache.lock_associations_of(self)
        SimpleCache.cache.lock(simple_cache_key) if self.class.simple_cache_classes.include?(self.class.name)
      end

      before_destroy do |_record|
        self.locked_simple_cache_key = SimpleCache.cache.lock_associations_of(self)
        SimpleCache.cache.lock(simple_cache_key) if self.class.simple_cache_classes.include?(self.class.name)
      end

      after_commit do |_record|
        SimpleCache.cache.delete(simple_cache_key) if self.class.simple_cache_classes.include?(self.class.name)
        SimpleCache.cache.delete_all locked_simple_cache_key
        self.reset_locked_simple_cache_key
      end
    end

    def locked_simple_cache_key
      @locked_simple_cache_key ||= []
    end

    def locked_simple_cache_key=(arr)
      @locked_simple_cache_key = arr
    end

    def reset_locked_simple_cache_key
      @locked_simple_cache_key = []
    end
  end
end
