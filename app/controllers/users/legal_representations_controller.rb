module Users
  class LegalRepresentationsController < ApplicationController
    def new
      @user = User.find(params[:user_id])
    end

    def yes
      @user = User.find(params[:user_id])
      @user.update(has_attorney: true)
      redirect_to new_user_attorney_path(@user)
    end

    def no
      @user = User.find(params[:user_id])
      @user.update(has_attorney: false)
      redirect_to user_contact_information_path(@user)
    end
  end
end
