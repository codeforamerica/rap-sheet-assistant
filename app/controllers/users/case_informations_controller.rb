module Users
  class CaseInformationsController < ApplicationController
    def show
      @user = User.find(params[:user_id])
      redirect_to edit_user_case_information_path(@user)
    end

    def edit
      @user = User.find(params[:user_id])
      @form = CaseInformationForm.from_user(@user)
    end

    def update
      @user = User.find(params[:user_id])
      @form = CaseInformationForm.new(case_information_params)
      if @form.save(@user)
        redirect_to rap_sheet_documents_path(@user.rap_sheet)
      else
        render :edit
      end
    end

    private

    def case_information_params
      params.require(:case_information_form).permit(*CaseInformationForm::ATTRIBUTES)
    end
  end
end
