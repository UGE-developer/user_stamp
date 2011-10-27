require 'action_controller'
require 'active_record/observer'

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'user_stamp'

UserStampSweeper.instance

class User
  attr_accessor :id
  
  def initialize(id);
    @id = id
  end
end

class Rails
  class VERSION
    STRING = "2.3.11"
  end
end
