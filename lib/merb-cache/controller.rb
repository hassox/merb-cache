module Merb
  module Cache
    module ControllerClassMethods
    
      def cache_action(action, options = {}, &block)
        # Get the filter options
        opts = {}
        [:exclude, :only, :with].each{ |k| r = options.delete(k); opts.merge!(r) if r}
        
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
        before  nil, opts, &b
        after   nil, opts, &a
      end
    
      # Pure convenience
      def cache_actions(*args, &block)
        options = args.pop if Hash === args.last
        options ||= {}
        opts = {}
        [:exclude, :only, :with].each{ |k| r = options.delete(k); opts.merge!(r) if r}
        
        if args.empty?
          unless opts[:exclude]
            args = self.callable_actions
            opts[:only] = args.flatten
          end
        end
      
        # Setup a before filter and after filter
        b = Proc.new do
          _fetch_action_cache(options)
        end
        a = Proc.new do
          _set_action_cache(options)
        end
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