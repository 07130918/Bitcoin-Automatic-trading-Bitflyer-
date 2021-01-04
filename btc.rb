require 'net/http'
require 'date'
require 'uri'
require 'json'
require 'openssl'
require './keyRb'

@uri = URI.parse('https://api.bitflyer.com')
@https = Net::HTTP.new(@uri.host, @uri.port)
@https.use_ssl = true
@timestamp = Time.now.to_i.to_s
@key = API_KEY
@secret = API_SECRET

interval = 120 #秒
@prices = []

# 関数たち
# 時刻管理
def trade_time
  nowTime = DateTime.now
  @btc_text.puts "#{nowTime.hour}時#{nowTime.minute}分#{nowTime.second}秒現在"
end

# 現在の価格取得
def get_price
  @uri.path = '/v1/getboard'
  response = @https.get @uri.request_uri
  response_hash = JSON.parse(response.body)
  return response_hash['mid_price'].floor
end

# 現在の資産状況を取得
def assets(coin_name)
  method = 'GET'
  @uri.path = '/v1/me/getbalance'
  text = @timestamp + method + @uri.request_uri
  sign = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), @secret, text)
  options =
    Net::HTTP::Get.new(
      @uri.request_uri,
      initheader = {
        'ACCESS-KEY' => @key,
        'ACCESS-TIMESTAMP' => @timestamp,
        'ACCESS-SIGN' => sign,
      },
    )
  response = @https.request(options)
  response_hash = JSON.parse(response.body)
  amount = response_hash.find { |n| n['currency_code'] == coin_name }['amount']
  return coin_name, amount
end

# 総資産(BTC,JPY,BTC+JPY)
def jpy_conversion
  b_name, b_amount = assets('BTC')
  j_name, j_amount = assets('JPY')
  @btc_text.puts "#{b_name}: #{b_amount}枚"
  @btc_text.puts "#{j_name}: #{j_amount.to_i}円"
  @btc_text.puts "日本円換算の総資産は #{
                   (get_price * b_amount + j_amount).to_i
                 }円 です"
end

# オーダーを出す(BUYorSELL, BTC枚数)
def first_order(order, size)
  method = 'POST'
  @uri.path = '/v1/me/sendchildorder'
  body =
    '{
    "product_code": "BTC_JPY",
    "child_order_type": "MARKET",
    "side": "' + order +
      '",
    "size": ' + size +
      ',
    "minute_to_expire": 10000,
    }'
  text = @timestamp + method + @uri.request_uri + body
  sign = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), @secret, text)
  options =
    Net::HTTP::Post.new(
      @uri.request_uri,
      initheader = {
        'ACCESS-KEY' => @key,
        'ACCESS-TIMESTAMP' => @timestamp,
        'ACCESS-SIGN' => sign,
        'Content-Type' => 'application/json',
      },
    )
  options.body = body
  response = @https.request(options)
  response_status = JSON.parse(response.body)

  # 取引成功
  if response_status.include?('child_order_acceptance_id')
    @btc_text.puts "取引成功  BTC#{size}枚#{order}しました"
  end

  # 取引失敗
  if response_status['status'] == -200
    if order == 'SELL'
      @btc_text.puts "現在BTC#{size}枚売れるほどBTCを持っていません"
    else
      #買えない状況
      @btc_text.puts "現在BTC#{size}枚買えるほどJPYを持っていません"
    end
  end
end

# 状況を判断して売るか買う関数
def buy_or_sell
  # 上昇傾向
  if @prices[3] > @prices[2] && @prices[2] > @prices[1] &&
       @prices[1] > @prices[0]
    begin
      first_order('SELL', '0.001')
    rescue => e
      @btc_text.puts e
      @btc_text.puts 'buy_or_sell関数 SELLでエラー'
    ensure
      trade_time
      jpy_conversion
    end
  end

  # 下降傾向
  if @prices[3] < @prices[2] && @prices[2] < @prices[1] &&
       @prices[1] < @prices[0]
    begin
      first_order('BUY', '0.001')
    rescue => e
      @btc_text.puts e
      @btc_text.puts 'buy_or_sell BUYでエラー'
    ensure
      trade_time
      jpy_conversion
    end
  end
end

# 永久駆動
while true
  begin
    @btc_text = File.open('btc.txt', 'a')
    @prices << get_price
    @prices.shift(1) if @prices.length >= 5
    @btc_text.puts "#{@prices}"
    buy_or_sell if @prices.length >= 4
    sleep(interval)
  rescue => e
    @btc_text.puts e
    @btc_text.puts 'while trueでエラー発生 処理移行'
    sleep(interval)
    next
  ensure
    @btc_text.close
  end
end
