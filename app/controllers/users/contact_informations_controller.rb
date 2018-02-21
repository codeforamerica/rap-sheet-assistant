module Users
  class ContactInformationsController < ApplicationController
    def edit
      @user = User.find(params[:user_id])
    end

    def update
      @user = User.find(params[:user_id])
      if @user.update!(contact_information_params)
        redirect_to documents_rap_sheet_path(@user.rap_sheet)
      else
        render :edit
      end
    end

    private

    def contact_information_params
      params.require(:user).permit(:first_name, :last_name, :phone_number, :email, :street_address, :city, :state, :zip_code, :date_of_birth)
    end
  end
end
