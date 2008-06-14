class Merb::Cache::Store
  attr_reader :store, :config
  
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
  
  DEFAULT_CONFIG = {
    :store => "memcached",
    :host => "127.0.0.1:11211"
  }.freeze
  
  def initialize
    @config = DEFAULT_CONFIG.merge(Merb::Plugins.config[:merb_cache] || {})
    load unless @config[:disabled]
    Merb.logger.info "Loaded merb-cache using #{@config[:store]}"
  end
  
  private
  # Require the cache store
  
  def load
    require "merb-cache/cache_stores/#{config[:store]}_store"
    @store = Merb::Cache.const_get(@config[:store].capitalize + "Store").new
  rescue LoadError
    raise NotFound, @config[:store]
  end
end