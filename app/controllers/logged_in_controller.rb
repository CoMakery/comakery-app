class LoggedInController < ApplicationController
  def landing
    render text: "landing, you logged in bro"
  end
end
