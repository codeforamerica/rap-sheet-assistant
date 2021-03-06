module Users
  class ContactInformationsController < ApplicationController
    def show
      @user = User.find(params[:user_id])
      redirect_to edit_user_contact_information_path(@user)
    end

    def edit
      @user = User.find(params[:user_id])
      @form = ContactInformationForm.from_user(@user)
      #redirect_to rap_sheet_documents_path(@user.rap_sheet)
    end

    def update
      @user = User.find(params[:user_id])
      @form = ContactInformationForm.new(contact_information_params)
      if @form.save(@user)
        redirect_to rap_sheet_documents_path(@user.rap_sheet)
      else
        render :edit
      end
    end

    private

    def contact_information_params
      params.require(:contact_information_form).permit(
        :name,
        :phone_number,
        :email,
        :street_address,
        :city,
        :state,
        :zip,
        :date_of_birth,
        :prefer_email,
        :prefer_text
      )
    end
  end
end
