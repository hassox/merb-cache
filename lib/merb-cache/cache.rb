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
    autoload :StrategyStore,    "merb-cache" / "stores" / "strategy_store"
    
    class << self
      attr_accessor :stores, :precedence
    end

    self.stores = {}
    self.precedence = []

    # Cache store lookup
    # name<Symbol> : The name of a registered store
    # Returns<Nil AbstractStore> : A thread-safe copy of the store
    def self.[](*names)
      if names.size == 1
        (Thread.current[:'merb-cache'] ||= clone_stores)[names.first]
      else
        AdhocStore[*names]
      end
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
      name, klass = :default, name if klass.nil?

      raise "#{name} store already setup" if @stores.has_key?(name)

      @stores[name] = klass.new(opts)
      @precedence << name unless @precedence.include? name
    end

    def self.read(key, parameters = {}, conditions = {})
      precedence.capture_first {|n| self[n].read(key, parameters, conditions)}
    end

    def self.write(key, data = nil, parameters = {}, conditions = {})
      precedence.capture_first {|n| self[n].write(key, parameters, conditions)}
    end

    def self.write_all(key, data = nil, parameters = {}, conditions = {})
      precedence.capture_intersection {|n| self[n].write()}
    end

    def self.fetch(key, parameters = {}, conditions = {}, &blk)
      precedence.capture_first {|n| self[n].fetch(key, parameters, conditions, &blk)}
    end

    def self.exists?(key, parameters = {})
      precedence.any?{|n| self[n].exists?(key, parameters)}
    end

    def self.delete(key, parameters = {})
      precedence.capture_intersection {|n| self[n].delete(key, parameters)}
    end

    def self.delete_all!
      precedence.capture_intersection {|n| self[n].delete_all!}
    end

    class NotSupportedError < Exception; end
  end #Cache
end #Merb