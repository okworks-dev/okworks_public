class FixAverageRewardOfPebank
  def self.execute
    site_id = Site.find_by(name: 'Pe-BANK').id
    jobs = Job.where(site_id: site_id)
    jobs.each do |job|
      if job.max_reward
        average_reward = (job.max_reward.to_f / (job.max_day.to_f * 4)).to_i
      else
        average_reward = (job.min_reward.to_f / (job.min_day.to_f * 4)).to_i
      end
      job.update(average_reward: average_reward)
    end
  end
end

FixAverageRewardOfPebank.execute
