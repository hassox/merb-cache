module Merb
  module Cache
    module ControllerClassMethods
    
      def cache_action(action, options = {}, &block)
        # Get the filter options
        opts = {}
        opts = normalize_filters!(opts || {})
        
        # setup the options for the before_filter
        opts.delete(:exclude)
        opts[:only] = action
        
        _add_action_cache(action, options, &block)
        
        # Setup a before filter 
        b = Proc.new do
          _fetch_action_cache(options)
        end
        a = Proc.new do
          _set_action_cache(options)
        end
        
        # Using procs so that we can run multiple filters on _fetch_action_cache and _set_action_cache
        before  nil, opts, &b
        after   nil, opts, &a
      end
    
      # Pure convenience
      def cache_actions(*args, &block)
        options = args.pop if Hash === args.last
        options ||= {}
        opts = normalize_filters!(opts || {})
        
        case opts.keys
        when include?(:exclude)
          actions = self.callable_actions - opts[:exclude]        
        when include?(:only)
          actions = opts[:only]
        else
          actions = args.empty? ? self.callable_actions : args.flatten
        end

        # Setup the cache store on the controller
        actions.each{|a| _add_action_cache(action.to_sym, options, &block)}
      
        # Setup a before filter and after filter
        b = Proc.new do
          _fetch_action_cache(options)
        end
        a = Proc.new do
          _set_action_cache(options)
        end
        
        # Using procs so that we can run multiple filters on _fetch_action_cache and _set_action_cache
        before  nil, opts, &b
        after   nil, opts, &a
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
      
      # A place to store the cached actions
      def _action_caches
        @_action_caches ||= Hash.new{|h,k| h[k] = {}}
      end
      
      private
      def _add_action_cache(action, options, &proc)
        self._action_caches[action][:options] = options
        self._action_caches[action][:proc]    = proc
      end
    end
  
    module ControllerInstanceMethods
    
      # Get from cache stores
      # Cache stores will all return data or nil
      def get(key, store = :default)
        Merb.cache.get(key, store)
      end

      # Put, like a HTTP request
      # Its the web kids
      def put(key, data, expiry, store = :default)
        Merb.cache.put(key, data, expiry, store)
      end

      def cached?(key, store = :default)
        Merb.cache.cached?(key,store)
      end

      def expire!(key, store = :default)
        Merb.cache.expire!(key, store)
      end
      
      def expire_action
        raise NotImplmented
      end
      
      def expire_actions
        raise NotImplmented
      end
      
      def cached_action?
        raise NotImplmented
      end
      
      private 
      def _fetch_action_cache(opts = {})
        
      end
      
      def _set_action_cache(opts = {})
        
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