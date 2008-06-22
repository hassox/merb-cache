# make sure we're running inside Merb
if defined?(Merb::Plugins)
  # Deps
  %w(gzip/gzip).each{|dep| require File.join(File.dirname(__FILE__), '..', 'vendor', dep) }
  
  require 'merb-cache/merb-cache'

  require 'merb-cache/controller'
  require 'merb-cache/cache_store'

  path = File.expand_path(File.join(File.dirname(__FILE__))) /  "merb-cache" / "cache_stores"
  Merb::Cache.register(:memcached, :path => (path / "memcached_store"), :class_name => "MemcachedStore")
  Merb::Cache.register(:mintcache, :path => (path / "mintcache_store"), :class_name => "MintcachedStore")


  Merb::BootLoader.before_app_loads do
    # code that can be required after the application loads
    # Initialize the cache store if there is not one setup for the default
    Merb::Cache.setup_default if Merb::Cache[:default].empty?
  end

  Merb::BootLoader.after_app_loads do

  end
end
