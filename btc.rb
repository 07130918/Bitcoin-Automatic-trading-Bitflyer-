require 'net/http'
require 'uri'
require 'json'
require 'openssl'
require './keyRb'

time = 1
@uri = URI.parse('https://api.bitflyer.com')
@key = API_KEY
@secret = API_SECRET
prices = []

# 現在の価格取得
def get_price
  @uri.path = '/v1/getboard'
  https = Net::HTTP.new(@uri.host, @uri.port)
  https.use_ssl = true
  response = https.get @uri.request_uri
  @response_hash = JSON.parse(response.body)
  return @response_hash['mid_price']
end

# オーダーを出す(BUYorSELL, BTC枚数)
def first_order(order, size)
  timestamp = Time.now.to_i.to_s
  method = 'POST'
  @uri.path = '/v1/me/sendchildorder'
  body =
    '{
    "product_code": "BTC_JPY",
    "child_order_type": "MARKET",
    "side": "' + order + '",
    "size": '+ size +',
    "minute_to_expire": 10000,
    }'
  text = timestamp + method + @uri.request_uri + body
  sign = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), @secret, text)
  options =
    Net::HTTP::Post.new(
      @uri.request_uri,
      initheader = {
        'ACCESS-KEY' => @key,
        'ACCESS-TIMESTAMP' => timestamp,
        'ACCESS-SIGN' => sign,
        'Content-Type' => 'application/json',
      },
    )
  options.body = body
  https = Net::HTTP.new(@uri.host, @uri.port)
  https.use_ssl = true
  response = https.request(options)
  puts response.body
end

# 現在の資産状況
def assets(coin_name)
  timestamp = Time.now.to_i.to_s
  method = 'GET'
  @uri.path = '/v1/me/getbalance'
  text = timestamp + method + @uri.request_uri
  sign = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), @secret, text)
  options =
    Net::HTTP::Get.new(
      @uri.request_uri,
      initheader = {
        'ACCESS-KEY' => @key,
        'ACCESS-TIMESTAMP' => timestamp,
        'ACCESS-SIGN' => sign,
      },
    )
  https = Net::HTTP.new(@uri.host, @uri.port)
  https.use_ssl = true
  response = https.request(options)
  response_hash = JSON.parse(response.body)
  amount = response_hash.find {|n| n["currency_code"] == coin_name}["amount"]
  puts "#{coin_name}資産 #{amount}"
end

while true do
  current_price = get_price
  prices << current_price
  prices.shift(1) if prices.length >= 5
  puts prices
  assets("BTC")
  assets("JPY")
  sleep(time)
end
# first_order('BUY', '0.001')