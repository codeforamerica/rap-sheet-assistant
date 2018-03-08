module Users
  class BenefitsController < ApplicationController
    def new
      @user = User.find(params[:user_id])
    end

    def create
      @user = User.find(params[:user_id])
      @user.financial_information.update!(benefits_params)
      if benefits_params[:benefits_programs].empty?
        redirect_to new_user_income_information_path(@user)
      else
        redirect_to rap_sheet_documents_path(@user.rap_sheet)
      end
    end

    private

    def benefits_params
      _benefits_params = params.require(:financial_information).permit(benefits_programs: [])
      _benefits_params[:benefits_programs].reject!(&:blank?)
      _benefits_params
    end
  end
end
