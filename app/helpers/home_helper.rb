module HomeHelper

  def set_skill_amont_charts
    skill_amount = cache_skill_amount
    name = skill_amount.keys
    data = skill_amount.values
    @skill_amount_bar = LazyHighCharts::HighChart.new("graph") do |f|
      f.chart(:type => "column")
      f.title(:text => "技術別の案件数")
      f.xAxis(:categories => name)
      f.series(:data => data)
      f.legend(enabled: false)
    end
  end

  def set_skill_amont_charts_sp
    skill_amount = cache_skill_amount_sp
    name = skill_amount.keys
    data = skill_amount.values
    @skill_amount_bar_sp = LazyHighCharts::HighChart.new("graph") do |f|
      f.chart(:type => "column")
      f.title(:text => "技術別の案件数")
      f.xAxis(:categories => name)
      f.series(data: data)
      f.legend(enabled: false)
    end
  end

  def set_median_rewards_by_skills
    skill_amount = cache_median_rewards
    name = skill_amount.keys
    data = skill_amount.values
    @skill_average_rewards_bar = LazyHighCharts::HighChart.new("graph") do |f|
      f.chart(:type => "column")
      f.title(:text => "技術別の単価/日の中央値")
      f.yAxis(
          title: {text: ''},
          labels: {
            formatter: "function(){
                return Highcharts.numberFormat(this.value, 0, '.', ',') +'円'
            }".js_code,
          }
      )
      f.xAxis(:categories => name)
      f.series(:data => data)
      f.legend(enabled: false)
    end
  end

  def set_median_rewards_by_skills_sp
    skill_amount = cache_median_rewards_sp
    name = skill_amount.keys
    data = skill_amount.values
    @skill_average_rewards_bar_sp = LazyHighCharts::HighChart.new("graph") do |f|
      f.chart(:type => "column")
      f.title(:text => "技術別の単価/日の中央値")
      f.yAxis(
          title: {text: ''},
          labels: {
            formatter: "function(){
                return Highcharts.numberFormat(this.value, 0, '.', ',') +'円'
            }".js_code,
          }
      )
      f.xAxis(:categories => name)
      f.series(:data => data)
      f.legend(enabled: false)
    end
  end

  def cache_skill_amount
    Rails.cache.fetch('cache_skill_amount', expires_in: 1.hour) do
      skill_amount_hash = {}
      skills = Skill.all
      skills.each do |skill|
        amount = JobSkill.where(skill_id: skill.id).size
        skill_amount_hash[skill.name] = amount
      end
      skill_amount_hash
    end
  end

  def cache_skill_amount_sp
    Rails.cache.fetch('cache_skill_amount_sp', expires_in: 1.hour) do
      skill_amount_hash = {}
      skills = Skill.all
      skills.each do |skill|
        amount = JobSkill.where(skill_id: skill.id).size
        skill_amount_hash[skill.name] = amount
        if skill_amount_hash.size > 10
          min_value = skill_amount_hash.values.min
          min_key = skill_amount_hash.key(min_value)
          skill_amount_hash.delete min_key
        end
      end
      skill_amount_hash
    end
  end

  def cache_median_rewards
    Rails.cache.fetch('cache_median_rewards', expires_in: 1.hour) do
      median_rewards_hash = {}
      skills = Skill.all
      skills.each do |skill|
        job_ids = JobSkill.where(skill_id: skill.id).pluck :job_id
        jobs_rewards = Job.where(id: job_ids).pluck :average_reward
        median_rewards = calc_median_reward(jobs_rewards)
        # クローリング先のサイトにおいて入力ミスがあった時、
        # 平均値だと大きくぶれてしまうので、中央値を使用
        median_rewards_hash[skill.name] = median_rewards.to_i
      end
      median_rewards_hash
    end
  end

  def cache_median_rewards_sp
    Rails.cache.fetch('cache_median_rewards_sp', expires_in: 1.hour) do
      median_rewards_hash = {}
      skills = Skill.all
      skills.each do |skill|
        job_ids = JobSkill.where(skill_id: skill.id).pluck :job_id
        jobs_rewards = Job.where(id: job_ids).pluck :average_reward
        median_rewards = calc_median_reward(jobs_rewards)
        # クローリング先のサイトにおいて入力ミスがあった時、
        # 平均値だと大きくぶれてしまうので、中央値を使用
        median_rewards_hash[skill.name] = median_rewards.to_i
        if median_rewards_hash.size > 10
          min_value = median_rewards_hash.values.min
          min_key = median_rewards_hash.key(min_value)
          median_rewards_hash.delete min_key
        end
      end
      median_rewards_hash
    end
  end

  def calc_median_reward(jobs_rewards)
    if jobs_rewards.size == 0
      median_rewards = 0
    else
      median_rewards = (jobs_rewards.size % 2).zero? ? jobs_rewards[jobs_rewards.size/2 - 1, 2].inject(:+) / 2.0 : jobs_rewards[jobs_rewards.size/2]
    end
    return median_rewards
  end










end

