class AbstractStore

  def initialize(config = {}); end

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

  alias_method :write_all, :write

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
  def delete_all
    raise NotImplementedError
  end

  alias_method :delete_all!, :delete_all
end