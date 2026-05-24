# v0.1 は Core Audio ネイティブ、CLI は開発検証のみ

MicBar v0.1 の配布物は Core Audio を直接呼び出して Default Input Device を切り替える。`switchaudio-osx` は開発中の動作確認・Core Audio 実装との結果比較にだけ使い、ユーザー環境への同梱やランタイム依存にはしない。

Homebrew 前提の CLI 完成版は配布体験が悪く、BOSS が求める「アプリ単体で完結する」体験と合わない。一方、実装前に BOSS 環境（USB Audio、AirPods 等）で切替が成立するかを早く確認する価値はある。

**Considered Options**

- **A — 最初から Core Audio のみ**: 最もシンプルだが、Core Audio の不具合と要件不整合の切り分けが遅れる。
- **B — 開発検証にだけ CLI、出荷は Core Audio**（採用）: tech-stack §4.2 の意図と一致。
- **C — v0.1 本体も CLI 依存**: 早いが Homebrew 前提が残り、v0.1 の完成定義と矛盾する。
