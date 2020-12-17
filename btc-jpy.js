"use strict";
const ccxt = require("ccxt");
const key = require("./key");

const btcPrice = [];
const numberOfSheets = 0.001; //1回の取引で使うBTC枚数
const interval = 300000;

const sleep = (interval) => {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve();
    }, interval);
  });
};

(async function () {
  //bitflyer取引所を利用
  let bitflyer = new ccxt.bitflyer(key);
  let date = new Date().toLocaleString({ timeZone: "Asia/Tokyo" });

  while (true) {
    try {
      const ticker = await bitflyer.fetchTicker("BTC/JPY");
      btcPrice.push(ticker.ask);
      if (btcPrice.length > 4) {
        btcPrice.shift();
      }
      console.log(btcPrice);
      // 上昇を検知
      if (
        btcPrice[3] > btcPrice[2] &&
        btcPrice[2] > btcPrice[1] &&
        btcPrice[1] > btcPrice[0]
      ) {
        try {
          await bitflyer.createMarketSellOrder("BTC/JPY", numberOfSheets);
          console.log(`${date} 上昇傾向を検知,${numberOfSheets}BTC売りました`);
        } catch (e) {
          console.log(
            "上昇傾向を検知しましたがBTCがないため売ることができませんでした"
          );
        }
      }
      // 下降を検知
      if (
        btcPrice[3] < btcPrice[2] &&
        btcPrice[2] < btcPrice[1] &&
        btcPrice[1] < btcPrice[0]
      ) {
        try {
          await bitflyer.createMarketBuyOrder("BTC/JPY", numberOfSheets);
          console.log(`${date} 下降傾向を検知,${numberOfSheets}BTC買いました`);
        } catch (e) {
          console.log(
            "下降傾向を検知しましたがJPYがないため買うことができませんでした"
          );
        }
      }
    } catch (e) {
      //10時間ほど経つとfetchTicker関数は接続エラーを起こすためエラーハンドリング
      console.log("await bitflyer.fetchTicker('BTC/JPY');でエラー発生");
      console.log(`エラー発生時刻: ${date}`);
      await sleep(interval);
      continue;
    }
    await sleep(interval);
  }
})();
