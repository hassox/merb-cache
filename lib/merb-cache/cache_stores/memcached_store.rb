class Merb::Cache::MemcachedStore < Merb::Cache::Store
  
  class NoClient < StandardError
    def initialize
      super "No ruby memcached client was available"
    end
  end
  
  def self.default_config
    @default_config ||= {
      :store => "memcached",
      :host => "127.0.0.1:11211"
    }.freeze
  end
  
  def initialize(config)
    @config = self.class.merge(config)
    connect!
  end
  
  def get(key)
    @memcache.get(key)
  rescue
    return nil
  end
  
  def put(key, value, expiry)
    @memcache.set(key, value, expiry)
  end
  
  def expire(key)
    @memcache.delete(key)
  end
  
  def cached?(key)
    !get(key).nil?
  end
    
  private
  def connect!
    @memcache = Memcached.new(@config[:host])
  rescue NameError
    raise NoClient
  end
end