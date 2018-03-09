module Users
  class FinancialInformationsController < ApplicationController
    def new
      @user = User.find(params[:user_id])
      @financial_information = FinancialInformation.new(user: @user)
    end

    def create
      user = User.find(params[:user_id])

      financial_information = FinancialInformation.find_or_initialize_by(user: user)
      financial_information.update!(financial_information_params)
      redirect_to new_user_benefits_path(user)
    end

    private

    def financial_information_params
      params.require(:financial_information).permit(:employed, :job_title, :employer_name, :employer_address)
    end
  end
end
