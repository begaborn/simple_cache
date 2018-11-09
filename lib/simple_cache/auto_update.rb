module SimpleCache
  module AutoUpdate 
    extend ActiveSupport::Concern

    def included(klass)
      klass.extend ClassMethods
    end

    included do
      after_commit do |record|
        self.delete_object_cache(record)
      end
    end 

    def delete_object_cache(record)
      record.class.inverse_reflections.each do |kls, arr|
        arr.each do |e|
          target_model = kls.safe_constantize.find_by(id: record.send(e[:foreign_key]))
          return if target_model.nil?
          target_model.delete_cache(e[:name])
        end
      end
    end

    module ClassMethods
      def inverse_reflections
        @inverse_reflections ||= {}
      end      
    end
  end
end
