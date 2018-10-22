FactoryBot.define do
  factory :job do
    site_id { Site.all.first.id }
    sequence(:title) { |n| "TEST_TITLE_#{n}"}
    sequence(:key) { |n| "https://www.google.com/?hoge=#{n}"}
    enabled { true }
    job_type_id { JobType.all.first.id }
    job_type_detail { 'DBエンジニア' }
    detail { '求人の詳細' }
    required_skill { 'スキル' }
    max_day { 5 }
    min_day { 3 }
    reward_type { 'day' }
    min_reward { 50000 }
    max_reward { 80000 }
    location { '渋谷' }
    remote_ok { true }
    average_reward { 30000 }
  end
end