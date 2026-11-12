# 御成敗式目の形式化と衝突候補の検証

鎌倉幕府の御成敗式目をLean 4でモデル化し、同じ事案に義務と禁止が重なる条件や、裁判の手続を順に適用したときの衝突候補を調べるデモです。全51条の検証は規則のペアを対象とし、手続の検証は裁判手続に関わる8条を対象とします。

## 実行方法

1. Leanのバージョン管理ツールであるElanを導入します。Windowsでは公式ガイドのVS CodeとLean 4拡張機能から設定できます。コマンドラインからの導入方法も公式ガイドにあります。[Leanのインストール](https://lean-lang.org/install/) · [手動インストール](https://lean-lang.org/install/manual/)
2. 展開またはクローンしたフォルダーを開き、ターミナルで `lean-toolchain` があるディレクトリに移動します。Elanはこのファイルを読み、Lean 4.19.0を選択します。初回はツールチェーンの取得にネット接続が必要です。[Elanのツールチェーン選択](https://lean-lang.org/doc/reference/latest/Build-Tools-and-Distribution/Managing-Toolchains-with-Elan/)
3. 以下を実行します。Lean標準の機能だけで動作します。

```text
lean --version
lean ShikimokuOriginalAudit.lean
lean ShikimokuProcedureAudit.lean
```

各ファイルは単独で実行できます。末尾の `#eval` が結果を表示し、`#guard` のあるモデルでは期待した検証結果が得られないとLeanがエラーを返します。

## ファイルと結果

| Leanファイル | 対象と結果 | 報告書 |
|---|---|---|
| [ShikimokuOriginalAudit.lean](ShikimokuOriginalAudit.lean) | 原文翻刻と照合した162規則の全13,041ペア。候補4件。そのうち1件は慣行と禁制の重なり。 | [原文照合版の報告](reports/ShikimokuOriginalAuditReport.txt) |
| [ShikimokuProcedureAudit.lean](ShikimokuProcedureAudit.lean) | 8条の手続について272通りの事案を探索。第29条の留保の適用範囲によって、候補のある事案は16件、4件、0件。 | [手続検証の報告](reports/ShikimokuProcedureAuditReport.txt) |

全ペアの件数は、各モデルに登録した規則から異なる2規則を選ぶ組み合わせの数です。同じ法的効果に当たる規則は人手で対応づけています。手続モデルでは問状と召文の接続や裁許の留保範囲を仮定し、仮定ごとに到達可能な経路を調べています。各報告書に、候補が成立する条件と解釈上の留保を記載しています。

## 参照資料

- 塙保己一編『群書類従』第十五輯所収「御成敗式目」。原文照合版と手続モデルの底本。[ウィキソースの原文翻刻](https://ja.wikisource.org/wiki/御成敗式目)
- 多賀譲治訳「御成敗式目・貞永式目 現代語訳全文」。[玉川学園](https://www.tamagawa.ac.jp/sisetu/kyouken/kamakura/goseibaishikimoku/)
- 佐藤雄基「御成敗式目の現代語訳はどうして難しいのか」。第41条の年紀と帰属、第48条の私領売買の解釈。[立教大学リポジトリ](https://rikkyo.repo.nii.ac.jp/record/21506/files/AA12450203_05_02.pdf)
- 松園潤一朗「中世における年紀法の機能と変容」。第8条の適用と知行の経緯。[一橋大学リポジトリ](https://hit-u.repo.nii.ac.jp/record/2041528/files/hogaku0180100690.pdf)
- 佐藤雄基による鎌倉幕府の裁判手続の解説。第35条の召文と不参決、第51条の問状の運用。[裁判所ウェブサイト](https://www.courts.go.jp/saikosai/vc-files/saikosai/shihoukensyujyo/ronsyuu2024-5.pdf)

## GitHubへの登録

GitHubで空のリポジトリを作成します。README、ライセンス、.gitignore の初期化は空欄にします。展開先の `shikimoku-lean` で次を実行し、`YOUR-ACCOUNT/shikimoku-lean` を作成したリポジトリのパスに置き換えます。認証の方法はGitHubの公式手順を参照してください。[既存のローカルコードをGitHubに追加する](https://docs.github.com/en/migrations/importing-source-code/using-the-command-line-to-import-source-code/adding-locally-hosted-code-to-github)

```bash
git init -b main
git add .
git commit -m "Add Goseibai Shikimoku Lean models"
git remote add origin https://github.com/YOUR-ACCOUNT/shikimoku-lean.git
git push -u origin main
```
