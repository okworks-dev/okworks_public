require 'fog/aws'

bucket_name = 'okworks-production'
SitemapGenerator::Sitemap.default_host = 'https://www.okworks.me'
SitemapGenerator::Sitemap.sitemaps_host = "https://s3-ap-northeast-1.amazonaws.com/#{bucket_name}"
SitemapGenerator::Sitemap.sitemaps_path = 'sitemaps/'

SitemapGenerator::Sitemap.adapter = SitemapGenerator::AwsSdkAdapter.new(bucket_name,
  aws_access_key_id: ENV['AWS_ACCESS_KEY_ID'],
  aws_secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'],
  aws_region: 'ap-northeast-1'
)

SitemapGenerator::Sitemap.create do
  add '/'
  add jobs_path
  
  Skill.all.each do |skill|
    add jobs_path + '?' + {'q': {'skills_id_eq': skill.id}}.to_query
  end

  JobType.all.each do |job_type|
    add jobs_path + '?' + {'q': {'job_type_id_eq': job_type.id}}.to_query
  end

  Job.enabled.each do |job|
    add job_path(job)
  end
end
