class SessionsController < ApplicationController

  def new
    @user = User.new
    render :new
  end

  def create
  user_params = params.require(:user).permit(:email, :password)
  @user = User.confirm(user_params)
    if @user
      login(@user)
      flash[:notice] = "Successfully logged in."
      redirect_to @user
    else
      flash[]
      redirect_to login_path
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "Successfully logged out."
    redirect_to root_path
  end




end
