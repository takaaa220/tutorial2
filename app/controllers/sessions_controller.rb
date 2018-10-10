class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password])
      flash[:success] = "ログインしました"
      log_in @user
      redirect_to @user
    else
      flash.now[:danger] = "メールアドレスとパスワードを確認してください"
      render "new"
    end
  end

  def destroy
    log_out
    flash[:success] = "ログアウトしました"
    redirect_to root_url
  end

end
