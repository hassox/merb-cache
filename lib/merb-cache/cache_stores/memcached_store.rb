class Merb::Cache::MemcachedStore < Merb::Cache::Store
  VALID_CONFIG_OPTIONS = %w(store host)
  
  def initialize
  end
end