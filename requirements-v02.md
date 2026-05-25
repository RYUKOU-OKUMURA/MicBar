# MicBar 要件定義書（v0.2）

> **正本**: 本ファイルが v0.2 の要件の単一ソースです。  
> **前提**: [requirements-v01.md](./requirements-v01.md)（v0.1 完了）  
> **用語**: [CONTEXT.md](./CONTEXT.md)  
> **実装方針**: [docs/adr/](./docs/adr/) — 特に [ADR-0003](./docs/adr/0003-device-change-monitoring-and-refresh-modes.md)

## 1. v0.2 の目的

BOSS 自分用に、「毎日の入力切替」を **常駐・抜き差し追従・見える化** まで揃える。v0.1 の切替コアは変えず、その上に載せる。

主目的は引き続き **ショートカットを増やさず、見て選ぶ**（US-004）。v0.2 はそのための常駐基盤であり、ショートカット・通知・配布パッケージは含めない。

## 2. v0.2 スコープ

### 2.1 含めるもの

| ID | 内容 |
|----|------|
| F-009 | **Login Item** — Mac ログイン時の自動起動（メニュー内トグル、デフォルトオフ） |
| F-007 | **Device Change Monitoring** — Core Audio 通知による自動 Device List Refresh |
| F-013 | **Menu Bar Label** — 現在の Display Name の常時表示（ON/OFF、デフォルトオフ） |
| F-014 | **MicBar Settings** — 上記2設定をメニュー内フッターに置く（別ウィンドウなし） |

v0.1 の F-001〜F-008, F-010 は維持する。Device List Refresh の追加タイミングは §4 を参照。

### 2.2 含めないもの

| 項目 | 扱い |
|------|------|
| 署名・DMG・Notarization 配布 | **v1.0** |
| グローバルショートカット（F-012） | **見送り**（製品方針と矛盾） |
| macOS 通知（F-011） | **見送り** |
| Switch Error の UI 改善（失敗理由の区別等） | **見送り**（v0.1 定型文のまま） |
| エラー UI 改善全般 | v0.2 に含めない |
| Per-App Input Setting の説明 UI | 引き続き範囲外 |

## 3. ユーザーストーリー（v0.2 追加分）

### US-005: ログイン後も MicBar を忘れない

Mac ログイン後、手動で起動しなくても Menu Bar Icon が現れ、いつもどおり入力デバイスを切り替えたい。初回は Login Item を明示的にオンにする（デフォルトオフ）。

### US-006: 抜き差し後に一覧が古くならない

USB や AirPods の接続・切断、システム設定でのデフォルト変更後、メニューを開く前から Store と（任意の）Menu Bar Label がおおむね最新であってほしい。取りこぼしたときは Manual Refresh でよい。

### US-007: メニューバーを見るだけで現在デバイスが分かる

会議前など、メニューを開かずに現在の Default Input Device を確認したい。Menu Bar Label をオンにしたときだけ、アイコン横に（切り詰めた）Display Name を常時表示する。

## 4. 機能要件

### F-009: Login Item

* メニュー内トグル「ログイン時に起動」。初期値 **オフ**
* オン操作時のみ `SMAppService` で Login Item を登録。オフで解除
* macOS の「ログイン項目」から外された場合、**起動時**および**メニュー表示時**に実状態を読みトグル表示を同期する
* v0.1 の Background App 方針は維持（Dock 非表示）

### F-007: Device Change Monitoring

* 常時ポーリングは行わない（NF-002 継承）
* Core Audio プロパティ変更通知で Device List Refresh を起動する
* 監視対象:
  * 入力デバイス一覧の変化（接続・切断等）
  * **Default Input Device** の変化（システム設定など MicBar 外での変更を含む）
* 通知時の Refresh は [ADR-0003](./docs/adr/0003-device-change-monitoring-and-refresh-modes.md) に従う **Background Refresh**（メニュー非表示時）
* 自動検知が効かない場合でも Manual Refresh（Foreground）で更新できること

**Device List Refresh タイミング（v0.2 全体）**

