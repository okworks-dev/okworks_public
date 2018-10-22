class Pebank
  def self.do
    site = Site.find_by(name: 'Pe-BANK')
    raise "Site doesn't exist!" if site.nil?
    agent = Mechanize.new
    count = 0
    skill_hash = []
    while true
      url = "https://pe-bank.jp/work/project?title=&&&&combine=&&sort_by=created&sort_order=DESC&page=#{count}"
      page = agent.get(url)
      break if page.search('.view-empty').text.gsub(/( )/,"").gsub(/(\n)/,"") == '検索結果は0件でした。'    
      item_urls = page.search('.view-content').search('.views-field-title').map{|p| 'https://pe-bank.jp' + p.at('a').values[0]}
      item_urls.each do |item_url|
        job = Job.find_or_initialize_by(site_id: site.id, key: item_url)
        next if job.persisted?
        crawled_data = self.item(site, item_url)
        skill_hash.push crawled_data[:skills]
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
      title = page.at('.page_title').text
      #re =Regexp.new('(【(.*)】)')
      #m = re.match(title)
      #job_type = page.at('body > main > div.breadcrumb > p > a:nth-child(2)').text
      #job_type_detail = m[2]
      salary = page.at('.price1').text.gsub(/(\t)/,"").gsub(/(\n)/,"").gsub(' ', '')
      working_type = page.at('.dlist > dd[10]').text.gsub(/(\t)/,"").gsub(/(\n)/,"")
      # 全て週5日
      working_days = 5
      location = page.at('.dlist > dd[6]').text.gsub(/(\t)/,"").gsub(/(\n)/,"")
      skills = page.at('.dlist > dd[14]').text.split(' ').select{|t| !t.blank? }.select{|t| t != '/'}.map{|s| s.gsub(" ", "")} if !page.at('.dlist > dd[14]').nil?
      detail = page.at('.dlist > dd[2]').text.gsub(/(\t)/,"").gsub(/(\n)/,"")
      #team_size = page.at('.pjct-table > tr:nth-child(6)').at('td[2]').text.gsub(/(\t)/,"").gsub(/(\n)/,"")
      must_skill = page.at('.dlist > dd[4]').text.gsub(/(\t)/,"").gsub(/(\n)/,"")
      #ideal_skill =  page.at('.pjct-table > tr:nth-child(8)').at('td[4]').text.gsub(/(\t)/,"").gsub(/(\n)/,"")
      job_data = {title: title, salary: salary, working_type: working_type, working_days: working_days,
                  location: location, skills: skills, detail: detail, must_skill: must_skill
                  }      
    rescue => exception
      p exception
      p exception.backtrace
      nil
    end
  end

  def self.parse_data(job_data)
    begin
      job_type_id_data = {'アセンブラ': 1, 'VB/VBA': 1, 'インフラ（ネットワーク)': 1, 'コンサルティング': 4, 'Shell(C/B/K)': 1, '検証': 99, 'テスト': 99, 'VC++': 1, 'インフラ（サーバー）': 1, 'ERP': 1, 'ITアーキテクト': 1, 'CSS': 1, 'HTML5': 1, 'Webディレクター': 4, 'PMO': 4, 'PM': 4, 'C#)': 1, '.NET(VB': 1, 'COBOL': 1, 'Perl': 1, 'PHP': 1, 'インフラ（その他）': 1, 'データベース': 1, 'C/C++': 1, 'その他言語': 1, 'JavaScript': 1, 'Python': 1, 'Ruby': 1, 'SQL': 1, 'Android': 1, 'iOS': 1, 'Java': 1}
      skill_data = {'アセンブラ': nil, 'VB/VBA': nil, 'インフラ（ネットワーク)': nil, 'コンサルティング': 30, 'Shell(C/B/K)': nil, '検証': nil, 'テスト': nil, 'VC++': nil, 'インフラ（サーバー）': nil, 'ERP': nil, 'ITアーキテクト': nil, 'CSS': 1, 'HTML5': 1, 'Webディレクター': 30, 'PMO': 30, 'PM': 30, 'C#)': 7, '.NET(VB': nil, 'COBOL': nil, 'Perl': nil, 'PHP': 6, 'インフラ（その他）': nil, 'データベース': nil, 'C/C++': 8, 'その他言語': nil, 'JavaScript': 2, 'Python': 4, 'Ruby': 3, 'SQL': nil, 'Android': 2, 'iOS': 12, 'Java': 2}

      title = job_data[:title]
      # 複数スキルがある場合は、1つ目に記載されているものの優先順位が高いと判断
      job_type_id = job_type_id_data[job_data[:skills][0].to_sym]
      #job_type_detail = job_data[:job_type_detail]
      detail = job_data[:detail]
      required_skill = job_data[:must_skill]

      #tmp_days = job_data[:working_days].gsub("週 ", "").gsub("日", "").split("･").map(&:to_i)
      min_day = 5
      max_day = 5

      location = job_data[:location]
      skill_ids = job_data[:skills].map{|skill| skill_data[skill.to_sym]}.uniq.compact if !job_data[:skills].nil?
      skills = Skill.all
      skills.each do |skill|
        skill_ids.push(skill.id) if (title.to_s + detail.to_s + required_skill.to_s).downcase.include?(skill.name.downcase)
      end

      skill_ids.uniq!

      remote_ok = title.include?('リモート') || detail.include?('リモート') || required_skill.include?('リモート')
      parsed_rewards = job_data[:salary].gsub(/\/|月|円|契約金額|：|:| |￥|¥|,/,'').split('〜')
      reward_type = 'month'
      if parsed_rewards.size == 2 and parsed_rewards[0] != parsed_rewards[1]
        min_reward = parsed_rewards[0].to_f
        max_reward = parsed_rewards[1].to_f
      else
        min_reward = parsed_rewards[0]
        max_reward = nil          
      end

      if max_reward
        average_reward = (max_reward.to_f / (max_day.to_f * 4)).to_i
      else
        average_reward = (min_reward.to_f / (min_day.to_f * 4)).to_i
      end

      {title: title, job_type_id: job_type_id, detail: detail, 
      required_skill: required_skill, min_day: min_day, max_day: max_day, reward_type: reward_type, min_reward: min_reward, max_reward: max_reward,
      location: location, skill_ids: skill_ids, remote_ok: remote_ok, average_reward: average_reward
      }
    rescue => exception
      p exception
      p exception.backtrace
      nil
    end    
  end
end
