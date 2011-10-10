require "spec_helper"

describe MachinesController do
  describe "routing" do

    it "routes to #index" do
      get("/machines").should route_to("machines#index")
    end

    it "routes to #new" do
      get("/machines/new").should route_to("machines#new")
    end

    it "routes to #show" do
      get("/machines/1").should route_to("machines#show", :id => "1")
    end

    it "routes to #edit" do
      get("/machines/1/edit").should route_to("machines#edit", :id => "1")
    end

    it "routes to #create" do
      post("/machines").should route_to("machines#create")
    end

    it "routes to #update" do
      put("/machines/1").should route_to("machines#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/machines/1").should route_to("machines#destroy", :id => "1")
    end

  end
end
