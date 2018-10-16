class SharesController < ApplicationController
  before_action :logged_in_user

  def create
    @micropost = Micropost.find(params[:micropost_id])
    @micropost.retweet(current_user)
    flash[:success] = "シェアしました"
    redirect_to request.referrer || root_url
  end

  def destroy
    @micropost = Share.find(params[:id]).micropost
    @micropost.unretweet(current_user)
    flash[:success] = "シェアを取り消しました"
    redirect_to request.referrer || root_url
  end
end
