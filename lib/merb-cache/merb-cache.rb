# Require components
module Merb
  module Cache
    class << self
      # Addess to registered stores
      # name<Symbol> : The Name of the store type
      # value<Hash> : Requires a hash with to describe the cache.  See Merb::Cache.register
      def [](name)
        active_stores
        raise Merb::Cache::Store::NotFound, "Could not find the #{name} cache" unless Merb::Cache::Store === @active_stores[name]
        @active_stores[name]
      end

      # Register a cache store with Merb::Cache
      # name<Symbol> : A label for the cache store
      # options<Hash>: A hash of options
      #   Required Options
      #     :path => "path/to/cache/store"
      #     :class_name => "ClassNameOfStore"
      def register(name, options = {})
        raise ArgumentError, "Requires :path and :class_name options" unless ([:path, :class_name] - options.keys).empty?
        raise Merb::Cache::Store::NotFound, "Missing Store File: #{options[:path]}" unless File.exists?("#{options[:path]}.rb")
        @registered_stores ||= Hash.new{|h,k| h[k] = {}}
        @registered_stores[name.to_sym] = options
      end
  
      # Sets up a cache store 
      # name<Symbol> : A label or name to give the cache
      # store<Symbol> : A registered store type.  By default :memcached, and :mintstore are supported
      # opts<Hash> : A hash to pass through to the store for configuration
      def setup(name, store, opts = {})
        active_stores
        load_store(store)
        @active_stores[name] = self.const_get(registered_stores[store.to_sym][:class_name]).new(opts)
      end
      
      # Removes an active cache store
      # name<Symbol> : A label fot the cache store
      # Returns<Nil CacheStore>
      def remove_active_cache!(name)
        @active_stores.delete(name)
      end
  
      # === Returns
      # A Hash of registered store types
      def registered_stores
        @registered_stores || Hash.new{|h,k| h[k] = {}}
      end
  
      # Returns a Hash of active stores.
      def active_stores
        @active_stores ||= {}
      end
      
      # Sets up the default if it's not present
      def setup_default
        setup(:default, :memcached) unless active_stores[:default]
      end
        
  
      protected
      def []=(name,value)
        @active_stores[name] = value
      end
      
      def load_store(store)
        require registered_stores[store.to_sym][:path] rescue raise Store::NotFound.new(store)
      end
    end # # << self
  end # Cache
end # Merb
