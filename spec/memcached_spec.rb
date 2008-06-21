require File.dirname(__FILE__) + '/spec_helper'
require File.join(File.dirname(__FILE__), '..', 'lib', 'merb-cache', 'cache_stores', 'memcached_store')

describe "memcached store" do
  before :all do
    @store = Merb::Cache::MemcachedStore.new({:host => "127.0.0.1:11211"})
  end
  
  it "should respond to connect" do
    @store.private_methods.should include "connect"
  end
  
  it "should respond to put" do
    @store.public_methods.should include "put"
  end
  
  it "should respond to get" do
    @store.public_methods.should include "get"
  end
  
  it "should respond to expire" do
    @store.public_methods.should include "expire"
  end
  
  it "should store a key" do
    @store.put('key', "stored_data", 10)
  end
  
  it "should get a key" do
    @store.get('key').should eql "stored_data"
  end
  
  it "should know if theres a cache" do
    @store.cached?('key').should be_true
  end
  
  it "should expire a key" do
    @store.get('key').should eql "stored_data"
    @store.expire('key')
    @store.get('key').should be_nil
  end
  
  it "should know when there isn't a cache" do
    @store.cached?('key').should be_false
  end
end