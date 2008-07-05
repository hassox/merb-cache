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

    it "should create an adhoc store if multiple store names are supplied" do
      Merb::Cache.setup(DummyStore)
      Merb::Cache.setup(:dummy, DummyStore)
      Merb::Cache[:default, :dummy].class.should == Merb::Cache::AdhocStore
    end
  end

  describe ".read" do
    it "should call #read on the result of the cache lookup" do
      store = mock(:store)
      store.should_receive(:read)
      Merb::Cache.should_receive(:[]).with(Merb::Cache.precedence).and_return store

      Merb.cache.read(:key)
    end
  end

  describe ".write" do
    it "should call #write on the result of the cache lookup" do
      store = mock(:store)
      store.should_receive(:write)
      Merb::Cache.should_receive(:[]).with(Merb::Cache.precedence).and_return store

      Merb.cache.write(:key, :value)
    end
  end

  describe ".write_all" do
    it "should call #write_all on the result of the cache lookup" do
      store = mock(:store)
      store.should_receive(:write_all)
      Merb::Cache.should_receive(:[]).with(Merb::Cache.precedence).and_return store

      Merb.cache.write_all(:key, :value)
    end
  end

  describe ".fetch" do
    it "should call #fetch on the result of the cache lookup" do
      store = mock(:store)
      store.should_receive(:fetch)
      Merb::Cache.should_receive(:[]).with(Merb::Cache.precedence).and_return store

      Merb.cache.fetch(:key) { 'value' } 
    end
  end

  describe ".exists?" do
    it "should call #fetch? on the result of the cache lookup" do
      store = mock(:store)
      store.should_receive(:exists?)
      Merb::Cache.should_receive(:[]).with(Merb::Cache.precedence).and_return store

      Merb.cache.exists?(:key)
    end
  end

  describe ".delete" do
    it "should call #delete on the result of the cache lookup" do
      store = mock(:store)
      store.should_receive(:delete)
      Merb::Cache.should_receive(:[]).with(Merb::Cache.precedence).and_return store

      Merb.cache.delete(:key)
    end
  end

  describe ".delete_all!" do
    it "should call #delete_all! on the result of the cache lookup" do
      store = mock(:store)
      store.should_receive(:delete_all!)
      Merb::Cache.should_receive(:[]).with(Merb::Cache.precedence).and_return store

      Merb.cache.delete_all!
    end
  end
end