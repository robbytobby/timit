require 'spec_helper'

shared_examples_for "SearchController" do
  def search_key(ext = true)
    self.controller.send(:search_key, ext)
  end

  def unalias(key)
    unaliased_key = key.to_s.gsub(/_not_eq$/,'_does_not_equal')
    unaliased_key = unaliased_key.gsub(/_eq$/,'_equals')
  end

  it "### it_should_behave_like SearchController needs @search_params" do
    @search_params.should be_instance_of(Hash)
  end

  it "### it_should_behave_like SearchController needs @search_params2" do
    @search_params2.should be_instance_of(Hash)
  end
  
  it "### it_should_behave_like SearchController needs @search_model" do
    @search_model.should be_instance_of(Class)
  end

  it "### it_should_behave_like SearchController needs @search_class" do
    @search_class.should be_instance_of(Class)
  end

  it "defines the search_model" do
    self.controller.send(:search_model).should be_instance_of(Class)
  end

  it "assigns a search object to @search" do
    get :index
    assigns(:search).should be_instance_of(@search_class)
  end

  it "uses the given search attributes for @search" do
    get :index, :search => @search_params
    @search = assigns(:search)
    @search_params.each do |key, value|
      @search.search_attributes[unalias(key)].should == value
    end
  end

  it "sets up default values for a simple search" do
    get :index
    @search = assigns(:search)
    @defaults = self.controller.send(:search_defaults)[:basic]
    @defaults[:search].each do |key, value|
      @search.search_attributes[unalias(key)].should == value
    end if @defaults[:search]
  end

  it "sets up default values for an extended search" do
    get :index, :extended => :true
    @search = assigns(:search)
    @defaults = self.controller.send(:search_defaults)[:extended]
    @defaults[:search].each do |key, value|
      @search.search_attributes[unalias(key)].should == value
    end if @defaults[:search]
  end

  it "should use the given value instead of an default value" do
    get :index, :search => @search_params
    @search = assigns(:search)
    @defaults = self.controller.send(:search_defaults)[:basic]
    @defaults[:search].each do |key, value|
      if @search_params.with_indifferent_access.has_key?(key)
        @search.search_attributes[unalias(key)].should == @search_params.with_indifferent_access[key]
      else
        @search.search_attributes[unalias(key)].should == value
      end
    end if @defaults[:search]
  end

  it "stores a basic search in the session" do
    get :index, :search => @search_params
    session[search_key][:extended].should be_false
    session[search_key][:search].should == @search_params.stringify_keys
  end

  it "stores an extended search in the session" do
    get :index, :extended => true, :search => @search_params
    session[search_key(false)][:extended].should be_true
    session[search_key][:search].should == @search_params.stringify_keys
  end

  it "restores a search from session if no search params are given" do
    session[search_key] = {:search => @search_params}
    get :index
    @search = assigns(:search)
    @search_params.each do |key, value|
      @search.search_attributes[unalias(key)].should == value
    end
  end

  it "does not restore a search from session if search params are given" do
    session[search_key] = {:search => @search_params}
    get :index, :search => @search_params2
    @search = assigns(:search)
    @search_params.each do |key, value|
      @search.search_attributes[unalias(key)].should_not == value
    end
    @search_params2.each do |key, value|
      @search.search_attributes[unalias(key)].should == value
    end
  end

  it "overwrites sort by rank if necessary" do 
    get :index, :search => {:meta_sort => 'rank.asc'}
    @search = assigns(:search)
    @search.search_attributes["meta_sort"].should == self.controller.send(:search_defaults)[:basic][:search]['meta_sort']
  end

  it "restores a simple search, when I come back from another action" do
    get :index, :search => @search_params2, :extended => true
    get :index, :search => @search_params
    get :show, :id => @search_model.first.id
    get :index
    @search = assigns(:search)
    @search_params.each do |key, value|
      @search.search_attributes[unalias(key)].should == value
    end
  end

  it "restores an extended search, when I come back from another action" do
    get :index, :search => @search_params2
    get :index, :search => @search_params, :extended => true
    get :show, :id => @search_model.first.id
    get :index
    @search = assigns(:search)
    @search_params.each do |key, value|
      @search.search_attributes[unalias(key)].should == value
    end
  end

  it "toggles between extended and basic search" do
    session[search_key] = {:extended => true}
    get :toggle_search, :format => :js
    session[search_key][:extended].should be_false
    self.controller.params[:extended].should be_false
  end

  it "restores a basic search while toggeling to it" do
    get :index, :search => @search_params
    get :index, :search => @search_params2, :extended => true
    get :toggle_search, :format => :js
    @search = assigns(:search)
    @search_params.each do |key, value|
      @search.search_attributes[unalias(key)].should == value
    end
  end
    
  it "restores an extended search while toggeling to it" do
    get :index, :search => @search_params, :extended => true
    get :index, :search => @search_params2
    get :toggle_search, :format => :js
    @search = assigns(:search)
    @search_params.each do |key, value|
      @search.search_attributes[unalias(key)].should == value
    end
  end
end
