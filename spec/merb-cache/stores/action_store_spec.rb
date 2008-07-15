require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/strategy_store_spec'

describe Merb::Cache::ActionStore do
  it_should_behave_like 'all strategy stores'

  before(:each) do
    Merb::Cache.stores.clear
    Thread.current[:'merb-cache'] = nil

    @klass = Merb::Cache::ActionStore[:dummy]
    Merb::Cache.setup(:dummy, DummyStore)
    Merb::Cache.setup(:default, @klass)

    @dummy = Merb::Cache[:dummy]
    @store = Merb::Cache[:default]
  end

  describe "examples" do
    class Scores < Merb::Controller
      cache :index, :show
      cache :overview
      cache :short, :params => :page
      cache :stats, :params => [:start_date, :end_date]
      cache :ticker, :expire_in => 10

      def index
        "Scores index"
      end

      def show(team)
        "Scores show(#{team})"
      end

      def overview(team = :all)
        "Scores overview(#{team})"
      end

      def short(team = :all)
        "Scores short(#{team})[#{params[:page]}]"
      end

      def stats(start_date, end_date, team = :all)
        "Scores stats(#{team}, #{start_date}, #{end_date})"
      end

      def ticker
        "Scores ticker"
      end
    end

    it "should cache the index action on the first request" do
      dispatch_to(Scores, :index)

      @dummy.data("Scores#index").should == "Scores index"
    end

    it "should cache the show action by the team parameter using the action arguments" do
      dispatch_to(Scores, :show, :team => :redsox)

      @dummy.data("Scores#show", :team => 'redsox').should == "Scores show(redsox)"
    end

    it "should cache the overview action by the default parameter if none is given" do
      dispatch_to(Scores, :overview)

      @dummy.data("Scores#overview", :team => :all).should == "Scores overview(all)"
    end

    it "should cache the short action by the team & page parameters" do
      dispatch_to(Scores, :short, :team => :bosux, :page => 4)

      @dummy.data("Scores#short", :team => 'bosux', :page => '4').should == "Scores short(bosux)[4]"
    end

    it "should cache the stats action by team, start_date & end_date parameters" do
      start_date, end_date = Time.today.to_s, Time.now.to_s
      dispatch_to(Scores, :stats, :start_date => start_date, :end_date => end_date)

      @dummy.data("Scores#stats", :team => :all, :start_date => start_date, :end_date => end_date).should == "Scores stats(all, #{start_date}, #{end_date})"
    end

    it "should cache the ticker action with an expire_in condition" do
      dispatch_to(Scores, :ticker)

      @dummy.conditions("Scores#ticker")[:expire_in].should == 10
    end
  end
end