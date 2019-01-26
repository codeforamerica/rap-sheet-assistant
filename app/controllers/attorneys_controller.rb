class AttorneysController < ApplicationController
  def new
    @user = User.find(session[:current_user_id])
  end

  def create
    attorney = Attorney.create(attorneys_params)
    @user = User.find(session[:current_user_id])
    @user.attorney = attorney
    @user.save!
    redirect_to edit_user_contact_information_path(@user)
  end

  def attorneys_params
    params.require(:attorney).permit(:name, :state_bar_number, :firm_name)
  end
end
