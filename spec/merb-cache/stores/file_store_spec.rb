require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/abstract_store_spec'

describe Merb::Cache::FileStore do
  it_should_behave_like 'all stores'

  before(:each) do
    @store = Merb::Cache::FileStore.new(:dir => File.dirname(Tempfile.new("").path))
  end

  describe "#writable?" do
    it "should be true if the conditions hash is empty" do
      @store.writable?('foo').should be_true
    end

    it "should not be true if there is an 'expire_in' condition" do
      @store.writable?('foo', {}, :expire_in => 10).should_not be_true
    end
  end

  describe "#read" do
    it "should return nil if the file is non-existent" do
      key = "body.txt"

      FileUtils.rm(@store.pathify(key)) if File.exists?(@store.pathify(key))

      @store.read(key).should be_nil
    end

    it "should read the contents of the file" do
      key = "tmp.txt"
      body = "body of the file"

      File.open(@store.pathify(key), "w+") do |file|
        file << body
      end

      @store.read(key).should == body
    end
  end

  describe "#write" do
    it "should create the file if it does not exist" do
      key = "body.txt"

      FileUtils.rm(@store.pathify(key)) if File.exists?(@store.pathify(key))

      File.should_not be_exist(@store.pathify(key))

      @store.write(key, "")

      File.should be_exist(@store.pathify(key))
    end

    it "should overwrite the file if it exists" do
      key = "tmp.txt"
      old_body, new_body = "old body", "new body"

      File.open(@store.pathify(key), "w+") do |file|
        file << old_body
      end

      File.open(@store.pathify(key), "r") do |file|
        file.read.should == old_body
      end

      @store.write(key, new_body)

      File.open(@store.pathify(key), "r") do |file|
        file.read.should == new_body
      end
    end
  end

  describe "#fetch" do
    it "should not call the block if the entry can be read" do
       key, body = "tmp.txt", "body"
       called = false
       proc = lambda { called = true }

       File.open(@store.pathify(key), "w+") do |file|
         file << body
       end

       @store.fetch(key, &proc)

       called.should be_false
    end

    it "should call the block if the entry cannot be read" do
      key = "tmp.txt"
       called = false
       proc = lambda { called = true }

       FileUtils.rm(@store.pathify(key)) if File.exists?(@store.pathify(key))

       @store.fetch(key, &proc)

       called.should be_true
    end
  end

  describe "#delete" do
    it "should rm the file" do
      key, body = "tmp.txt", "body of the file"

      File.open(@store.pathify(key), "w+") do |file|
        file << body
      end

      File.exists?(@store.pathify(key)).should be_true
      @store.delete(key)
      File.exists?(@store.pathify(key)).should be_false
    end
  end

  describe "#delete_all" do
    it "should raise a NotSupportedError exception" do
      lambda { @store.delete_all }.should raise_error(Merb::Cache::NotSupportedError)
    end
  end

  describe "#pathify" do
    it "should begin with the cache dir" do
      @store.pathify("tmp.txt").should include(@store.dir)
    end

    it "should add any parameters to the end of the filename" do
      @store.pathify("index.html", :page => 3, :lang => :en).should =~ %r[--#{{:page => 3, :lang => :en}.to_sha2}$]
    end

    it "should seperate the parameters from the key by a '?'" do
      @store.pathify("index.html", :page => 3, :lang => :en).should =~ %r[--#{{:page => 3, :lang => :en}.to_sha2}$]
    end
  end
end