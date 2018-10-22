Rails.application.routes.draw do
  get 'sitemap', to: redirect('https://okworks-production.s3-ap-northeast-1.amazonaws.com/sitemaps/sitemap.xml.gz')
  post 'subscriptions/create'
  root 'home#index'
  resources :jobs
end
