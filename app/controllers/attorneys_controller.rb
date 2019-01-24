class AttorneysController < ApplicationController
  def new
    @user = User.find(params[:user_id])
    @attorney = Attorney.new
  end

  def create

  end
end
