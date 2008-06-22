describe "proxy to cache engine" do
  before :all do
    Merb::Cache::Store.new
    @cache = CacheSpecController.new({})
  end
  
  it "should put a cache" do
    @cache.put("a-key", "some data", 10)
  end
  
  it "should get a cache" do
    @cache.get("a-key").should eql("some data")
  end
  
  it "should know when a cache exists" do
    @cache.cached?("a-key").should be_true
    @cache.cached?("b-key").should_not be_true
  end
  
  it "should expire a cache" do
    @cache.expire!("a-key")
  end
  
  it "should set validity in minutes" do
    @cache.put("c-key", "data", 1)
    sleep 1 # Seconds
    @cache.cached?("c-key").should be_true
  end
  
  it "should allow a cache store to register itself" do
    file = File.expand_path(File.dirname(__FILE__) / ".." / "lib" / "merb-cache" / "cache_stores"/ "memcached_store" )
    Merb::Cache.register(:tester, :path => file, :class_name => "MemcachedStore")   
  end

  it "should raise an error if there is no path and class_name present" do
    lambda do
      Merb::Cache.register(:memcached, {})
    end.should raise_error(ArgumentError)
  end
  
  it "should get the default cache" do
    Merb::Cache[:default].should be_a_kind_of(Merb::Cache::Store)    
  end
  
  it "should get a custom cache" do
    Merb::Cache.setup(:custom, :memcached)
    Merb::Cache[:custom].should be_a_kind_of(Merb::Cache::MemcachedStore)
  end
  
  it "should not allow you to register a store if the file does not exist" do
    lambda do
      Merb::Cache.register(:custom_store, :path => "does/not/exist", :class_name => "NotHere")
    end.should raise_error(Merb::Cache::Store::NotFound)
  end
  
  it "should raise an error when accessing a cache that does not exist" do
    lambda do 
      Merb::Cache[:not_there]
    end.should raise_error(Merb::Cache::Store::NotFound)
  end
  
  it "should remove active stores" do
    Merb::Cache.setup(:custom_store1, :mintcache)
    Merb::Cache[:custom_store1].should_not be_nil
    Merb::Cache.remove_active_cache!(:custom_store1).should be_a_kind_of(Merb::Cache::MintcachedStore)
    lambda do
      Merb::Cache[:custom_store1]
    end.should raise_error(Merb::Cache::Store::NotFound)
  end
  
  it "should setup multiple stores" do
    Merb::Cache.setup(:custom_store1, :memcached)
    Merb::Cache.setup(:custom_store2, :mintcache)
    Merb::Cache[:custom_store1].should be_a_kind_of(Merb::Cache::MemcachedStore)
    Merb::Cache[:custom_store2].should be_a_kind_of(Merb::Cache::MintcachedStore)
    Merb::Cache.remove_active_cache!(:custom_store1)
    Merb::Cache.remove_active_cache!(:custom_store2)
  end
  

  
  it "should return the registered_stores" do
    Merb::Cache.registered_stores.keys.should include(:memcached, :mintcache)
    Merb::Cache.registered_stores[:memcached].keys.should include(:path, :class_name)
    Merb::Cache.registered_stores[:mintcache].keys.should include(:path, :class_name)
  end

  it "should return the active_stores" do
    Merb::Cache.setup(:my_store, :memcached)
    Merb::Cache.send(:active_stores).keys.should include(:my_store)
    Merb::Cache.remove_active_cache!(:my_store)
  end
  
end

describe "store keys" do
  it "should store keys in :controller/:action format by default"
  it "should store keys in a specified format"
end