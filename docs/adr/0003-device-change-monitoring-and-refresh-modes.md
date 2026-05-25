# Device Change Monitoring と Background / Foreground Refresh

v0.2 では Core Audio のプロパティ変更通知で Device List Refresh を起動する（常時ポーリングは行わない）。監視対象は入力デバイス一覧の変化と Default Input Device の変化の両方とする。Refresh には **Background Refresh**（メニュー非表示時: `loading` にせず Store と Menu Bar 表示のみ更新）と **Foreground Refresh**（メニュー表示中: v0.1 どおり Device List Loading）の2経路を設ける。メニュー表示時は直近の Background Refresh 以降に変更がなければ Loading を出さず即一覧とし、Manual Refresh は常に Foreground Refresh とする。

v0.1 は毎回 `refresh()` で `listState = .loading` とし、メニューでは stale list を出さない方針だった。v0.2 で常時監視と Menu Bar Label を足すと、バックグラウンドでも Refresh が走る。同じ経路のままでは USB 抜き差しのたびにメニューバー表示がちらつき、メニューを開くたびに「取得中…」が出て監視の意味が薄れる。Loading 禁止は「ユーザーがメニューを見ているとき」に限定し、閉じているときは静かに更新するトレードオフを取った。鮮度と Manual Refresh の明示性のため、ユーザー操作の再読み込みと、メニュー表示中の未取得・変更ありの場合だけ Foreground に残す。
