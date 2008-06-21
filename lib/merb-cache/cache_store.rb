module Merb
  module Cache
    
    class << self
      # Addess to registered stores
      # name<Symbol> : The Name of the store type
      # value<Hash> : Requires a hash with to describe the cache.  See Merb::Cache.register
      def [](name)
        active_stores
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
      
      # === Returns
      # A Hash of registered store types
      def registered_stores
        @registered_stores || Hash.new{|h,k| h[k] = {}}
      end
      
      # Returns a Hash of active stores.
      def active_stores
        @active_stores ||= {}
      end
      
      protected
      def []=(name,value)
        @active_stores[name] = value
      end
          
      def load_store(store)
        require registered_stores[store.to_sym][:path] rescue raise Store::NotFound.new(store)
      end
    end
    
    class Store      
      attr_accessor :config
  
      class NotFound < StandardError
        def initialize store_details
          super "Cache store not found: #{store_details.inspect}"
        end
      end
  
      class BadConfiguration < StandardError
        def initialize valid_config={}
          super "Bad cache store configuration: Valid example \n #{valid_config.inspect}"
        end
      end
  
      def initialize(options = {})
        name = options.fetch(:store_name, :default)
        @config = self.class.default_config.merge(Merb::Plugins.config[:merb_cache] || {})
        unless @config[:disabled]
          Merb::Cache.setup(name, (@config[:store] || :memcached), @config)
        else
          Merb.logger.info "Merb cache is disabled"
        end
      end
  
      def self.default_config
        @default_config ||= {
          :store => :memcached,
          :host => "127.0.0.1:11211"
        }.freeze
      end
      
      def get(key, store = :default)
        raise NotImplmented
      end
      def put(key, data, expiry, store = :default)
        raise NotImplmented
      end
      def cached?(key, store = :default)
        raise NotImplmented
      end
      def expire!(key, store = :default)
        raise NotImplmented
      end
  
    end # Store
  end # Cache
end # Merb