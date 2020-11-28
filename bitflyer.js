'use strict';
const ccxt = require('ccxt');



(async function () {
  const key = require('./key');
  let bitflyer = new ccxt.bitflyer(key)
  // console.log(bitflyer.id, await bitflyer.fetchTicker('BTC/JPY'))
  // const order = await bitflyer.createMarketSellOrder('BTC/JPY', 0.001);
  const ticker = await bitflyer.fetchTicker('BTC/JPY');
  console.log(ticker)
})();
