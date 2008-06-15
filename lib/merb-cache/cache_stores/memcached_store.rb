class Merb::Cache::MemcachedStore < Merb::Cache::Store
  
  VALID_CONFIG_EXAMPLE = {
    :store => "memcached",
    :host => "127.0.0.1:11211"
  }
  
  class NoClient < StandardError
    def initialize
      super "No ruby memcached client was available"
    end
  end
  
  def initialize(config)
    @config = config
    connect
  end
  
  def get key
    @memcache.get key
  end
  
  def put key, value, expiry
    @memcache.set key, value, expiry
  end
  
  def expire key
    @memcache.delete key
  end
    
  private
  def connect
    @memcache = Memcached.new(@config[:host])
  rescue NameError
    raise NoClient
  end
end