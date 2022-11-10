require 'rails_helper'

RSpec.describe "TwitterSearchProcesses", type: :request do

  describe "GET /new" do
    it "returns http success" do
      get "/twitter_search_processes/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /creaate" do
    it "returns http success" do
      get "/twitter_search_processes/creaate"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/twitter_search_processes/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/twitter_search_processes/show"
      expect(response).to have_http_status(:success)
    end
  end

end
