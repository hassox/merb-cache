require File.dirname(__FILE__) + '/../spec_helper'

describe Hash do
  
  describe "to_sha1" do
    before(:each) do
      @params = {:id => 1, :string => "string", :symbol => :symbol}
    end
    
    it{@params.should_respond_to(:to_sha1)}
    
    it "should encode the hash by alphabetic key" do
      string = ""
      @params.keys.sort.each{|k| string << @params[k]}
      digest = Digest::SHA2.hexdigest(string)    
    end
    
    it "should be repeatable"
    
  end
  
end