module ApplicationHelper
  def default_meta_tags
    {
      site: 'OKWorks',
      title: '日本最大のIT系フリーランス案件/求人検索サービス',
      description: 'OKWorks（オーケーワークス）は、日本最大のIT系フリーランス案件/求人検索サービスです。週3日などのフレキシブルな働き方、リモート可能、高単価を実現するIT系の案件/求人を探すことが可能です。',
      canonical: request.original_url,
      reverse: true,
      separator: '|',
      icon: [
        #{ href: image_url('favicon.ico') },
        #{ href: image_url('icon.jpg'), rel: 'apple-touch-icon', sizes: '180x180', type: 'image/jpg' },
      ],
      og: {
        site_name: '案件/求人',
        title: '日本最大のIT系フリーランス案件/求人検索サービス',
        description: 'OKWorks（オーケーワークス）は、日本最大のIT系フリーランス案件/求人検索サービスです。週3日などのフレキシブルな働き方、リモート可能、高単価を実現するIT系の案件/求人を探すことが可能です。',
        type: 'website',
        url: request.original_url,
        image: image_url('ogp.jpg'),
        locale: 'ja_JP',
      },
      twitter: {
        card: 'summary_large_image',
        site: '@codeq_official',
      }
    }
  end
end