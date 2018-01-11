class MembershipsController < ApplicationController
  def create
    if current_user.id === params[:membership][:user_id]
      Membership.create(library_id: params[:membership][:library_id], user_id: params[:membership][:user_id])
      redirect_to libraries_path
    else
      flash[:notice] = "stop hacking"
      redirect_to libraries_path
    end
  end
end
