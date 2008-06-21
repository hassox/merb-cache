describe "proxy to cache engine" do
  before :all do
    @cache = Merb::Cache::Store.new
  end
  
  it "should put a cache" do
    @cache.put("a-key", "some data", 10)
  end
  
  it "should get a cache" do
    @cache.get("a-key").should eql "some data"
  end
  
  it "should know when a cache exists" do
    @cache.cache_exists?("a-key").should be_true
    @cache.cache_exists?("b-key").should_not be_true
  end
end

describe "store keys" do
  it "should store keys in :controller/:action format by default"
  it "should store keys in a specified format"
end