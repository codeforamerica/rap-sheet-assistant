module Users
  class FinancialInformationsController < ApplicationController
    def new
      @user = User.find(params[:user_id])
      @financial_information = FinancialInformation.new(user: @user)
    end

    def create
      @user = User.find(params[:user_id])
      FinancialInformation.create!(financial_information_params.merge(user: @user))
      redirect_to rap_sheet_documents_path(@user.rap_sheet)
    end

    private

    def financial_information_params
      params.require(:financial_information).permit(:employed, :job_title, :employer_name, :employer_address)
    end
  end
end
