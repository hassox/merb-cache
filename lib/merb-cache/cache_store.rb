class Merb::Cache::Store
  attr_accessor :store, :config
  
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
    @config = self.class.merge(Merb::Plugins.config[:merb_cache] || {})
    unless @config[:disabled]
      load
    else
      Merb.logger.info "Merb cache is disabled"
    end
  end
  
  # get
    # Merb.logger.info("cache: hit miss (#{key})")
  # set
    # Merb.logger.info("cache: set (#{key})")
  
  def cached? key
    @store.cached?(key)
  end
  
  def self.default_config
    @default_config ||= {
      :store => "memcached",
      :host => "127.0.0.1:11211"
    }.freeze
  end
  
  private
  # Require the cache store
  
  def load
    require "merb-cache/cache_stores/#{config[:store]}_store"
    @store = Merb::Cache.const_get(@config[:store].capitalize + "Store").new(@config)
    Merb.logger.debug "Loaded merb-cache using #{@config[:store]}"
  rescue LoadError
    raise NotFound, @config[:store]
  end
  
end