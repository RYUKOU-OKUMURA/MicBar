# 本実装前に権限・CLI の事前検証を行う

v0.1 の Phase 1（メニューシェル）に入る前に、(1) Core Audio だけの最小アプリでマイク権限ダイアログの有無を確認し、(2) 必要なら `switchaudio-osx` で BOSS 実機の切替成立を確認する。その後 Phase 1 → Phase 2〜3（Core Audio 本実装）の順で進める。

権限ダイアログは Background App 設計とプライバシー方針（録音しない）に直結する未知要素。CLI 比較は ADR-0001 の開発検証方針の具体化。Phase 1 から始めると、後から Core Audio 周りで設計をやり直すリスクがある。
