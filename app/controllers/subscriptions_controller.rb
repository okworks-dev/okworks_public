class SubscriptionsController < ApplicationController
  def create
    subscription = Subscription.new_subscription(params[:email], params['subscription_skill_id'], params['subscription_job_type_id'])
    cookies.permanent[:suscribed] = 'true'
    cookies.permanent[:subscription_id] = subscription.id
    redirect_to params[:last_url], notice: '案件情報の購読を開始しました。'
  end  
end
