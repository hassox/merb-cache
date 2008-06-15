require File.dirname(__FILE__) + '/spec_helper'

#dispatch_to(Merb::Test::Fixtures::Controllers::DisplayWithStringLocation, :index, {}, :http_accept => "application/json").headers['Location'].should =~ /some_resources/

describe "merb action cache returned headers" do
  it "should return gzip"
  it "should not return gzip"
  it "should set cache-control"
  it "should set expires"
  it "should set etag"
  it "should set last-modified"
  it "should set the expires header to the current time and date plus the defined cache expiry time"
  it "should return gzip if the client can accept it"
  it "should not return gzip when the client can not accept it"
end
