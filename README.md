# 御成敗式目の形式化と衝突候補の検証

鎌倉幕府の御成敗式目から条件付きの規則を採録し、Lean 4で衝突候補を調べるデモです。全51条の規則について、人が同じ効果と対応づけた行為のペアを検査します。別の手続モデルでは、裁判手続に関わる8条の適用順序を調べます。

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
| [ShikimokuOriginalAudit.lean](ShikimokuOriginalAudit.lean) | 全51条から160規則を採録し、4つの比較用効果を導出。全13,366組中、同一行為名・反対モードの12組を条件比較。候補5枝、条文番号対では4組。 | [原文照合版の報告](reports/ShikimokuOriginalAuditReport.txt) |
| [ShikimokuProcedureAudit.lean](ShikimokuProcedureAudit.lean) | 8条の手続について1,024通りの事案を探索。第29条の発覚後・留保未解除で裁定へ進める事案は、設定別に96件、64件、0件（広義の留保を共通の検査基準とする）。 | [手続検証の報告](reports/ShikimokuProcedureAuditReport.txt) |

## 検証範囲

原文照合版は、登録した規則・比較用効果の異なる2項目を選ぶ全ペアを走査します。そのうち、同じ行為名で、禁止と義務・許可・慣行が対になるものだけが適用条件の比較に進みます。総ペア数と条件比較に進んだペア数を別々に出力します。

行為名・条件は人が原文を読んで対応づけています。異なる表現の同義関係、条件間の含意、義務同士の両立不能、主体や対象の同一性を一般的に推論する仕組みはありません。第41・43条の比較用効果は元の規則から生成し、例外も引き継ぎます。第38条の名主職改替と第45条の糺決要件など、他条への手続条件の接続は未実装です。全51条の採録は、原文の全規範や全事案を検証し尽くしたことを意味しません。

手続版では、第44条の競望と本案を分け、第49条の証拠の明白さと、原告の主張に理があるかを区別します。第29条は、奉行人を迂回した事実、その発覚、留保の発動を別に扱います。発覚時点や留保解除、問状と召文の接続、所職改替の順序にはモデル上の仮定があります。探索は登録した有限の事案・状態・遷移について行い、発覚前の裁定や外部判断による留保解除も含めた範囲を報告書に記載しています。

検出0件は、採用した解釈と検査項目の下での結果です。原文からの変換の正しさや、鎌倉幕府での実際の裁定をLeanが保証するわけではありません。歴史的な運用の判断には、裁判記録・追加法・当時の通達との照合が必要です。

今回の変更理由と残る範囲は、[原文再レビューへの対応](reports/SourceReviewChanges.txt)を参照してください。

## 参照資料

- 塙保己一編『群書類従』第十五輯所収「御成敗式目」。原文照合版と手続モデルの底本。[ウィキソースの原文翻刻](https://ja.wikisource.org/wiki/御成敗式目)
- 多賀譲治訳「御成敗式目・貞永式目 現代語訳全文」。[玉川学園](https://www.tamagawa.ac.jp/sisetu/kyouken/kamakura/goseibaishikimoku/)
- 佐藤雄基「御成敗式目の現代語訳はどうして難しいのか」。第41条の年紀と帰属、第48条の私領売買の解釈。[立教大学リポジトリ](https://rikkyo.repo.nii.ac.jp/record/21506/files/AA12450203_05_02.pdf)
- 松園潤一朗「中世における年紀法の機能と変容」。第8条の適用と知行の経緯。[一橋大学リポジトリ](https://hit-u.repo.nii.ac.jp/record/2041528/files/hogaku0180100690.pdf)
- 佐藤雄基による鎌倉幕府の裁判手続の解説。第35条の召文と不参決、第51条の問状の運用。[裁判所ウェブサイト](https://www.courts.go.jp/saikosai/vc-files/saikosai/shihoukensyujyo/ronsyuu2024-5.pdf)
- 始澤真純「日本の中世の名誉保護と現代法制とのつながり」51頁。第12条の悪口と勝敗による処分の区別。[東洋大学リポジトリ](https://toyo.repo.nii.ac.jp/record/2000467/files/daigakuin60-D_049-062.pdf)
- 今井林太郎「神護寺領播磨国福井荘」85頁。第37条の他の御家人の所領の上司という関係。[大手前大学リポジトリ](https://otemae.repo.nii.ac.jp/record/1248/files/1976_wu_077-091_imai.pdf)

## 指摘・再利用

史料の読みやモデルへの指摘、実行時の問題はGitHub Issuesに投稿できます。該当する条文やファイル、実行したコマンドを添えると再現しやすくなります。[Issues](https://github.com/adachi6k/shikimoku-lean/issues)

- Leanソースコード（`*.lean`）は [MIT License](LICENSE) を適用します。
- このREADMEと `reports/` 内の検証報告書は、Koji Adachiが許諾できる範囲で [CC BY 4.0](LICENSE-CC-BY-4.0) を適用します。再利用時は著作者名とライセンスを示し、改変した場合はその旨を明記してください。

リンク先の現代語訳・論文などには、それぞれの権利条件が適用されます。
