module Merb
  module Cache
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
      
      # The default path for the controller
    end
  
    module ControllerInstanceMethods
    
      # Get from cache stores
      # Cache stores will all return data or nil
      def get(key, store = :default)
        cached_data = Merb::Cache[store].get(key)
        Merb.logger.info("cache: #{(cached_data.nil?) ? "miss" : "true" }  (#{key})")
        return cached_data 
      end

      # Put, like a HTTP request
      # Its the web kids
      def put(key, data, expiry, store = :default)
        expiry = expiry * 60 # expiry = 1 becomes 60
        Merb::Cache[store].put(key, data, expiry)
        Merb.logger.info("cache: set (#{key})")
      end

      def cached?(key, store = :default)
        Merb::Cache[store].cached?(key)
      end

      def expire!(key, store = :default)
        Merb::Cache[store].expire!(key)
      end
    
    end
  end
end

# Crack open the controller class and include the cache class and instance methods
module Merb
  class Controller
    extend Merb::Cache::ControllerClassMethods
    include Merb::Cache::ControllerInstanceMethods
  end
end