module Merb
  # A convinient way to get at Merb::Cache
  def self.cache
    Merb::Cache
  end

  module Cache
    # autoload is used so that gem dependencies can be required only when needed by
    # adding the require statement in the store file.
    autoload :AbstractStore,    "merb-cache" / "stores" / "abstract_store"
    autoload :AdhocStore,       "merb-cache" / "stores" / "adhoc_store"
    autoload :FileStore,        "merb-cache" / "stores" / "file_store"
    autoload :GzipStore,        "merb-cache" / "stores" / "gzip_store"
    autoload :MemcachedStore,   "merb-cache" / "stores" / "memcached_store"
    autoload :SHA1Store,        "merb-cache" / "stores" / "sha1_store"
    autoload :StrategyStore,    "merb-cache" / "stores" / "strategy_store"
    
    class << self
      attr_accessor :stores
    end

    self.stores = {}

    # Cache store lookup
    # name<Symbol> : The name of a registered store
    # Returns<Nil AbstractStore> : A thread-safe copy of the store
    def self.[](*names)
      if names.size == 1
        Thread.current[:'merb-cache'] ||= {}
        (Thread.current[:'merb-cache'][names.first] ||= stores[names.first].clone) 
      else
        AdhocStore[*names]
      end
    rescue TypeError
      raise(StoreNotFound, "Could not find the :#{names.first} store")
    end

    # Clones the cache stores for the current thread
    def self.clone_stores
      @stores.inject({}) {|h, (k, s)| h[k] = s.clone; h}
    end

    # Sets up a cache store
    # name<Symbol> : An optional symbol to give the cache.  :default is used if no name is given.
    # klass<Class> : A store type.
    # opts<Hash> : A hash to pass through to the store for configuration.
    def self.setup(name, klass = nil, opts = {})
      klass, opts = nil, klass if klass.is_a? Hash
      name, klass = default_store_name, name if klass.nil?

      raise StoreExists, "#{name} store already setup" if @stores.has_key?(name)

      @stores[name] = klass.new(opts)
    end

    def self.exists?(name)
      return true if self[name]
    rescue StoreNotFound
      return false
    end

    def self.default_store_name
      :default
    end

    class NotSupportedError < Exception; end
    
    class StoreExists < Exception; end
    
    class StoreNotFound < Exception; end
  end #Cache
end #Merb