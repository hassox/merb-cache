class Merb::Cache
  module ControllerClassMethods
    
    def cache_action(action)
      raise NotImplmented
#      Merb::Cache::Store.put(Merb::Cache.key_for(action)) unless cached_action?(action)
    end
    
    # Pure convenience
    def cache_actions(actions)
      raise NotImplmented
      # actions.each do |action|
      #   action.expire_action(action)
      # end
    end
    
    def cached_action?(action)
      raise NotImplmented
      # Merb::Cache::Store.get(Merb::Cache.key_for(action)).nil?
    end
    
    def expire_action
      raise NotImplemented
    end
    
    # Pure convenience
    def expire_actions(actions)
      raise NotImplmented
      # actions.each do |action|
      #   action.expire_action(action)
      # end
    end
  end
  
  module ControllerInstanceMethods
  end
end

# Crack open the controller class and include the cache class and instance methods
module Merb
  class Controller
    class << self
      include Merb::Cache::ControllerClassMethods
    end
    include Merb::Cache::ControllerInstanceMethods
  end
end