'use strict';
// ccxtは100以上の取引所に対応したAPI共有化ライブラリ
const ccxt = require('ccxt');
const key = require('./key');

// 取引所の指定
let bitflyer = new ccxt.bitflyer(key)

const interval = 30000;
const records = [];
const orderPrise = 500;
const orderSize = 0.01;
let orderInfo = null;

const sleep = (timer) => {
  return new Promise(function (resolve) {
    setTimeout(() => { resolve() }, timer)
  })
}

(async function () {
  while (true) {
    // 板情報を取得
    const ticker = await bitflyer.fetchTicker('FX_BTC_JPY');
    records.push(ticker.ask);
    if (records.length > 3) { //現在、30秒前、60秒前の価格がわかればいいため
      records.shift();
    }
    console.log(records);
    if (orderInfo) {
      console.log("latest bid price:" + ticker.bid);
      console.log("order price:" + ticker.bid);
      console.log("差分" + ticker.bid - orderInfo.price);
      if (ticker.bid - orderInfo.price > orderPrise) { //現在の価格と買い注文時の価格がorderPrise円より開いていた場合
        await bitflyer.createMarketSellOrder('FX_BTC_JPY', orderSize);
        orderInfo = null;
        console.log("利益確定しました。", order)
      } else if (ticker.bid - orderInfo.price < - orderPrise) {
        await bitflyer.createMarketSellOrder('FX_BTC_JPY', orderSize);
        orderInfo = null;
        console.log("ロスカットしました。", order)
      }
    } else {
      if (records[2] > records[1] && records[1] > records[0]) { //2>1>0で上昇
        // 買いか売りの注文を出す
        const order = await bitflyer.createMarketBuyOrder('FX_BTC_JPY', orderSize);
        orderInfo = {
          order: order,
          price: ticker.ask,
        }
        console.log("買い注文しました!!", orderInfo);
      }
    }
    await sleep(interval);
  }


  // pass/redefine custom exchange-specific order params: type, amount, price or whatever
  // use a custom order type
  // bitfinex.createLimitSellOrder ('BTC/USD', 1, 10, { 'type': 'trailing-stop' })

})();