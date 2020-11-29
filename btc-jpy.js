'use strict';
const ccxt = require('ccxt');
const key = require('./key');

const btcPrice = [];
const numberOfSheets = 0.001; //1回の取引で使うBTC枚数

const sleep = () => {
  return new Promise((resolve) => { setTimeout(() => { resolve(); }, 30000); });
}

(async function () {
  //bitflyer取引所を利用
  let bitflyer = new ccxt.bitflyer(key);
  while (true) {
    const ticker = await bitflyer.fetchTicker('BTC/JPY');
    btcPrice.push(ticker.ask);
    if (btcPrice.length > 4) {
      btcPrice.shift();
    }
    console.log(btcPrice);
    // 上昇を検知
    if (btcPrice[3] > btcPrice[2] && btcPrice[2] > btcPrice[1] && btcPrice[1] > btcPrice[0]) {
        try {
          await bitflyer.createMarketSellOrder('BTC/JPY', numberOfSheets);
          console.log(`上昇傾向を検知,${numberOfSheets}BTC売りました`);
        } catch (e) {
          console.log("BTCがないため売ることができませんでした");
        }
    }
    // 下降を検知
    if (btcPrice[3] < btcPrice[2] && btcPrice[2] < btcPrice[1] && btcPrice[1] < btcPrice[0]) {
        try {
          await bitflyer.createMarketBuyOrder('BTC/JPY', numberOfSheets);
          console.log(`下降傾向を検知,${numberOfSheets}BTC買いました`)
        } catch (e) {
          console.log("BTCがないため買うことができませんでした");
        }
    }
    await sleep();
  }
})();