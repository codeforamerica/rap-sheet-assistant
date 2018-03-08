module Users
  class BenefitsController < ApplicationController
    def new
      @user = User.find(params[:user_id])
    end

    def create
      @user = User.find(params[:user_id])
      @user.financial_information.update!(benefits_params)
      redirect_to rap_sheet_documents_path(@user.rap_sheet)
    end

    private

    def financial_information_params
      params.require(:financial_information).permit(:employed, :job_title, :employer_name, :employer_address)
    end
  end
end
