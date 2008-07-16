require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/abstract_strategy_store_spec'

describe Merb::Cache::PageStore do
  it_should_behave_like 'all strategy stores'

  before(:each) do
    Merb::Cache.stores.clear
    Thread.current[:'merb-cache'] = nil

    @klass = Merb::Cache::PageStore[:dummy]
    Merb::Cache.setup(:dummy, DummyStore)
    Merb::Cache.setup(:default, @klass)

    @store = Merb::Cache[:default]
    @dummy = @store.stores.first
  end

  describe "examples" do

    class NHLScores < Merb::Controller
      provides :xml, :json, :yaml

      cache :index, :show
      cache :overview
      cache :short, :params => :page
      cache :stats, :params => [:start_date, :end_date]


      def index
        "NHLScores index"
      end

      def show(team)
        "NHLScores show(#{team})"
      end
    end

    before(:each) do
      Merb::Router.prepare do |r|
        r.match("/").to(:controller => "nhl_scores", :action => "index").name(:index)
        r.match("/show/:team").to(:controller => "nhl_scores", :action => "show").name(:show)
      end
    end

    it "should cache the index action on the first request" do
      dispatch_to(NHLScores, :index) {|c| c.request.env['REQUEST_PATH'] = url(:index)}

      @dummy.data("/index.html").should == "NHLScores index"
    end

    it "should cache the yaml version of the index action request" do
      dispatch_to(NHLScores, :index) {|c| c.request.env['REQUEST_PATH'] = url(:index); c.content_type = :yaml}

      @dummy.data("/index.yaml").should == "NHLScores index"
    end

    it "should cache the show action when the team parameter is a route parameter" do
      dispatch_to(NHLScores, :show, :team => 'redwings') {|c| c.request.route_params = {:team => 'redwings'}; c.request.env['REQUEST_PATH'] = url(:show, :team => 'redwings')}

      @dummy.data("/show/redwings.html", :team => 'redwings').should == "NHLScores show(redwings)"
    end

    it "should cache the xml version of a request" do
      dispatch_to(NHLScores, :show, :team => 'redwings') {|c| c.request.route_params = {:team => 'redwings'}; c.request.env['REQUEST_PATH'] = url(:show, :team => 'redwings'); c.content_type = :xml}

      @dummy.data("/show/redwings.xml", :team => 'redwings').should == "NHLScores show(redwings)"
    end


    it "should not cache the show action when the team parameter is not a route parameter" do
      dispatch_to(NHLScores, :show, :team => 'readwings')

      @dummy.vault.should be_empty
    end

    it "should not cache the action when a there is a query string parameter" do
      dispatch_to(NHLScores, :index, :page => 2) {|c| c.request.env['REQUEST_PATH'] = url(:index); c.request.env['QUERY_STRING'] = 'page=2'}

      @dummy.vault.should be_empty
    end

    it "should not cache a POST request" do
      dispatch_to(NHLScores, :index) {|c| c.request.env['REQUEST_PATH'] = url(:index); c.request.env['REQUEST_METHOD'] = 'post'}
    end
  end
end