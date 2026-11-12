# 御成敗式目の形式化と衝突候補の検証

鎌倉幕府の御成敗式目をLean 4でモデル化し、同じ事案に義務と禁止が重なる条件や、裁判の手続を順に適用したときの衝突候補を調べるデモです。全51条の検証は規則のペアを対象とし、手続の検証は裁判手続に関わる8条を対象とします。

## 実行方法

Leanのバージョン管理ツールであるElanを導入し、ターミナルで以下を実行します。`lean-toolchain` がLean 4.19.0を指定します。初回はツールチェーンの取得にインターネット接続が必要です。モデルはLean標準の機能だけで動作します。[Leanのインストール](https://lean-lang.org/install/) · [Elanのツールチェーン選択](https://lean-lang.org/doc/reference/latest/Build-Tools-and-Distribution/Managing-Toolchains-with-Elan/)

```bash
git clone https://github.com/adachi6k/shikimoku-lean.git
cd shikimoku-lean
lean --version
lean ShikimokuOriginalAudit.lean
lean ShikimokuProcedureAudit.lean
```

GitHubの **Code → Download ZIP** から取得した場合は、展開したフォルダーのうち `lean-toolchain` がある場所で、`lean --version` 以降を実行します。各モデルは `#eval` で結果を表示し、`#guard` で検証結果が期待値と一致することを確認します。実行結果の詳細は下の報告書にあります。

## ファイルと結果

| Leanファイル | 対象と結果 | 報告書 |
|---|---|---|
| [ShikimokuOriginalAudit.lean](ShikimokuOriginalAudit.lean) | 全51条を原文翻刻と照合し、162規則の13,041組を比較。候補4件のうち1件は慣行と禁制の重なり。 | [原文照合版の報告](reports/ShikimokuOriginalAuditReport.txt) |
| [ShikimokuProcedureAudit.lean](ShikimokuProcedureAudit.lean) | 8条の手続について272通りの事案を探索。第29条の留保を適用する範囲に応じ、留保中に裁定へ進める事案は16件、4件、0件。 | [手続検証の報告](reports/ShikimokuProcedureAuditReport.txt) |

## 検証範囲

13,041組は、登録した162規則から異なる2規則を選ぶ全組み合わせです。同じ法的効果を比較するための対応づけは手作業で行っています。手続検証では、問状と召文の接続や裁許の留保範囲を仮定し、各設定で到達できる経路を調べています。

検証結果は、採用した解釈とモデルの条件の下で、どの規則が重なるかを示します。鎌倉幕府での実際の裁定を判断するには、裁判記録や追加法、当時の通達による裏づけが必要です。

## 参照資料

- 塙保己一編『群書類従』第十五輯所収「御成敗式目」。原文照合版と手続モデルの底本。[ウィキソースの原文翻刻](https://ja.wikisource.org/wiki/御成敗式目)
- 多賀譲治訳「御成敗式目・貞永式目 現代語訳全文」。[玉川学園](https://www.tamagawa.ac.jp/sisetu/kyouken/kamakura/goseibaishikimoku/)
- 佐藤雄基「御成敗式目の現代語訳はどうして難しいのか」。第41条の年紀と帰属、第48条の私領売買の解釈。[立教大学リポジトリ](https://rikkyo.repo.nii.ac.jp/record/21506/files/AA12450203_05_02.pdf)
- 松園潤一朗「中世における年紀法の機能と変容」。第8条の適用と知行の経緯。[一橋大学リポジトリ](https://hit-u.repo.nii.ac.jp/record/2041528/files/hogaku0180100690.pdf)
- 佐藤雄基による鎌倉幕府の裁判手続の解説。第35条の召文と不参決、第51条の問状の運用。[裁判所ウェブサイト](https://www.courts.go.jp/saikosai/vc-files/saikosai/shihoukensyujyo/ronsyuu2024-5.pdf)

## 指摘・再利用

史料の読みやモデルへの指摘、実行時の問題はGitHub Issuesに投稿できます。該当する条文やファイル、実行したコマンドを添えると再現しやすくなります。[Issues](https://github.com/adachi6k/shikimoku-lean/issues)

- Leanソースコード（`*.lean`）は [MIT License](LICENSE) を適用します。
- このREADMEと `reports/` 内の検証報告書は、Koji Adachiが許諾できる範囲で [CC BY 4.0](LICENSE-CC-BY-4.0) を適用します。再利用時は著作者名とライセンスを示し、改変した場合はその旨を明記してください。

リンク先の現代語訳・論文などには、それぞれの権利条件が適用されます。
