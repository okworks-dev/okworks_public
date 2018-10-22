namespace :update do
  task jobs: :environment do
    # task
    Crawler.all
  end
end
