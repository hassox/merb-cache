# Require components
require 'merb-cache/controller'
require 'merb-cache/cache_store'

path = File.expand_path(File.join(File.dirname(__FILE__)))
Merb::Cache.register(:memcached, :path => (path / "cache_stores" / "memcached_store"), :class_name => "MemcachedStore")
Merb::Cache.register(:mintcache, :path => (path / "cache_stores" / "mintcache_store"), :class_name => "MintcachedStore")


Merb::BootLoader.before_app_loads do
  # require code that must be loaded before the application
end

Merb::BootLoader.after_app_loads do
  # code that can be required after the application loads
end