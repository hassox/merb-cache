module Merb
  module Cache
    class MintcachedStore < Merb::Cache::Store
  
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
        @config = self.class.default_config.merge(config)
        connect
      end
  
      def get(key)
        data = @memcache.get key
        if data.nil?
          mint_cache = @memcached.get_multi "#{key}_validity", "#{key}_data"
          validity_time, data = mint_cache["#{key}_validity"], mint_cache["#{key}_data"]
      
          if !validity_time.nil? and Time.now > validity_time
            Merb.logger.info("stale cache, refreshing")
            # Cache to be set for 60 seconds while its regenerated for the
            # poor soul who gets a cache miss
            @memcache.set key, data, 60
            data = nil
          end
        end
    
        Merb.logger.info("cache: #{data.nil? ? "miss" : "hit"} (#{key})")
        data
      rescue Memcached::NotFound 
        return nil
      end
  
      def put (key, value, expiry =  nil)
        # Regular cache set
        expiry = expiry ? expiry : 0
        @memcache.set key, value, expiry
    
        # Set the data to a seperate key that has a long expiry.
        # When the cache that is set above expires, this one can 
        # steal the show - unless the data really isn't as hot as you'd 
        # like to think it was – Then you're fucked.
        validity_expiry = (expiry * 2) * 60
        @memcache.set("#{key}_validity", (Time.now + expiry), validity_expiry)
        @memcache.set("#{key}_data", value, validity_expiry)
      end
  
      def expire!(key)
        @memcache.delete key
      end
  
      def cached?(key)
        !get(key).nil?
      end
  
      private
      def connect
        @memcache = Memcached.new(@config[:host])
      rescue NameError
        raise NoClient
      end
    end # MintcachedStore
  end # Cache
end # Merb