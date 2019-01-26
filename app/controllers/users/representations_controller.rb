module Users
  class RepresentationsController < ApplicationController
    def new
      @user = User.find(params[:user_id])
    end

    def yes
      @user = User.find(params[:user_id]).update(pro_se: false)
      user = User.find(params[:user_id])
      redirect_to new_attorney_path(@user)
    end

    def no
      @user = User.find(params[:user_id]).update(pro_se: true)
      user = User.find(params[:user_id])
      redirect_to new_user_contact_information_path(user)
    end
  end
end
