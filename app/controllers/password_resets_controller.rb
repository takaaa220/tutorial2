class PasswordResetsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_email
      flash[:info] = "パスワード再設定用のメールを送信しました"
      redirect_to root_url
    else
      flash.now[:danger] = "アドレスが見つかりません"
      render "new"
    end
  end

  def edit
  end
end
