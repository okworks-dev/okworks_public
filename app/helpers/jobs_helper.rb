module JobsHelper
  def reward_helper(job)
    if job.reward_type == 'day'
      if job.max_reward.nil?
        "（日給）#{job.min_reward / 10000}万円以上"
      elsif job.min_reward == job.max_reward
        "（日給）#{job.min_reward / 10000}万円"
      else
        "（日給）#{job.min_reward / 10000} 〜 #{job.max_reward / 10000}万円"
      end
    elsif job.reward_type == 'month'
      if job.max_reward.nil?
        "（月給）#{job.min_reward / 10000}万円以上"
      elsif job.min_reward.nil?
        "（月給）#{job.max_reward / 10000}万円以下"
      elsif job.min_reward == job.max_reward
        "（月給）#{job.min_reward / 10000}万円"
      else
        "（月給）#{job.min_reward / 10000} 〜 #{job.max_reward / 10000}万円"
      end
    end
  end

  def reward_html_helper(job)
    if job.reward_type == 'day'
      if job.max_reward.nil?
        "<span class='text-danger h4'>#{job.min_reward / 10000}</span>万円以上/日"      
      elsif job.min_reward == job.max_reward
        "<span class='text-danger h4'>#{job.min_reward / 10000}</span>万円/日"      
      else
        "<span class='text-danger h4'>#{job.min_reward / 10000} 〜 #{job.max_reward / 10000}</span>万円/日"
      end
    elsif job.reward_type == 'month'
      if job.max_reward.nil?
        "<span class='text-danger h4'>#{job.min_reward / 10000}</span>万円以上/月"
      elsif job.min_reward.nil?
        "<span class='text-danger h4'>#{job.max_reward / 10000}</span>万円以下/月"
      elsif job.min_reward == job.max_reward
        "<span class='text-danger h4'>#{job.min_reward / 10000}</span>万円/月"
      else
        "<span class='text-danger h4'>#{job.min_reward / 10000} 〜 #{job.max_reward / 10000}</span>万円/月"
      end
    end
  end

  def workdays_helper(job)
    result = ''
    (job.min_day..job.max_day).each{|i| result += result.blank? ? "週#{i}日" : "・#{i}日" }
    result
  end
end