| タイミング | Refresh 種別 |
|-----------|----------------|
| アプリ起動時 | Foreground（v0.1 同様） |
| メニュー表示時 | 変更がなければ Loading なし。変更あり・未取得なら Foreground |
| Device Change Monitoring 通知時 | Background（メニュー表示中は Foreground） |
| Manual Refresh | 常に Foreground |
| 切替成功時 | v0.1 同様（Foreground） |

### F-013: Menu Bar Label

* MicBar Settings のトグル「メニューバーにデバイス名を表示」。初期値 **オフ**
* オン時: Menu Bar Icon 横に現在の Default Input Device の **Display Name**（切り詰め可）
* 長い名前はメニューバー幅のため省略し、**全文は Menu Bar Tooltip**（ホバー）で示す
* `currentDevice` が無いとき（取得失敗・0件・起動直後等）は **ラベル文字を出さずアイコンのみ**
* オフ時は v0.1 どおりアイコンのみ。Menu Bar Tooltip は維持

### F-014: MicBar Settings

* 別の設定ウィンドウ・Preferences シーンは作らない
* メニューフッター構成（`listState == .normal` 等でフッターが出る画面）:

```text
────────────
☐ ログイン時に起動
☐ メニューバーにデバイス名を表示
入力デバイスを再読み込み
終了
```

* Loading / empty / fetchFailed 時も Manual Refresh・終了は v0.1 どおり利用可能。トグルは normal 時を想定（実装で empty 等にも出すかは implementation-plan で決定可）

## 5. 非機能要件（v0.2 追記・変更）

| ID | 内容 |
|----|------|
| NF-002 | 常時ポーリング禁止。Device Change Monitoring は Core Audio 通知のみ |
| NF-003 | Login Item 利用時も起動後すぐ Menu Bar Icon を表示 |
| NF-009 | 設定の永続化は `UserDefaults`（Login Item 実状態は `SMAppService` が正） |

v0.1 の NF-001, NF-004〜NF-008 は継承。Switch Success / Switch Error の通知方針は v0.1 のまま。

## 6. 受け入れ基準（v0.2）

| ID | 内容 |
|----|------|
| AC-009 | Login Item をオンにし再ログインすると MicBar が自動起動する。デフォルトはオフ |
| AC-010 | USB 抜き差し後、メニューを開かずに（Menu Bar Label オン時は）表示が更新される |
| AC-011 | システム設定のみで Default Input Device を変えたとき、MicBar のチェック・「現在の入力:」・Tooltip が追従する |
| AC-012 | Menu Bar Label オン時、長い Display Name は切り詰め、Tooltip に全文 |
| AC-013 | システムのログイン項目から MicBar を外したあと、メニューを開くとトグルがオフ表示になる |
| AC-014 | 変更のない状態でメニューを開いても、毎回「取得中…」だけが出続けない |

## 7. 手動 QA（v0.2 追加）

v0.1 の §12 に加え:

* Login Item オン → 再ログイン → Menu Bar Icon 出現
* Login Item オフ → 再ログイン → 起動しない
* USB / AirPods 抜き差し（メニュー閉）→ Label / Tooltip / 次回メニュー一覧
* システム設定で入力切替 → MicBar 表示追従
* Menu Bar Label オン / オフ、長い Display Name の切り詰め

## 8. 開発順序（参考）

1. Device Change Monitoring + Background / Foreground Refresh（Store・CoreAudioService）
2. MicBar Settings + Login Item（`SMAppService`）
3. Menu Bar Label（`MenuBarLabelView`）
4. 手動 QA・`implementation-plan-v02.md`（未作成なら作成）

詳細タスクは `implementation-plan-v02.md` で管理する（本 grill 時点では未作成）。

## 9. 後続バージョン（参考）

| バージョン | 主な追加 |
|-----------|---------|
| v0.2 | 本ファイルのスコープ |
| v1.0 | transport 付き Display Name、スリープ復帰、Developer ID + DMG、Intel / Universal Binary |
| 見送り | グローバルショートカット、macOS 通知 |
