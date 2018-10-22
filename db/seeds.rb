# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

sites = [{name: 'ITプロパートナーズ'}, {name: 'PROsheet'}, {name: 'Midworks'}, {name: 'Pe-BANK'}, {name: 'レバテックフリーランス'}]
sites.each do |site|
  new_site = Site.find_or_create_by(name: site[:name])
end

job_types = [{id: 1, name: 'エンジニア'}, 
             {id: 2, name: 'デザイナー'}, 
             {id: 3, name: 'マーケター'}, 
             {id: 4, name: 'ディレクター'}, 
             {id: 99, name: 'その他'}]
             
job_types.each do |job_type|
  JobType.find_or_create_by(job_type)
end

skills = [{id: 1, name: 'HTML/CSS'},
          {id: 2, name: 'Javascript'},
          {id: 3, name: 'Ruby'},
          {id: 4, name: 'Python'},
          {id: 5, name: 'Java'},
          {id: 6, name: 'PHP'},
          {id: 7, name: 'C#'},
          {id: 8, name: 'C/C++'},
          {id: 9, name: 'Scala'},
          {id: 10, name: 'Go'},
          {id: 11, name: 'Objective-C'},
          {id: 12, name: 'Swift'},
          {id: 13, name: 'Kotlin'},
          {id: 14, name: 'AWS'},
          {id: 15, name: 'MySQL'},
          {id: 16, name: 'PostgreSQL'},
          {id: 17, name: 'Oracle'},
          {id: 18, name: 'Webデザイン'},
          {id: 19, name: 'HTMLコーディング'},
          {id: 20, name: 'イラストレーター'},
          {id: 21, name: 'UI/UXデザイン'},
          {id: 22, name: 'Webディレクション'},
          {id: 23, name: '事業責任者'},
          {id: 24, name: '集客/マーケティング'},
          {id: 25, name: '分析/データマイニング'},
          {id: 26, name: '広告運用/検証'},
          {id: 27, name: 'Photoshop/Illustrator'},
          {id: 28, name: 'WordPress'},
          {id: 29, name: 'SEO/SEM'},
          {id: 30, name: 'PM（プロジェクト管理）'}]
skills.each do |skill|
  Skill.find_or_create_by(skill)
end
