require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/abstract_store_spec'

begin
  require 'memcached'
  servers = ['127.0.0.1:43042', '127.0.0.1:43043']
  namespace = 'memcached_test_namespace'
  
  options = {      
    :namespace => @namespace,
    :hash => :default,
    :distribution => :modula
  }
  cache = Memcached.new(servers, options)
  key, value = Time.now.to_i.to_s, DateTime.now.to_s
  cache.set(key, value)
  raise Exception unless cache.get(key) == value
rescue Exception => e
  raise "Memcached test failed.  Try starting memcached with the memcached:start rake task"
end

describe Merb::Cache::MemcachedStore do
  it_should_behave_like 'all stores'

  before(:each) do
    @store = Merb::Cache::MemcachedStore.new(:namespace => "specs", :servers => ["127.0.0.1:43042", "127.0.0.1:43043"])
    @memcached = @store.memcached
    @memcached.flush
  end

  after(:each) do
    @memcached.flush
  end

  describe "#writable?" do
    it "should be true if the conditions hash is empty" do
      @store.writable?('foo').should be_true
    end
  end

  describe "#read" do
    it "should return nil if the key has no entry" do
      key = "foo"

      @memcached.delete(key) rescue nil

      @store.read(key).should be_nil
    end

    it "should return the entry matching the key" do
      key, data = "foo", "bar"

      @memcached.set(key, data)

      @store.read(key).should == data
    end
  end

  describe "#write" do
    it "should create a new entry if it doesn't exist" do
      key, data = "foo", "bar"

      @memcached.delete(key) rescue nil

      lambda { @memcached.get(key) }.should raise_error(Memcached::NotFound)

      @store.write(key, data)

      @memcached.get(key).should == data
    end

    it "should overwrite the entry if it exists" do
      key, data = "foo", "bar"

      @memcached.set(key, "baz")

      @memcached.get(key).should == "baz"

      @store.write(key, data)

      @memcached.get(key).should == data
    end
  end

  describe "#fetch" do
    it "should not call the block if the entry exists" do
       key, data = "foo", "bar"
       called = false
       proc = lambda { called = true }

       @memcached.set(key, data)

       @store.fetch(key, &proc)

       called.should be_false
    end

    it "should call the block if the entry doesn't exist" do
      key, data = "foo", "bar"
       called = false
       proc = lambda { called = true }

       @memcached.delete(key) rescue nil

       @store.fetch(key, &proc)

       called.should be_true
    end
  end

  describe "#delete" do
    it "should delete the entry" do
      key, data = "foo", "bar"

      @memcached.set(key, data)

      @memcached.get(key).should == data

      @store.delete(key)

      lambda { @memcached.get(key) }.should raise_error(Memcached::NotFound)
    end
  end

  describe "#delete_all" do
    it "should call 'flush' on the Memcached object" do
      @memcached.should_receive(:flush).at_least(1).times

      @store.delete_all
    end
  end

  describe "#clone" do
    it "should call the call method of the Memcached instance" do
      @memcached.should_receive(:clone)

      @store.clone
    end
  end

  describe "#normalize" do
    it "should begin with the key" do
      @store.normalize("this/is/the/key").should =~ /^this\/is\/the\/key/
    end

    it "should not add the '?' if there are no parameters" do
      @store.normalize("this/is/the/key").should_not =~ /\?/
    end

    it "should seperate the parameters from the key by a '?'" do
      @store.normalize("this/is/the/key", :page => 3, :lang => :en).should =~ %r!this\/is\/the\/key--#{{:page => 3, :lang => :en}.to_sha2}$!
    end
  end

  describe "#expire_time" do
    it "should return 0 if there is no :expire_in parameter" do
      @store.expire_time.should == 0
    end

    it "should return Time.now + the :expire_in parameter" do
      now = Time.now
      Time.should_receive(:now).and_return now

      @store.expire_time(:expire_in => 100).should == now + 100
    end
  end
end