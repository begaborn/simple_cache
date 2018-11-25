module SimpleCache
  module AutoUpdate
    extend ActiveSupport::Concern

    def included(klass)
      klass.extend ClassMethods
    end

    included do
      before_save do |_record|
        simple_cache = simple_cache(:find)
        simple_cache.lock_associations(self)
        simple_cache.lock
      end

      before_destroy do |_record|
        simple_cache = simple_cache(:find)
        simple_cache.lock_associations(self)
        simple_cache.lock
      end

      after_commit do |_record|
        simple_cache = simple_cache(:find)
        simple_cache.delete_associations
        simple_cache.delete
      end
    end

    module ClassMethods
      def inverse_reflections
        @inverse_reflections ||= {}
      end
    end
  end
end
