describe "proxy to cache engine" do
  before :all do
    @cache = Merb::Cache::Store.new
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
    sleep 2 # Seconds
    @cache.cached?("c-key").should be_true
  end
end

describe "store keys" do
  it "should store keys in :controller/:action format by default"
  it "should store keys in a specified format"
end