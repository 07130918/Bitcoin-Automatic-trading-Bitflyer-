// bitflyer専用特殊注文
'use strict';
// ccxtは100以上の取引所に対応したAPI共有化ライブラリ
const ccxt = require('ccxt');

(async function () {
  const key = require('./key');
  new ccxt.bitflyer(key)
  // private+httpリクエスト+関数名で利用するルール
  await this.privatePostSendparentorder({
    "order_method": "IFDOCO",
    "minute_to_expire": 10000,
    "time_in_force": "GTC",
    "parameters": [{
      "product_code": "FX_BTC_JPY",
      "condition_type": "LIMIT",
      "side": "BUY",
      "price": 1795000,
      "size": 0.01
    },
    {
      "product_code": "FX_BTC_JPY",
      "condition_type": "LIMIT",
      "side": "SELL",
      "price": 1795500,
      "size": 0.01
    },
    {
      "product_code": "FX_BTC_JPY",
      "condition_type": "STOP",//いくらのタイミングで売りを出すか
      "side": "SELL",
      "trigger_price": 1795500,
      "size": 0.01
    }]
  });
})();
