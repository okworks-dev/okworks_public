class SubscriptionsMailer < ApplicationMailer
  def jobs(subscription)
    @jobs = Job.subscription_mailer_jobs(subscription, limit = 5)
    @day = Time.now.strftime("%Y年%m月%d日")
    mail to: subscription.email, subject: "[OK Works] #{@day} 新着案件情報をご紹介"
  end
end
