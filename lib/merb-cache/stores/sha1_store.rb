require 'digest/sha1'

module Merb::Cache
  class SHA1Store < StrategyStore
    def initialize(config = {})
      super(config)
      @map = {}
    end

    def writable?(key, parameters = {}, conditions = {})
      case key
      when String, Numeric, Symbol
        @stores.any? {|c| c.writable?(digest(key, parameters), {}, conditions)}
      else nil
      end
    end

    def read(key, parameters = {})
      @stores.capture_first {|c| c.read(digest(key, parameters))}
    end

    def write(key, data = nil, parameters = {}, conditions = {})
      if writable?(key, parameters, conditions)
        @stores.capture_first {|c| c.write(digest(key, parameters), data, {}, conditions)}
      end
    end

    def write_all(key, data = nil, parameters = {}, conditions = {})
      if writable?(key, parameters, conditions)
        @stores.capture_intersection {|c| c.write_all(digest(key, parameters), data, {}, conditions)}
      end
    end

    def fetch(key, parameters = {}, conditions = {}, &blk)
      read(key, parameters) || (writable?(key, parameters, conditions) && @stores.capture_first {|c| c.fetch(digest(key, parameters), {}, conditions, &blk)})
    end

    def exists?(key, parameters = {})
      @stores.capture_first {|c| c.exists?(digest(key, parameters))}
    end

    def delete(key, parameters = {})
      @stores.capture_intersection {|c| c.delete(digest(key, parameters))}
    end

    def delete_all!
      @stores.capture_intersection {|c| c.delete_all! }
    end

    def digest(key, parameters = {})
      @map[[key, parameters]] ||= Digest::SHA1.hexdigest("#{key}#{parameters.to_params}")
    end
  end
end