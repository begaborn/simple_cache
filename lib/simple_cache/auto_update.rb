module SimpleCache
  module AutoUpdate
    extend ActiveSupport::Concern

    def included(klass)
      klass.extend ClassMethods
    end

    included do
      before_save do |_record|
        self.lock_association_object_cache
        self.lock_self_cache
      end

      before_destroy do |_record|
        self.lock_association_object_cache
        self.lock_self_cache
      end

      after_commit do |_record|
        self.delete_association_object_cache
        self.delete_self_cache
      end
    end

    def lock_self_cache
      self.lock_cache(:find)
    end

    def delete_self_cache
      self.delete_cache(:find)
    end

    def lock_association_object_cache
      self.class.inverse_reflections.each do |kls, arr|
        arr.each do |e|
          target_model = kls.safe_constantize.find_by(id: self.send("#{e[:foreign_key]}_was"))
          return if target_model.nil?
          self.locked_cache_model += [{model: target_model, name: e[:name]}]
          target_model.lock_cache(e[:name])
        end
      end
    end

    def delete_association_object_cache
      locked_cache_model.each do |e|
        e[:model].delete_cache(e[:name])
      end
      @locked_cache_model = nil
    end

    def locked_cache_model
      @locked_cache_model ||= []
    end

    def locked_cache_model=(arr)
      @locked_cache_model = arr
    end

    module ClassMethods
      def inverse_reflections
        @inverse_reflections ||= {}
      end
    end
  end
end
