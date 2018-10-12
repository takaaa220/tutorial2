class LikesController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]

  def create
    @micropost = Micropost.find(params[:micropost_id])
    @micropost.iine(current_user)
    flash[:success] = "いいねしました"
    redirect_to request.referrer || root_url
  end

  def destroy
    @micropost = Like.find(params[:id]).micropost
    @micropost.uuun(current_user)
    flash[:success] = "いいねを取り消しました"
    redirect_to request.referrer || root_url
  end
end
