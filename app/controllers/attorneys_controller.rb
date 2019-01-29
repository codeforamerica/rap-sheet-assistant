class AttorneysController < ApplicationController
  def new
    @user = User.find(params[:user_id])
  end

  def create
    attorney = Attorney.create(attorneys_params)
    user = User.find(params[:user_id])
    attorney.users << user
    redirect_to edit_user_contact_information_path(user)
  end

  def attorneys_params
    params.require(:attorney).permit(
      :name,
      :state_bar_number,
      :firm_name,
      :street_address,
      :city,
      :state,
      :zip,
      :phone_number,
      :email
    )
  end
end
