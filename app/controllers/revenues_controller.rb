class RevenuesController < ApplicationController
  skip_before_action :require_login, only: :index

  def index
    head :ok
  end
end
