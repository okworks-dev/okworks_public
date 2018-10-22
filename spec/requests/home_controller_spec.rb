require "rails_helper"

describe HomeController, :type => :request do
  describe 'GET root_path' do
    it "リクエストが成功すること" do
      get root_path
      expect(response.status).to eq(200)
    end
  end
end