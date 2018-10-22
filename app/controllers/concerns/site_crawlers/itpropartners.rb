class Itpropartners
  def self.do
    site = Site.find_by(name: 'ITプロパートナーズ')
    raise "Site doesn't exist!" if site.nil?
    agent = Mechanize.new
    count = 1
    while true
      url = "https://itpropartners.com/top?page=#{count}"
      page = agent.get(url)
      break if page.at('noContent')
      item_urls = page.search('.project_ttlLink').map{|item| 'https://itpropartners.com' + item.attributes['href'].text}
      item_urls.each do |item_url|
        begin
          job = Job.find_or_initialize_by(site_id: site.id, key: item_url)
          next if job.persisted?
          crawled_data = self.item(site, item_url)
          next if crawled_data.nil?
          parsed_data = self.parse_data(crawled_data)
          next if parsed_data.nil?        
          job.enabled = job.enabled || true
          job.attributes = parsed_data
          job.save if job.skill_ids.present?
        rescue => exception
          next
        end        
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
      title = page.at('.project_ttl').text
      job_type = page.at('.project__category').text
      job_type_detail = ""
      skills = page.at('.project__tag').search('.tag__item').map{|item| item.text}
      salary = page.at('.project__subTtl').text.split('  /  ')[0]
      working_days = page.at('.project__subTtl').text.split('  /  ')[1]
      location = page.at('.project__table').at('tr[6] > td').text
      detail = page.at('.project__block.project__block--first > .project__block__text').text
      team_size = ""
      working_type = ""
      must_skill = page.at('.project_body > .project__block[2]').search('.project__block__text').map{|item| item.text}.join
      ideal_skill = ""
      remote_ok = page.at('.project__remoteTag').nil? ? false : true
      job_data = {title: title, job_type: job_type, job_type_detail: job_type_detail, salary: salary, working_type: working_type, working_days: working_days,
        location: location, skills: skills, detail: detail, team_size: team_size, must_skill: must_skill, ideal_skill: ideal_skill, remote_ok: remote_ok
        }
    rescue => exception
      p exception
    end
  end

  def self.parse_data(job_data)
    job_type_id_data = {'エンジニア': 1, 'デザイナー': 2, 'マーケター': 3, 'プロデューサー': 4}
    skill_data = {'Go': 10, 'Javascript': 2, 'MySQL': 15, 'AWS': 14, 'Ruby': 3, 'HTML/CSS': 1, 'CSS': 1, 'Java': 5, 'PostgreSQL': 16, 'Python': 4, 'Objective-C': 11, 'Swift': 12, 'Java(Android)': 5, 'Webデザイナー': 18, 'HTMLコーダー': 19, 'イラストレーター': 20, 'UI/UXデザイナー': 21, 'Sketch': nil, 'Kotlin': 13, 'Webディレクション': 22, '事業責任者': 23, 'PHP': 6, 'Photoshop/Illustrator': 27, 'ITコンサルタント': 22, 'PM': 30, '集客/マーケティング': 24, '分析/データマイニング': 25, 'Oracle': 17, '広告運用/検証': 26, 'リスティング広告(Google/Yahoo!)': 26, 'Scala': 9, 'WordPress': 28, 'SEO/SEM': 29, 'C#': 7, 'C/C++': 8, 'セキュリティ・コンサルタント': nil, 'UNITY': nil, 'Webプロデュース': nil}
    title = job_data[:title]
    job_type_id = job_type_id_data[job_data[:job_type].to_sym]
    job_type_detail = ""
    detail = job_data[:detail]

    required_skill = job_data[:must_skill]
                      .gsub(/\n                                            /,'')
                      .gsub('                     ','')
                      .gsub('                   ','')
    location = job_data[:location]

    tmp_day = job_data[:working_days].gsub(/週に|日勤務/,'').to_i
    min_day = tmp_day
    max_day = tmp_day     

    tmp_reward = job_data[:salary].gsub(/月収 |万円/,'').split('〜').map(&:to_i)
    reward_type = 'month'
    min_reward = tmp_reward[0] * 10000
    max_reward = tmp_reward[1] * 10000
    average_reward = (max_reward.to_f / (max_day.to_f * 4)).to_i

    skill_ids = job_data[:skills].map{|skill| skill_data[skill.to_sym]}.uniq.compact
    remote_ok = job_data[:remote_ok]

    {title: title, job_type_id: job_type_id, job_type_detail: job_type_detail, detail: detail, 
      required_skill: required_skill, min_day: min_day, max_day: max_day, reward_type: reward_type, min_reward: min_reward, max_reward: max_reward,
      location: location, skill_ids: skill_ids, remote_ok: remote_ok, average_reward: average_reward
      }
  end
end