class Midworks
  def self.do
    site = Site.find_by(name: 'Midworks')
    raise "Site doesn't exist!" if site.nil?
    agent = Mechanize.new
    count = 1
    while true
      url = "https://mid-works.com/project?page=#{count}"
      page = agent.get(url)
      break if page.search('h3')[2].text == 'に関する求人・案件が見つかりませんでした。'    
      item_urls = page.search('.project__col-main').first.search('a').map{|a| "https://mid-works.com" + a.attributes['href'].value}
      item_urls = item_urls.select{|a| a.include?('detail')}
      tags = page.search('.project__col-metadata').map{|p| p.search('div').children.map{ |j| j.text}}
      item_urls.each_with_index do |item_url, i|
        job = Job.find_or_initialize_by(site_id: site.id, key: item_url)
        next if job.persisted?
        crawled_data = self.item(site, item_url)
        next if crawled_data.nil?
        parsed_data = self.parse_data(crawled_data, tags, i)
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
      title = page.at('.project-single__title').text
      #job_type = page.at('body > main > div.breadcrumb > p > a:nth-child(2)').text
      #job_type_detail = page.at('body > main > div.breadcrumb > p > a:nth-child(3)').text
      salary = page.search('.project-single__row')[2].search('.project-single__meta')[0].text.gsub(/(\t)/,"").gsub(/(\n)/,"")
      #working_type = page.at('.project-single__meta-style > .project-single__meta').text.gsub(/(\t)/,"").gsub(/(\n)/,"")
      working_days = page.search('.project-single__row')[2].search('.project-single__meta')[2].text.gsub(/(\t)/,"").gsub(/(\n)/,"")
      location = page.search('.project-single__row')[2].search('.project-single__meta')[1].text.gsub(/(\t)/,"").gsub(/(\n)/,"")
      #skills = page.at('.js__offerSkillName').try(:text).to_s.split('・')
      detail = page.search('.project-single__text')[0].text.gsub(/(\t)/,"").gsub(/(\n)/,"")
      #team_size = page.at('.pjct-table > tr:nth-child(6)').at('td[2]').text.gsub(/(\t)/,"").gsub(/(\n)/,"")
      must_skill = page.search('.project-single__text')[1].text.gsub(/(\t)/,"").gsub(/(\n)/,"")
      ideal_skill = page.search('.project-single__text')[2].text.gsub(/(\t)/,"").gsub(/(\n)/,"")
      job_data = {title: title, salary: salary, working_days: working_days,
                  location: location, detail: detail, must_skill: must_skill, ideal_skill: ideal_skill
                  }      
    rescue => exception
      p exception
      nil
    end
  end

  def self.parse_data(job_data, tags, i)
    begin
      job_type_id_data = {'フロントエンドエンジニア': 1, 'ゲームプログラマ': 1, 'LAMP系エンジニア': 1, 'ソーシャル系エンジニア': 1, 'バックエンドエンジニア（サーバーサイド）': 1, 'Webデザイナー': 2, 'イラストレーター': 2, 'UIデザイナー': 2, 'Java系エンジニア': 1, 'スマホアプリ開発（ネイティブ）': 1, '運用・監視担当': 99, 'サーバーエンジニア': 1}
      #job_type_detail_id_data = {'エンジニア': 1, 'デザイナー': 2, 'PM': 4, 'ディレクター': 4, 'マーケター': 3, 'その他': 99}
      skill_data = { 'HTML5': 1, 'CSS3': 1, 'Angular.JS': nil, 'iOS': 12, 'iOS（Objective-C）': 11, 'iOS（Swift）': 12, 'MySQL': 15, 'PHP': 6, 'JavaScript': 2, 'Ruby': 3, 'C++': 8, 'Unity': nil, 'Linux': nil, 'Apatche': nil, 'Android': 5, 'Android（Java）': 5, 'Git': nil, 'Illustrator': 27, 'Photoshop': 27, 'LAMP': nil, 'FuelPHP': 6, 'PostgreSQL': 16, 'SQL': nil, 'Ruby on Rails': 3, 'Xcode': nil, 'GitHub': nil, 'Java': 5, 'Windows Server': nil, 'HULFT': nil, 'Jenkins': nil, 'memcached': nil, 'Oracle': 17, 'VB': nil, 'Active Directory': nil }

      title = job_data[:title]
      job_type_id = 99
      job_type_detail = ''
      skill_ids = []
      tags[i].each do |tag|
        job_type_id = job_type_id_data[tag.to_sym] if job_type_id == 99
        job_type_detail = tag + ',' if job_type_id_data[tag.to_sym]
        skill_ids.push(skill_data[tag.to_sym])
        skill_ids.uniq! if skill_ids.present?
      end
      job_type_detail.chop!
      detail = job_data[:detail]
      required_skill = job_data[:must_skill] + "\n" + job_data[:ideal_skill]

      tmp_days = job_data[:working_days].gsub("時間", "").split("〜").map(&:to_i)
      min_day = (tmp_days.min / (8 * 4)).round
      max_day = (tmp_days.max / (8 * 4)).round
      max_day = 5 if max_day >= 5

      location = job_data[:location]
      remote_ok = false

      parsed_rewards = job_data[:salary].gsub('万円', '').split('〜')
      reward_type = 'month'
      if job_data[:salary][0] == '〜'
        max_reward = parsed_rewards[1].to_i * 10000
      else
        min_reward = parsed_rewards[0].to_i * 10000
        max_reward = parsed_rewards[1].to_i * 10000
      end

      if max_reward
        average_reward = (max_reward.to_f / (max_day.to_f * 4)).to_i
      else
        average_reward = (min_reward.to_f / (min_day.to_f * 4)).to_i
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
