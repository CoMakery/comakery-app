require 'rails_helper'

class FoosController < ApplicationController; end

describe ApplicationController do
  controller FoosController do
    skip_before_filter :require_login
    skip_after_action :verify_policy_scoped

    def index
      raise ActiveRecord::RecordNotFound
    end
  end

  describe "errors" do
    describe "ActiveRecord::RecordNotFound" do
      it "redirects to 404 page" do
        get :index

        expect(response).to redirect_to "/404.html"
      end
    end
  end
end