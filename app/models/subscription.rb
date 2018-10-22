class Subscription < ApplicationRecord
  serialize :conditions

  def self.new_subscription(email, skill_id = nil, job_type_id = nil)
    Subscription.create(email: email, conditions: {skill_id: skill_id, job_type_id: job_type_id})
  end

  def send_mail
    begin
      SubscriptionsMailer.jobs(self).deliver_now
    rescue => exception      
    end
  end

  def self.send_mails
    subscriptions = self.all
    subscriptions.each{|subscription| subscription.send_mail}
  end
end