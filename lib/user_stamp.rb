module UserStamp
  mattr_accessor :creator_attribute
  mattr_accessor :updater_attribute
  mattr_accessor :current_user_method
  
  def self.creator_assignment_method
    "#{UserStamp.creator_attribute}="
  end
  
  def self.updater_assignment_method
    "#{UserStamp.updater_attribute}="
  end
  
  module ClassMethods
    def user_stamp(*models)
      if Rails::VERSION::STRING.first == '3' || Rails::VERSION::STRING[0] == '3'
        UserStampSweeper.class_eval { observe *models }
      elsif Rails::VERSION::STRING.first == '2' || Rails::VERSION::STRING[0] == '2'
        models.each { |klass| klass.add_observer(UserStampSweeper.instance) }
      else
        raise "UserStamp: Unsupported rails version"
      end
      class_eval { cache_sweeper :user_stamp_sweeper }
    end
  end

end

UserStamp.creator_attribute   = :creator
UserStamp.updater_attribute   = :updater
UserStamp.current_user_method = :current_user

class UserStampSweeper < ActionController::Caching::Sweeper
  def before_validation(record)
    return unless current_user
    
    if record.respond_to?(UserStamp.creator_assignment_method) && record.new_record?
      record.send(UserStamp.creator_assignment_method, current_user)
    end
    
    if record.respond_to?(UserStamp.updater_assignment_method) && record.changed?
      record.send(UserStamp.updater_assignment_method, current_user)
    end
  end
  
  private  
    def current_user
      if controller.respond_to?(UserStamp.current_user_method, true)
        controller.send UserStamp.current_user_method
      end
    end
end

class ActionController::Base
  extend UserStamp::ClassMethods
end
