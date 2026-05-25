# MicBar v0.2 実装計画

> **要件**: [requirements-v02.md](./requirements-v02.md)  
> **前提**: [requirements-v01.md](./requirements-v01.md)（v0.1 完了）  
> **用語**: [CONTEXT.md](./CONTEXT.md)  
> **ADR**: [docs/adr/0003-device-change-monitoring-and-refresh-modes.md](./docs/adr/0003-device-change-monitoring-and-refresh-modes.md)  
> **エージェント運用**: [AGENTS.md](./AGENTS.md) · [docs/agent-implementation-plan-v02.md](./docs/agent-implementation-plan-v02.md)

進捗はチェックボックスを `- [x]` に更新して管理する。

```text
Phase 1 → Phase 2 → Phase 3 → Phase 4
```

---

## フェーズ 1: Device Change Monitoring + Refresh 分岐

**対応**: F-007, AC-010, AC-011, AC-014

### 1.1 Infrastructure

- [x] `AudioDeviceProviding` に監視 API・`peekDeviceSnapshot()` を追加
- [x] `CoreAudioService` に `AudioObjectAddPropertyListenerBlock`（Devices + DefaultInput）
- [x] `stopMonitoring` / リスナー解除

### 1.2 AudioDeviceStore

- [x] `refreshForeground()` — v0.1 同様 Loading
- [x] `refreshBackground()` — Loading なしで Store 更新
- [x] `refreshOnMenuAppear()` — snapshot 一致時スキップ（AC-014）
- [x] `isMenuVisible` + 監視コールバックで BG/FG 分岐
- [x] 起動・切替・Manual Refresh の呼び分け

### 1.3 UI 接続

- [x] `MenuBarView` — `refreshOnMenuAppear` / `onDisappear`
- [x] `MicBarApp` — 起動時 `refreshForeground`、監視開始

### 1.4 テスト

- [x] Background refresh で `listState != .loading`
- [x] Foreground refresh で loading 経由
- [x] `refreshOnMenuAppear` snapshot 一致で list 未呼び出し
- [x] 監視 Mock で BG refresh

### 完了条件（フェーズ 1）

- [x] `xcodebuild build` 成功（Debug）
- [x] UT は Xcode ⌘U 推奨（CLI は `CONFIGURATION_BUILD_DIR=/Applications` のため TEST_HOST 要確認）

---

## フェーズ 2: MicBar Settings + Login Item

**対応**: F-009, F-014, AC-009, AC-013, NF-009

### 2.1 Settings / Login Item

- [x] `MicBarSettings` — `showMenuBarLabel`（UserDefaults、デフォルトオフ）
- [x] `LoginItemService` — `SMAppService.mainApp`
- [x] 起動時・メニュー表示時に Login Item 状態同期

### 2.2 メニューフッター

- [x] 「ログイン時に起動」トグル（normal 時のみ）
- [x] 「メニューバーにデバイス名を表示」トグル（normal 時のみ）
- [x] Manual Refresh → `refreshForeground()`
- [x] empty / fetchFailed は再読み込み・終了のみ

### 完了条件（フェーズ 2）

- [x] `ServiceManagement` リンク・ビルド成功
- [x] トグル操作で register / unregister が呼ばれる

---

## フェーズ 3: Menu Bar Label

**対応**: F-013, AC-012![1779672444863](image/implementation-plan-v02/1779672444863.png)

- [x] `MenuBarLabelView` — 設定 ON 時 Display Name（切り詰め）
- [x] `currentDevice == nil` → アイコンのみ
- [x] Tooltip に全文（AC-012）

### 完了条件（フェーズ 3）

- [x] トグル OFF で v0.1 どおりアイコンのみ

---

## フェーズ 4: 手動 QA・v0.2 完了

**対応**: requirements-v02 §6–7, AC-009〜014

- [ ] Login Item ON → 再ログイン → アイコン（AC-009）
- [ ] Login Item OFF → 再ログイン → 起動しない
- [ ] システムログイン項目から削除 → トグルオフ（AC-013）
- [ ] USB / AirPods 抜き差し（メニュー閉）— Label / メニュー（AC-010）
- [ ] システム設定のみで入力切替 — 追従（AC-011）
- [ ] Menu Bar Label 長名切り詰め + Tooltip 全文（AC-012）
- [ ] 変更なしでメニュー再表示 — Loading なし（AC-014）
- [x] コードレビュー（自走: Critical 0）

### 完了条件（フェーズ 4）

- [ ] 全 AC-009〜014 を BOSS 手動 QA で確認
- [ ] v0.2 完了判定
