require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/abstract_store_spec'

describe Merb::Cache::AdhocStore do
  it_should_behave_like 'all stores'

  before(:each) do
    Merb::Cache.stores.clear
    Thread.current[:'merb-cache'] = nil
    Merb::Cache.setup(:dummy, DummyStore)
    @store = Merb::Cache::AdhocStore[:dummy]
  end

  describe "#initialize" do
    it "should lookup all store names" do
      names = [:first, :second, :third]
      names.each {|n| Merb::Cache.should_receive(:[]).with(n)}

      Merb::Cache::AdhocStore[*names]
    end
  end

  describe "#write_all" do
    it "should not raise a NotImplementedError error" do
      lambda { @store.write_all('foo', 'bar') }.should_not raise_error(NotImplementedError)
    end

    it "should accept a string key" do
      @store.write_all('foo', 'bar')
    end

    it "should accept a symbol as a key" do
      @store.write_all(:foo, :bar)
    end

    it "should accept parameters and conditions" do
      @store.write_all('foo', 'bar', {:params => :hash}, :conditions => :hash)
    end
  end
end