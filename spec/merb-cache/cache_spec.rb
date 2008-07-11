require File.dirname(__FILE__) + '/../spec_helper'

describe Merb::Cache do
  before(:each) do
    Merb::Cache.stores.clear
    Thread.current[:'merb-cache'] = nil
  end

  describe ".setup" do
    it "should add the store name and instance to the store hash" do
      Merb::Cache.stores.should_not have_key(:foo)
      Merb::Cache.setup(:foo, DummyStore)
      Merb::Cache.stores.should have_key(:foo)
    end

    it "should use :default when no name is supplied" do
      Merb::Cache.stores.should_not have_key(:default)
      Merb::Cache.setup(DummyStore)
      Merb::Cache.stores.should have_key(:default)
    end
  end

  describe ".[]" do
    it "should clone the stores so to keep them threadsafe" do
      Merb::Cache.setup(DummyStore)
      Merb::Cache[:default].should_not be_nil
      Merb::Cache[:default].should_not == Merb::Cache.stores[:default]
    end

    it "should cache the thread local stores in Thread.current" do
      Merb::Cache.setup(DummyStore)
      Thread.current[:'merb-cache'].should be_nil
      Merb::Cache[:default]
      Thread.current[:'merb-cache'].should_not be_nil
    end

    it "should create an adhoc store if multiple store names are supplied" do
      Merb::Cache.setup(DummyStore)
      Merb::Cache.setup(:dummy, DummyStore)
      Merb::Cache[:default, :dummy].class.should == Merb::Cache::AdhocStore
    end
    
    it "should let you create new stores after accessing the old ones" do
      Merb::Cache.setup(DummyStore)
      Merb::Cache.setup(:one, DummyStore)
      Merb::Cache[:default].should_not be_nil
      Merb::Cache[:one].should_not be_nil
      Merb::Cache.setup(:two, DummyStore)
      Merb::Cache[:two].should_not be_nil
    end
    
    it "should raise an error if the cache has not been setup" do
      Merb::Cache.setup(DummyStore)
      Merb::Cache[:default].should_not be_nil      
      lambda do
        Merb::Cache[:does_not_exist]
      end.should raise_error(Merb::Cache::StoreNotFound)
    end
  end
end