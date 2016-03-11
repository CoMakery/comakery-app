require 'rails_helper'

class FoosController < ApplicationController; end

describe ApplicationController do
  controller FoosController do
    skip_before_filter :require_login
    skip_after_action :verify_policy_scoped

    def index
      raise ActiveRecord::RecordNotFound
    end

    def new
      raise Slack::Web::Api::Error.new("boom")
    end
  end

  describe "errors" do
    describe "ActiveRecord::RecordNotFound" do
      it "redirects to 404 page" do
        get :index

        expect(response).to redirect_to "/404.html"
      end
    end

    describe "Slack::Web::Api::Error" do
      it "redirects to logout page" do
        get :new

        expect(response).to redirect_to logout_url
        expect(flash[:error]).to eq("Error talking to Slack, sorry!")
      end
    end
  end
end