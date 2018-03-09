module Users
  class IncomeInformationsController < ApplicationController
    def new
      @user = User.find(params[:user_id])
    end

    def create
      user = User.find(params[:user_id])
      user.financial_information.update!(income_information_params)
      redirect_to rap_sheet_documents_path(user.rap_sheet)
    end

    private

    def income_information_params
      params.require(:financial_information).permit(:household_size, :monthly_income_limit, :monthly_income_under_limit)
    end
  end
end
