# Bitcoin Automatic trading with Bitflyer
Bitcoinの自動売買プログラムです。現在は現物取引にのみ対応しておりFX,先物には対応しておりません  
このプログラムは24時間稼働し続けています  

稼働させているファイルはbtc-jpy.jsです  

![スクリーンショット 2020-11-29 144348](https://user-images.githubusercontent.com/70265286/100534539-5da99000-3253-11eb-9cd6-b62c14f8c919.png)
  
**npm**  
- ccxt <https://github.com/ccxt/ccxt>  
100以上の仮想通貨取引所に対応している自動化ライブラリ  
  
- forever  
24h自動稼働させるためのモジュール  

``` 
let bitflyer = new ccxt.bitflyer(key);  
```
対応している取引所を指定する必要があります  
keyにはAPIキー,秘匿にしておくべきキーが格納されています　　


注)また2020年5月1日までに本人確認が取れないユーザーはFXができないそうです　　
<img width="581" alt="スクリーンショット 2020-11-29 144142" src="https://user-images.githubusercontent.com/70265286/100534549-83cf3000-3253-11eb-9174-1bb79e9baf72.png">

　　
