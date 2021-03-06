require "rails_helper"

describe Api::V1::UsersController do
  context "no access token" do
    it 'returns a 401 when users are not authenticated' do
      get :show
      expect(response.code).to eq "401"
    end
  end
end
