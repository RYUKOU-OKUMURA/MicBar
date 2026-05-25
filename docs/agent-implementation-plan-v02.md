# MicBar v0.2 — エージェント実装計画

> **進捗チェックリスト（正本）**: [implementation-plan-v02.md](../implementation-plan-v02.md)  
> **要件**: [requirements-v02.md](../requirements-v02.md)  
> **ADR**: [0003-device-change-monitoring-and-refresh-modes.md](./adr/0003-device-change-monitoring-and-refresh-modes.md)

---

## フェーズ別サブエージェント割当

```text
Phase 1 (Monitoring) → Phase 2 (Settings) → Phase 3 (Label) → Phase 4 (QA)
```

### Phase 1: Device Change Monitoring

| ステップ | 担当 | 作業 |
|----------|------|------|
| 1-a | `generalPurpose` | `CoreAudioService` リスナー、`DeviceSnapshot` |
| 1-b | `generalPurpose` | `AudioDeviceStore` BG/FG refresh、`refreshOnMenuAppear` |
| 1-c | `shell` | `xcodebuild test` |
| レビュー | `readonly` | ポーリングなし、UI から Core Audio 直叩きなし、AC-014 |

**出口**: F-007、UT 緑。

---

### Phase 2: MicBar Settings + Login Item

| ステップ | 担当 | 作業 |
|----------|------|------|
| 2-a | `generalPurpose` | `MicBarSettings`, `LoginItemService`, フッタートグル |
| レビュー | `readonly` | デフォルトオフ、SMAppService 同期、別ウィンドウなし |

**出口**: F-009, F-014。

---

### Phase 3: Menu Bar Label

| ステップ | 担当 | 作業 |
|----------|------|------|
| 3-a | `generalPurpose` | `MenuBarLabelView` + settings 連携 |
| レビュー | `readonly` | AC-012、nil 時アイコンのみ |

**出口**: F-013。

---

### Phase 4: 手動 QA

| ステップ | 担当 | 作業 |
|----------|------|------|
| 4-a | 手動（BOSS） | AC-009〜014、§7 シナリオ |
| レビュー | `readonly` | v0.2 スコープ外（通知・ショートカット等）が混入していないか |

---

## レビュー依頼テンプレート（v0.2）

```text
MicBar v0.2 Phase {N} の実装をレビューしてください。

参照:
- requirements-v02.md（F-007, F-009, F-013, F-014, AC-009〜014）
- docs/adr/0003-device-change-monitoring-and-refresh-modes.md
- implementation-plan-v02.md Phase {N}

確認観点:
1. Background / Foreground Refresh の分岐が ADR-0003 と一致するか
2. 常時ポーリングが入っていないか
3. Login Item の実状態同期（起動時・メニュー表示時）
4. Menu Bar Label デフォルトオフ、Tooltip 全文
5. v0.1 切替コア・Switch Success/Error 方針が壊れていないか

出力: Critical / Suggestion / OK。ファイルパス付き。
```
