module Merb::Cache
  class AbstractStrategyStore < AbstractStore
    # START: interface for creating strategy stores.  This should/might change.
    def self.contextualize(*stores)
        Class.new(self) do
          cattr_accessor :contextualized_stores

          self.contextualized_stores = stores
        end
      end

      class << self
        alias_method :[], :contextualize
      end

      attr_accessor :stores

      def initialize(config = {})
        @stores = contextualized_stores.map do |cs|
          case cs
          when Symbol
            Merb::Cache[cs]
          when Class
            cs.new(config)
          end
        end
      end

    # END: interface for creating strategy stores.

    attr_accessor :stores

    # determines if the store is able to persist data identified by the key & parameters
    # with the given conditions.
    def writable?(key, parameters = {}, conditions = {})
      raise NotImplementedError
    end

    # gets the data from the store identified by the key & parameters.
    # return nil if the entry does not exist.
    def read(key, parameters = {})
      raise NotImplementedError
    end

    # persists the data so that it can be retrieved by the key & parameters.
    # returns nil if it is unable to persist the data.
    # returns true if successful.
    def write(key, data = nil, parameters = {}, conditions = {})
      raise NotImplementedError
    end

    # persists the data to all context stores.
    # returns nil if none of the stores were able to persist the data.
    # returns true if at least one write was successful.
    def write_all(key, data = nil, parameters = {}, conditions = {})
      raise NotImplementedError
    end

    # tries to read the data from the store.  If that fails, it calls
    # the block parameter and persists the result.
    def fetch(key, parameters = {}, conditions = {}, &blk)
      raise NotImplementedError
    end

    # returns true/false/nil based on if data identified by the key & parameters
    # is persisted in the store.
    def exists?(key, parameters = {})
      raise NotImplementedError
    end

    # deletes the entry for the key & parameter from the store.
    def delete(key, parameters = {})
      raise NotImplementedError
    end

    # deletes all entries for the key & parameters for the store.
    # considered dangerous because strategy stores which call delete_all!
    # on their context stores could delete other store's entrees.
    def delete_all!
      raise NotImplementedError
    end

    def clone
      twin = super
      twin.stores = self.stores.map {|s| s.clone}
      twin
    end
    
  end
end