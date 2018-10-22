class Prosheet
  def self.do
    site = Site.find_by(name: 'PROsheet')
    raise "Site doesn't exist!" if site.nil?
    agent = Mechanize.new
    count = 1
    while true
      url = "https://prosheet.jp/project/list/page:#{count}"
      page = agent.get(url)
      break if page.title == 'プロシート（PROsheet） | フリーランス向け週２日〜のお仕事紹介。'    
      item_urls = page.search('.cmn-column').map{|item| "https://prosheet.jp" + item.attributes['action'].value}
      item_urls.each do |item_url|
        job = Job.find_or_initialize_by(site_id: site.id, key: item_url)
        next if job.persisted?
        crawled_data = self.item(site, item_url)
        next if crawled_data.nil?
        parsed_data = self.parse_data(crawled_data)
        next if parsed_data.nil?
        job.enabled = job.enabled || true
        job.attributes = parsed_data        
        job.save if job.skill_ids.present?
      end
      count += 1
      if count > 2 && Rails.env.dev?
        break
      elsif count > 5 && Rails.env.production?
        break
      end
    end
  end

  def self.item(site, url)
    begin
      agent = Mechanize.new
      page = agent.get(url)
      title = page.at('.cmn-recruit__list--lead').text
      job_type = page.at('body > main > div.breadcrumb > p > a:nth-child(2)').text
      job_type_detail = page.at('body > main > div.breadcrumb > p > a:nth-child(3)').text
      salary = page.at('.pjct-table > tr:nth-child(3)').at('td[2]').text.gsub(/(\t)/,"").gsub(/(\n)/,"")
      working_type = page.at('.pjct-table > tr:nth-child(4)').at('td[4]').text.gsub(/(\t)/,"").gsub(/(\n)/,"")
      working_days = page.at('.pjct-table > tr:nth-child(3)').at('td[4]').text.gsub(/(\t)/,"").gsub(/(\n)/,"")
      location = page.at('.pjct-table > tr:nth-child(4)').at('td[2]').text.gsub(/(\t)/,"").gsub(/(\n)/,"")
      skills = page.at('.js__offerSkillName').try(:text).to_s.split('・')
      detail = page.at('.pjct-table > tr:nth-child(5)').at('td[4]').text.gsub(/(\t)/,"").gsub(/(\n)/,"")
      team_size = page.at('.pjct-table > tr:nth-child(6)').at('td[2]').text.gsub(/(\t)/,"").gsub(/(\n)/,"")
      must_skill = page.at('.pjct-table > tr:nth-child(8)').at('td[2]').text.gsub(/(\t)/,"").gsub(/(\n)/,"")
      ideal_skill =  page.at('.pjct-table > tr:nth-child(8)').at('td[4]').text.gsub(/(\t)/,"").gsub(/(\n)/,"")
      job_data = {title: title, job_type: job_type, job_type_detail: job_type_detail, salary: salary, working_type: working_type, working_days: working_days,
                  location: location, skills: skills, detail: detail, team_size: team_size, must_skill: must_skill, ideal_skill: ideal_skill
                  }      
    rescue => exception
      p exception
      nil
    end
  end

  def self.parse_data(job_data)
    begin
      job_type_id_data = {'エンジニア': 1, 'デザイナー': 2, 'PM': 4, 'ディレクター': 4, 'マーケター': 3, 'その他': 99}
      skill_data = {'PHP': 6, 'Ruby': 3, 'JAVA': 5, 'Java (Android)': 5, 'Kotlin (Android)': 13, 'C#': 7, 'C/C++': 8, 'Node.js': nil, 'Objective-C': 11, 'Swift': 12, 'Go言語': 10, 'Scala': 9, 'Python': 4, 'JavaScript': 2, 'CSS': 1, 'HTML': 1, 'CMS関連': 28, 'MySQL': 15, 'PostgreSQL': 16, 'Oracle': 17, 'MongoDB': nil, 'AWS': 14, 'VB.NET': nil, 'VBA': nil, '[SW] PhotoShop': 27, '[SW] Illustrator': 27, '分析・データマイニング': 25, '広告の運用・検証': 26, 'SEO/SEM': 29, 'プロジェクト管理': 30, '広告（サーチ/ターゲティング）': 26, '広告（リターゲティング）広告（リターゲティング）': 26, '広告（媒体）': 26, 'ソーシャルメディア運用': nil, 'Web解析（アナリティクス等）': nil, '市場調査・分析': nil}

      title = job_data[:title]
      job_type_id = job_type_id_data[job_data[:job_type].to_sym]
      job_type_detail = job_data[:job_type_detail]
      detail = job_data[:detail]
      required_skill = job_data[:must_skill] + "\n" + job_data[:ideal_skill]

      tmp_days = job_data[:working_days].gsub("週 ", "").gsub("日", "").split("･").map(&:to_i)
      min_day = tmp_days.min
      max_day = tmp_days.max

      location = job_data[:location][0, job_data[:location].index('（')]
      skill_ids = job_data[:skills].map{|skill| skill_data[skill.to_sym]}.uniq.compact
      remote_ok = title.include?('リモート') || detail.include?('リモート') || required_skill.include?('リモート')

      if job_data[:salary].include?("月")
        parsed_rewards = job_data[:salary].gsub(/\/|月|円|,/,'').split('〜')
        reward_type = 'month'
        if parsed_rewards.size == 2
          min_reward = parsed_rewards[0].to_f
          max_reward = parsed_rewards[1].to_f
        else
          if job_data[:salary].include?('以上')        
            min_reward = parsed_rewards[0].gsub('以上','').to_f
            max_reward = nil          
          else
            binding.pry
          end
        end

        if max_reward
          average_reward = (max_reward.to_f / (max_day.to_f * 4)).to_i
        else
          average_reward = (min_reward.to_f / (min_day.to_f * 4)).to_i
        end
      else
        parsed_rewards = job_data[:salary].gsub(/\/|日|円|万|,/,'').split('〜')
        reward_type = 'day'
        if parsed_rewards.size == 2
          min_reward = parsed_rewards[0].to_f * 10000
          max_reward = parsed_rewards[1].to_f * 10000
        else
          if job_data[:salary].include?('以上')        
            min_reward = parsed_rewards[0].gsub('以上','').to_f * 10000
            max_reward = nil          
          else
            binding.pry
          end
        end

        average_reward = max_reward || min_reward
      end      

      {title: title, job_type_id: job_type_id, job_type_detail: job_type_detail, detail: detail, 
      required_skill: required_skill, min_day: min_day, max_day: max_day, reward_type: reward_type, min_reward: min_reward, max_reward: max_reward,
      location: location, skill_ids: skill_ids, remote_ok: remote_ok, average_reward: average_reward
      }
    rescue => exception
      p exception
      nil
    end    
  end
end