require File.dirname(__FILE__) + '/../spec_helper'

describe Merb::Cache do
  before(:each) do
    [Merb::Cache.stores, Merb::Cache.precedence].each {|e| e.clear}
    Thread.current[:'merb-cache'] = nil
  end

  describe ".setup" do
    it "should add the store name to the precedence list" do
      Merb::Cache.precedence.should_not include(:foo)
      Merb::Cache.setup(:foo, DummyStore)
      Merb::Cache.precedence.should include(:foo)
    end

    it "should add the store name and instance to the store hash" do
      Merb::Cache.stores.should_not have_key(:foo)
      Merb::Cache.setup(:foo, DummyStore)
      Merb::Cache.stores.should have_key(:foo)
    end

    it "should use :default when no name is supplied" do
      Merb::Cache.stores.should_not have_key(:default)
      Merb::Cache.precedence.should_not include(:default)
      Merb::Cache.setup(DummyStore)
      Merb::Cache.stores.should have_key(:default)
      Merb::Cache.precedence.should include(:default)
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
  end

  describe ".read" do
    it "should call #capture_first on the precedence list" do
      Merb::Cache.precedence.should_receive(:capture_first)
      Merb.cache.read(:key)
    end
  end

  describe ".write" do
    it "should call #capture_first on the precedence list" do
      Merb::Cache.precedence.should_receive(:capture_first)
      Merb.cache.write(:key, 'value')
    end
  end

  describe ".fetch" do
    it "should call #capture_first on the precedence list" do
      Merb::Cache.precedence.should_receive(:capture_first)
      Merb.cache.fetch(:key) { 'value' } 
    end
  end

  describe ".exists?" do
    it "should call #any? on the precedence list" do
      Merb::Cache.precedence.should_receive(:any?)
      Merb.cache.exists?(:key)
    end
  end
end