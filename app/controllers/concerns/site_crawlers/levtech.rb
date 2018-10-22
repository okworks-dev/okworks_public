class Levtech
  def self.do
    site = Site.find_by(name: 'レバテックフリーランス')
    raise "Site doesn't exist!" if site.nil?
    agent = Mechanize.new
    count = 1
    while true
      url = "https://freelance.levtech.jp/project/search/#{'p' + count.to_s if count > 1}"
      begin
        page = agent.get(url)
        item_urls = page.search('.js-link_rel').map{|a| 'https://freelance.levtech.jp' + a.attributes['href'].value}
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
      rescue Mechanize::ResponseCodeError => e
        break
      end
    end
  end

  def self.fetch_row(obj, key) 
    if key == '言語' || key == 'OS' || key == 'DB' || key == 'ポジション' || key == 'フレームワーク'
      text = obj.search('a').map{|a| a.text}
    elsif key == '最寄り駅' || key == '特徴'
      text = obj.children.text.gsub(/\n| /,'')
    elsif key == 'その他ツール'
      text = obj.children.text.gsub(/\n| /,'').split(' ,').map{|text| text.gsub("\u00A0", "")}
    else      
      text = obj.children.text
    end
    text
  end

  def self.item(site, url)
    begin
      agent = Mechanize.new
      page = agent.get(url)
      if page.at('.project__ttl').children[1].class == Nokogiri::XML::Element
        title = page.at('.project__ttl').children[2].text.gsub(/\n/,'').gsub('                ','').gsub('    ','')
      else
        title = page.at('.project__ttl').children[0].text.gsub(/\n/,'').gsub('                ','').gsub('    ','')
      end      
      table_data = {}
      rows = page.at('body > div.l-container > div.l-column.l-column--subpage > section.project > div > div.table').search('div.table__row')
      rows.each do |row|
        if row.search('p').size == 2
          key = row.search('p')[0].children.text
          table_data[key] = self.fetch_row(row.search('p')[1], key)        
        else
          first_key = row.search('p')[0].children.text          
          second_key = row.search('p')[2].children.text
          first_key = '精算条件' if first_key.include?('精算条件')
          second_key = '精算基準時間' if second_key.include?('精算基準時間')
          table_data[first_key] = self.fetch_row(row.search('p')[1], first_key)
          table_data[second_key] = self.fetch_row(row.search('p')[3], second_key)
        end
      end      
      job_type = 'エンジニア'
      salary = page.at('body > div.l-container > div.l-column.l-column--subpage > section.project > div > div.project__body__head > div.projectSummary > ul > li:nth-child(1)').children[1].text
      salary_range = page.at('body > div.l-container > div.l-column.l-column--subpage > section.project > div > div.project__body__head > div.projectSummary > ul > li:nth-child(1)').children[2].text.gsub(/ |／/,'')[0]
      job_data = {title: title, job_type: job_type, salary: salary, salary_range: salary_range, table_data: table_data}
    rescue => exception
      binding.pry
      p exception
      nil
    end
  end

  def self.parse_data(job_data)
    begin
      skill_data = {'Java': 5,'Ruby': 3,'Scala': 9,'PostgreSQL': 16,'AWS': 14,'JIRA': nil,'GitHub': nil,'Rails': nil,'JavaScript': 2,'PHP': 6,'CSS': 1,'HTML': 1,'Oracle': 17,'MySQL': 15,'Git': nil,'Jenkins': nil,'Backlog': nil,'Redmine': nil,'Docker': nil,'Node.js': nil,'Laravel': nil,'Swift': 12,'Hadoop': nil,'Hive': nil,'Objective-C': 11,'C#': 7,'C#.NET': nil,'SQL Server': nil,'C++': 8,'Python': 4,'SQL': nil,'Unity': nil,'React': nil,'Shell': nil,'SharePoint': nil,'Ansible': nil,'ABAP': nil,'jQuery': 2,'Go言語': 10,'Django': nil,'JP1': nil,'SAS': nil,'Tableau': nil,'Symfony': nil,'VB.NET': nil,'VC++': nil,'C言語': 8,'VC': nil,'Access': nil,'VBScript': nil,'VB': nil,'Apache': nil,'Tomcat': nil,'VMware': nil,'Citrix': nil,'Flask': nil,'Redis': nil,'MongoDB': nil,'Backbone.js': nil,'Kotlin': 13,'SQLite': nil,'AngularJS': nil}
      title = job_data[:title]
      job_type_id = 1
      job_type_detail = job_data[:table_data]['ポジション'].try(:join,', ')
      detail = job_data[:table_data]['職務内容']
      required_skill = job_data[:table_data]['必須スキル'].to_s
      required_skill = required_skill + "\n\n" + job_data[:table_data]['歓迎スキル'] if job_data[:table_data]['歓迎スキル']
      location = job_data[:table_data]['最寄り駅']
      remote_ok = title.include?('リモート') || detail.include?('リモート') 
      skill_ids = []
      job_data[:table_data]['言語'].each{|skill| skill_ids.push(skill_data[skill.to_sym])} if job_data[:table_data]['言語']
      job_data[:table_data]['DB'].each{|skill| skill_ids.push(skill_data[skill.to_sym])} if job_data[:table_data]['DB']
      job_data[:table_data]['その他ツール'].each{|skill| skill_ids.push(skill_data[skill.to_sym])} if job_data[:table_data]['その他ツール']
      job_data[:table_data]['フレームワーク'].each{|skill| skill_ids.push(skill_data[skill.to_sym])} if job_data[:table_data]['フレームワーク']
      skill_ids = skill_ids.uniq.compact
      
      if job_data[:salary_range].include?("月")
        parsed_reward = job_data[:salary].gsub(/,|円/,'').to_i
        reward_type = 'month'
        min_reward = nil
        max_reward = parsed_reward
        if job_data[:table_data]['精算基準時間'].nil?
          min_day = 5
          max_day = 5
          average_reward = (max_reward.to_f / (8 * 22).to_f).to_i
        else
          tmp_hours = job_data[:table_data]['精算基準時間'].gsub(/時間| |　/,'').split('～').map(&:to_i)
          min_day = ((tmp_hours[0].to_f / 8.0) / 4.0).floor
          max_day =  ((tmp_hours[1].to_f / 8.0) / 4.0).floor
          max_day = 5 if max_day > 5
          average_reward = ((max_reward.to_f / tmp_hours[1].to_f) * 8).to_i
        end
      else
        # 月以外の対応は後回しで
        raise "Other than month are not supported now! I need to support later...."
      end      

      {title: title, job_type_id: job_type_id, job_type_detail: job_type_detail, detail: detail, 
      required_skill: required_skill, min_day: min_day, max_day: max_day, reward_type: reward_type, min_reward: min_reward, max_reward: max_reward,
      location: location, skill_ids: skill_ids, remote_ok: remote_ok, average_reward: average_reward
      }
    rescue => exception
      p exception
      p exception.backtrace[0]
      nil
    end    
  end
end