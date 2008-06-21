describe "proxy to cache engine" do
  before :all do
    Merb::Cache::Store.new
    @cache = Merb::Cache[:default]
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
  
  it "should allow a cache store to register itself" do
    file = File.expand_path(File.dirname(__FILE__) / ".." / "lib" / "merb-cache" / "cache_stores", "memcached_store" )
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
    puts Merb::Cache[:custom].inspect
    Merb::Cache[:custom].should be_a_kind_of(Merb::Cache::MemcachedStore)
  end
  
  it "should not allow you to register a store if the file does not exist" do
    pending
    Merb::Cache.register(:custom_store, "does/not/exist")
    Merb::Cache[:custom_store].should be_nil
  end
  
end

describe "store keys" do
  it "should store keys in :controller/:action format by default"
  it "should store keys in a specified format"
end