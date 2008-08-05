require 'memcached'

module Merb::Cache
  class MemcachedStore < AbstractStore
    attr_accessor :namespace, :servers, :memcached

    def initialize(config = {})
      @namespace = config[:namespace]
      @servers = config[:servers] || ["127.0.0.1:11211"]

      connect(config)
    end

    def writable?(key, parameters = {}, conditions = {})
      true
    end

    def read(key, parameters = {})
      begin
        @memcached.get(normalize(key, parameters))
      rescue Memcached::NotFound, Memcached::Stored
        nil
      end
    end

    def write(key, data = nil, parameters = {}, conditions = {})
      if writable?(key, parameters, conditions)
        begin
          @memcached.set(normalize(key, parameters), data, expire_time(conditions))
          true
        rescue
          nil
        end
      end
    end

    def fetch(key, parameters = {}, conditions = {}, &blk)
      read(key, parameters) || (writable?(key, parameters, conditions) && write(key, value = blk.call, parameters, conditions) && value)
    end

    def exists?(key, parameters = {})
      begin
        @memcached.get(normalize(key, parameters)) && true
      rescue  Memcached::Stored
        true
      rescue Memcached::NotFound
        nil
      end
    end

    def delete(key, parameters = {})
      begin
        @memcached.delete(normalize(key, parameters))
      rescue Memcached::NotFound
        nil
      end
    end

    def delete_all
      @memcached.flush
    end

    def clone
      twin = super
      twin.memcached = @memcached.clone
      twin
    end

    def connect(config = {})
      @memcached = ::Memcached.new(@servers, config.only(:buffer_requests, :no_block).merge(:namespace => @namespace))
    end

    def normalize(key, parameters = {})
      parameters.empty? ? "#{key}" : "#{key}--#{parameters.to_sha2}"
    end

    def expire_time(conditions = {})
      if t = conditions[:expire_in]
        Time.now + t
      else
        0
      end
    end
  end
end