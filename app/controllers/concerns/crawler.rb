class Crawler
  def self.all
    # 乱用し各サービスに負荷がかかることを防ぐために、一旦動かない設定としてあります。
    # 下記ソースをカスタマイズの上、各サービスの負荷を考えた上でご利用ください。
    if false
      p 'prosheet'    
      Prosheet.do

      p 'itpro'
      Itpropartners.do

      p 'midworks'
      Midworks.do

      p 'pebank'
      Pebank.do

      p 'levtech'
      Levtech.do
    end
  end
end
