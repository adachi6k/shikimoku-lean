/-
御成敗式目 51条の登録規則と限定した衝突候補の検査
実行: lean ShikimokuOriginalAudit.lean

底本は『群書類従』第十五輯所収本の翻刻。
https://ja.wikisource.org/wiki/御成敗式目
https://dl.ndl.go.jp/pid/1879792/1/6

冒頭の経過規定、末尾の起請と追加条は、番号付き51条の外にある。
「根拠」欄の番号は翻刻を取得した際の本文行番号。
条件付きの義務・禁止・許可のほか、既存の慣行の記述を区別する。
同じ行為名は同じ事案・主体・対象・手続段階についての比較を表す。
各比較に固有の同一性や背景事実は成立条件として明示する。
条件・行為は文字列の原子として扱う。意味上の含意や行為の言い換えは
推論しない。51条すべてに項目があることは、全内容の形式化を意味しない。
第41条と第43条の比較用効果は原規則から生成し、解釈の変更後にも再生成する。
-/

namespace ShikimokuOriginal

inductive Mode where
  | require
  | forbid
  | permit
  | custom
  deriving DecidableEq

structure Clause where
  mode : Mode
  act : String
  conditions : List String
  exceptions : List String

structure Article where
  number : Nat
  sourceLine : Nat
  note : String
  clauses : List Clause

def articles : List Article := [
  ⟨1, 110, "地頭・神主、関東御分国と荘園。有封社の小破・大破を区別。", [
    ⟨.require, "地頭と神主が恒例の祭祀・礼奠を維持", ["関東御分国または対象荘園の神社"], []⟩,
    ⟨.require, "有封社の小破を修理", ["有封社が小破"], []⟩,
    ⟨.require, "有封社の大破を言上して事情に応じ処置", ["有封社が大破"], []⟩
  ]⟩,
  ⟨2, 113, "改易は寺からの追放と区別し、職の交替とする。", [
    ⟨.require, "寺塔を修造し恒例の仏事を勤める", ["寺塔と仏事"], []⟩,
    ⟨.require, "寺用を私し勤めを怠った者の職を改める", ["寺用を私し勤めを怠った"], []⟩
  ]⟩,
  ⟨3, 117, "大番催促・謀反・殺害と付記の犯罪類型をまとめる。守護が任命する代官は一人。", [
    ⟨.require, "守護が大番催促・所管の検断を行う", ["守護の所管事項"], []⟩,
    ⟨.forbid, "守護が権限外の国務・徴税に介入", ["守護の管内"], []⟩,
    ⟨.forbid, "守護が大番役を催促", ["御家人に当時の所帯なし"], []⟩,
    ⟨.forbid, "守護が大番役を催促", ["下司・荘官が御家人を詐称し国司・領家の下知に抵抗"], []⟩,
    ⟨.require, "違法な守護を改易し後任を補任", ["権限外の介入が顕然"], []⟩,
    ⟨.forbid, "守護が複数の代官を置く", ["守護の代官補任"], []⟩
  ]⟩,
  ⟨4, 119, "重犯の私的没収と守護所への付渡を分離。処分対象の列挙は翻刻に従う。", [
    ⟨.require, "守護が重犯の子細を注進し裁断を受ける", ["重犯が発生"], []⟩,
    ⟨.forbid, "守護が重犯の財産を独断で没収", ["重犯が発生"], []⟩,
    ⟨.require, "独断で没収した守護を処罰", ["守護の私的没収"], []⟩,
    ⟨.forbid, "保護対象を守護所に引き渡す", ["重犯人を守護所に引き渡す", "対象が田宅・妻子・雑具"], []⟩,
    ⟨.forbid, "共犯者に財産に関する沙汰をする", ["共犯者に財物なし"], []⟩
  ]⟩,
  ⟨5, 123, "結解・勘定と犯用の弁償を区別。額の軽重は入力。", [
    ⟨.require, "地頭が結解し勘定を受ける", ["本所が年貢抑留を訴えた"], []⟩,
    ⟨.require, "地頭が犯用分を速やかに弁償", ["地頭の犯用が確定", "少額"], []⟩,
    ⟨.require, "地頭が犯用分を三年以内に弁済", ["地頭の犯用が確定", "多額"], []⟩,
    ⟨.require, "弁済に従わない地頭の職を改める", ["第5条の弁済に違反"], []⟩
  ]⟩,
  ⟨6, 126, "従来の本所の進止への口入と、挙状を伴う越訴は別。", [
    ⟨.forbid, "幕府が本所の進止下の従来の沙汰に介入", ["従来の本所の進止下にある国衙・荘園・寺社"], []⟩,
    ⟨.forbid, "幕府が荘園・寺社領の越訴を裁定", ["荘園・寺社領の越訴"], ["本所の挙状あり"]⟩
  ]⟩,
  ⟨7, 129, "旧領主の訴え、当時の給人の罪科、代々の成敗後の濫訴を区別。", [
    ⟨.forbid, "旧領主の旧領請求を受理", ["先代将軍らの宛給地", "旧領主が本領と主張"], ["現在の給人に罪科", "前判決後の濫訴"]⟩,
    ⟨.permit, "旧領主の旧領請求を受理", ["先代将軍らの宛給地", "現在の給人に罪科", "旧領主に請求の根拠"], ["前判決後の濫訴"]⟩,
    ⟨.forbid, "旧領主の旧領請求を受理", ["先代将軍らの宛給地", "前判決後の濫訴"], []⟩,
    ⟨.require, "濫訴の不実を所持する証文に記載", ["代々の成敗に背く濫訴"], []⟩
  ]⟩,
  ⟨8, 132, "二十箇年を過ぎた当知行の改替と、偽って得た御下文の叙用を区別。第43条と射程を比較。", [
    ⟨.forbid, "幕府が当該所領の現知行者を交替させる", ["当該所領の当知行が二十年を超えた"], []⟩,
    ⟨.forbid, "偽って取得した御下文を証拠に採用", ["知行を装って御下文を得た"], []⟩
  ]⟩,
  ⟨9, 136, "謀反の刑を固定せず、先例と時宜を参照する。", [
    ⟨.require, "謀反の処分を先例と時宜により裁定", ["謀反"], []⟩
  ]⟩,
  ⟨10, 140, "当座の争論・酔余の不慮、父祖の敵の殺害、職や財宝を狙う殺害を区別。", [
    ⟨.require, "本人を処刑または流刑に処し所帯を没収", ["当座の諍論または酔余の不慮の殺害"], []⟩,
    ⟨.forbid, "父に連座の罪科を科す", ["不慮の殺害または刃傷", "父が関与していない"], ["子が父祖の敵を殺害"]⟩,
    ⟨.forbid, "子に連座の罪科を科す", ["不慮の殺害または刃傷", "子が関与していない"], []⟩,
    ⟨.require, "父に連座の罪科を科す", ["子が父祖の敵を殺害", "父が条文の対象となる父祖"], []⟩,
    ⟨.require, "祖父に連座の罪科を科す", ["子孫が父祖の敵を殺害", "祖父が条文の対象となる父祖"], []⟩,
    ⟨.forbid, "父に連座の罪科を科す", ["子が職または財宝を奪うため殺害を企てた", "父が知らなかったことが明白"], []⟩
  ]⟩,
  ⟨11, 143, "夫の咎を妻の所領に懸ける。口論による刃傷・殺害を例外とする。第4条の付渡とは別。", [
    ⟨.require, "夫の咎により妻の所領を没収の対象とする", ["夫が第11条の重科", "対象が妻の所領"], ["当座の口論による刃傷・殺害"]⟩,
    ⟨.forbid, "夫の咎により妻の所領を没収の対象とする", ["対象が妻の所領", "当座の口論による刃傷・殺害"], []⟩
  ]⟩,
  ⟨12, 146, "問注中の悪口を共通条件とする。後文を前文の分岐と読み、理ありなら論所、理なしなら他所領の有無で処分。原告・被告を問わない。", [
    ⟨.require, "重大な悪口の発言者を流罪", ["重大な悪口"], []⟩,
    ⟨.require, "軽い悪口の発言者を拘禁", ["軽い悪口"], []⟩,
    ⟨.require, "悪口を吐いた当事者の相手に論所を付す", ["当該当事者が問注中に悪口", "当該当事者の論所の主張に理あり"], []⟩,
    ⟨.require, "悪口を吐いた当事者の他の所領を没収", ["当該当事者が問注中に悪口", "当該当事者の論所の主張に理なし", "当該当事者に他の所領あり"], []⟩,
    ⟨.require, "悪口を吐いた当事者を流罪", ["当該当事者が問注中に悪口", "当該当事者の論所の主張に理なし"], ["当該当事者に他の所領あり"]⟩
  ]⟩,
  ⟨13, 150, "処分の身分区分は侍と郎従以下。", [
    ⟨.require, "殴打した侍の所領を没収", ["殴打した者が侍", "殴打した者に所領あり"], []⟩,
    ⟨.require, "殴打した侍を流罪", ["殴打した者が侍"], ["殴打した者に所領あり"]⟩,
    ⟨.require, "殴打した郎従以下の者を拘禁", ["殴打した者が郎従以下"], []⟩
  ]⟩,
  ⟨14, 153, "重科で代官本人を召進する場合と、本所年貢の抑留・先例違反の責任を区別。", [
    ⟨.forbid, "主人に代官の重科の連座を科す", ["代官が殺害等の重科", "主人が代官本人を召進"], []⟩,
    ⟨.require, "主人の所領を没収し代官を拘禁", ["主人が代官をかばって無罪と述べた", "実犯が露顕"], []⟩,
    ⟨.require, "主人に代官の年貢抑留・法違反の責任を問う", ["代官による本所年貢の抑留または先例・率法違反"], []⟩,
    ⟨.require, "主人の所帯に不参決の処分を行う", ["鎌倉または六波羅からの召し", "参決せず妨害を続ける"], []⟩
  ]⟩,
  ⟨15, 156, "一般の虚言でなく、相手の文書を根拠なく謀書と称した場合を分離。", [
    ⟨.require, "偽造した侍の所領を没収", ["文書を偽造した侍", "偽造者に所領あり"], []⟩,
    ⟨.require, "偽造した侍を遠流", ["文書を偽造した侍"], ["偽造者に所領あり"]⟩,
    ⟨.require, "偽造した凡下に火印を捺す", ["文書を偽造した凡下"], []⟩,
    ⟨.require, "偽造文書の執筆者を同罪に処す", ["偽造文書の執筆者"], []⟩,
    ⟨.require, "証文の偽造が確認されれば偽造の処分を適用", ["相手の証文を謀書と訴え実際に偽造と判明"], []⟩,
    ⟨.require, "根拠なく謀書と称した者に寺社修理を命じる", ["相手の証文を謀書と称したが誤りなし"], ["告発者に修理の資力なし"]⟩,
    ⟨.require, "修理の資力がない虚偽の謀書告発者を追放", ["相手の証文を謀書と称したが誤りなし", "告発者に修理の資力なし"], []⟩
  ]⟩,
  ⟨16, 160, "現給人への代替給付と旧主への返還を区別。即時の処刑・没収は既往の処分の説明（畢）としてこの注記に記録し、現在の義務から除外。後日判明者への処分を規則化。", [
    ⟨.require, "承久の乱で誤って没収した所領を旧主へ返す", ["承久の乱の没収", "旧主の無過が証拠上明白"], []⟩,
    ⟨.require, "現給人に代替の恩賞を与える", ["誤没収地を旧主へ返還", "現給人に勲功奉公あり"], []⟩,
    ⟨.require, "後に判明した朝廷方の御恩の輩の所領を五分の一没収", ["承久の乱で御恩の輩が朝廷方", "処刑・没収を免れて後に判明"], []⟩,
    ⟨.forbid, "朝廷方の下司・荘官を改めて処分", ["御家人以外の下司・荘官の朝廷方参加が後に判明"], []⟩,
    ⟨.forbid, "承久没収地につき当時の知行者を除外する旧領請求を受理", ["当時の知行者の罪で没収", "それ以前の由緒に基づく濫望"], []⟩
  ]⟩,
  ⟨17, 162, "父子の賞罰を個別化。西国在住者の同意推定と疎遠・不知の例外。恩賞と刑の併存は別途検討。", [
    ⟨.require, "父子それぞれの参戦先に応じ賞罰を決める", ["承久の乱で父子が敵味方に分かれた"], []⟩,
    ⟨.require, "西国の父子の朝廷方でない側に連座を科す", ["西国の父子", "父子の一方が朝廷方", "他方もその国に居住"], ["遠隔・音信困難で互いに事情を知らない"]⟩,
    ⟨.forbid, "西国の父子の朝廷方でない側に連座を科す", ["西国の父子", "父子の一方が朝廷方", "遠隔・音信困難で互いに事情を知らない"], []⟩
  ]⟩,
  ⟨18, 166, "女子への譲与後の向背を要件として明示。第26条の一般的な書き方との差は留保。", [
    ⟨.permit, "親が女子に譲った所領を悔返す", ["親が女子に所領を譲与", "女子に向背の儀あり"], []⟩
  ]⟩,
  ⟨19, 169, "親疎を問わず眷養された者と本主の子孫の相論。対象は得譲の所領。", [
    ⟨.require, "得譲の所領を本主の子孫に付す", ["眷養された者が本主から所領を譲り受けた", "眷養された者が本主の子孫に背いた"], []⟩
  ]⟩,
  ⟨20, 172, "子の存命中にも悔返し得るとの前提と、父母より先に死去した後の父祖の処分を登録。", [
    ⟨.permit, "父祖が譲り状に係る所領の処分を改める", ["譲り状を得た子が存命"], []⟩,
    ⟨.permit, "父祖が譲り状に係る所領の処分を改める", ["譲り状を得た子が父母より先に死去"], []⟩
  ]⟩,
  ⟨21, 176, "重科による棄捐と、有功無過の妻を新しい妻のために棄てた場合。", [
    ⟨.forbid, "棄捐された妻妾が前夫からの譲与地を知行", ["妻妾が前夫から所領を得た", "重科による棄捐"], []⟩,
    ⟨.forbid, "前夫が譲与地を悔返す", ["妻が有功無過", "前夫が新しい妻を重んじて旧妻を棄てた", "前夫からの譲与地"], []⟩
  ]⟩,
  ⟨22, 179, "成人した子の無足、嫡子分の五分の一、既配分の証跡と奉公・不孝の除外。", [
    ⟨.require, "無足の兄に現在の嫡子分の五分の一を宛てる", ["勤功のある成人の子を義絶せず配分から外した"], ["既配分の証跡あり", "奉公に乏しいまたは不孝"]⟩,
    ⟨.require, "既配分は証跡に従って扱う", ["成人の子に既配分の証跡あり"], []⟩
  ]⟩,
  ⟨23, 182, "無子の女人が養子に所領を譲与。寡婦に限る条件は置かない。", [
    ⟨.permit, "無子の女人が養子に所領を譲与", ["女人に子がなく養子あり"], []⟩
  ]⟩,
  ⟨24, 185, "亡夫から譲り得た所領に限る。無子の場合の別御計は裁量。", [
    ⟨.require, "後家が亡夫の後世を弔う", ["後家が亡夫から所領を譲り受けた"], []⟩,
    ⟨.require, "亡夫からの所領を亡夫の子に宛てる", ["後家が亡夫から所領を譲り受けた", "後家が改嫁", "亡夫に子あり"], []⟩,
    ⟨.require, "改嫁時の譲得所領について別に裁定", ["後家が亡夫から所領を譲り受けた", "後家が改嫁"], ["亡夫に子あり"]⟩
  ]⟩,
  ⟨25, 189, "所領を女子に譲っても公事を割り当てる。父の在世中の猶予と没後を区別。", [
    ⟨.require, "譲与所領に相応の公事を割り当てる", ["御家人が公家を婿にし女子に所領を譲与"], ["父が存命で猶予中"]⟩,
    ⟨.require, "父の死後に公事を催勤", ["第25条の譲与所領", "父が死亡"], []⟩,
    ⟨.require, "権威を頼み勤仕を怠る者から所領を退ける", ["第25条の譲与所領", "権威を頼み勤仕を怠る"], []⟩,
    ⟨.require, "殿中に仕える女房にも公平に公事を課す", ["対象者が関東祇候の女房"], []⟩,
    ⟨.forbid, "なお公事を拒む女房に所領の知行を認める", ["関東祇候の女房がなお公事を拒む"], []⟩
  ]⟩,
  ⟨26, 192, "親の後判の譲りを裁定の基準にする。先判に安堵御下文がある場合を明示。", [
    ⟨.require, "子への再譲与では後判の譲りに従い裁定", ["子への先判の譲りに安堵御下文", "親が悔返して他の子へ後判で譲与"], []⟩
  ]⟩,
  ⟨27, 195, "未処分跡を奉公・器量・時宜で分宛。受給者を本文にない妻子に固定しない。", [
    ⟨.require, "未処分跡を奉公・器量・時宜に応じて分宛", ["未処分の跡あり"], []⟩
  ]⟩,
  ⟨28, 199, "所領を望む讒訴と、他人の官途を妨げる虚言を区別。", [
    ⟨.require, "讒訴者の所領を他人に宛てる", ["所領を望んで讒訴", "讒訴者に所領あり"], []⟩,
    ⟨.require, "所領を望む讒訴者を遠流", ["所領を望んで讒訴"], ["讒訴者に所領あり"]⟩,
    ⟨.forbid, "官途を妨げた讒人を召し仕う", ["人の官途を妨げるための虚言"], []⟩
  ]⟩,
  ⟨29, 202, "裁許を一時抑えることと、奉行人の緩怠二十日後の庭中申立てを区別。", [
    ⟨.require, "訴人の裁許を一時見合わせる", ["本奉行人を飛ばし別人に内々に訴訟を依頼"], []⟩,
    ⟨.forbid, "別の取次人が内々の訴訟を取り次ぐ", ["本奉行人を飛ばした訴訟"], []⟩,
    ⟨.permit, "奉行人の緩怠を庭中に申し立てる", ["奉行人が緩怠し空しく二十日経過"], []⟩
  ]⟩,
  ⟨30, 206, "問注後の権門書状と、奉行人・庭中という通常の申立て経路を分ける。", [
    ⟨.forbid, "問注後の判決前に権門の書状を提出", ["問注を遂げ判決を待つ間"], []⟩,
    ⟨.permit, "当事者が奉行人または庭中に申し立てる", ["訴訟で申し立てる事項あり"], []⟩
  ]⟩,
  ⟨31, 209, "無理な敗訴者による虚偽の偏頗申立てと、奉行人の実際の誤りを区別。", [
    ⟨.require, "虚偽の偏頗申立人の所領を三分の一収公", ["無理な敗訴者が虚偽の偏頗を主張", "申立人に所領あり"], []⟩,
    ⟨.require, "虚偽の偏頗申立人を追却", ["無理な敗訴者が虚偽の偏頗を主張"], ["申立人に所領あり"]⟩,
    ⟨.forbid, "誤りを犯した奉行人を再び召し仕う", ["奉行人に実際の誤りあり"], []⟩
  ]⟩,
  ⟨32, 213, "証跡、隠匿、嫌疑による鎌倉留置、守護所への引渡し、代官交替・地頭職没収を分離。", [
    ⟨.require, "証跡のある凶賊を召し禁ずる", ["地頭の関係する凶賊に証跡あり"], []⟩,
    ⟨.require, "賊徒を隠した地頭を同罪に処す", ["地頭が賊徒を隠匿"], []⟩,
    ⟨.require, "嫌疑のある地頭を鎌倉に留める", ["賊徒隠匿の嫌疑", "現地の件が未決着"], []⟩,
    ⟨.require, "悪党を速やかに守護所へ引き渡す", ["守護使入部が停止された場所で悪党が発覚"], []⟩,
    ⟨.require, "守護使を入部させ地頭代を交替", ["悪党を守護所への引渡しからかばった"], []⟩,
    ⟨.require, "地頭職を没収し守護使を入部させる", ["代官交替に従わなかった"], []⟩
  ]⟩,
  ⟨33, 215, "強盗と窃盗の先例を参照し放火を準拠させる。具体的な刑は外部入力。", [
    ⟨.require, "強盗・窃盗の処分を断罪の先例に従い決める", ["強盗または窃盗"], []⟩,
    ⟨.require, "放火を盗賊の扱いに準拠して処分", ["放火"], []⟩
  ]⟩,
  ⟨34, 219, "強姦と和姦の両方を明示。前段の出仕停止、後段の身分別処分を分離。", [
    ⟨.require, "他人妻を犯した者の所領を半分召し上げ出仕を止める", ["他人妻への強姦または和姦", "行為者に所領あり"], []⟩,
    ⟨.require, "他人妻を犯した者を遠流", ["他人妻への強姦または和姦"], ["行為者に所領あり"]⟩,
    ⟨.require, "第34条の女性の所領も半分召し上げる", ["第34条前段の女性", "女性に所領あり"], []⟩,
    ⟨.require, "第34条の女性を配流", ["第34条前段の女性"], ["女性に所領あり"]⟩,
    ⟨.require, "道路で女性を捕らえた御家人の出仕を百日止める", ["道路で女性を捕らえた御家人"], []⟩,
    ⟨.require, "道路で女性を捕らえた郎従以下の片鬢を剃る", ["道路で女性を捕らえた郎従以下"], []⟩,
    ⟨.require, "道路で女性を捕らえた法師の罪科を斟酌する", ["道路で女性を捕らえた法師"], []⟩
  ]⟩,
  ⟨35, 223, "三度の召文と不参決。原告の理の有無で分岐。末尾の所従・馬牛・雑物等の但書を無理な原告の枝に接続する読みを採用し、但書の射程の確定とはしない。", [
    ⟨.require, "不参決の事件で原告に直ちに裁許", ["訴状による召文を三度出した", "被告が不参決", "原告に理あり"], []⟩,
    ⟨.require, "不参決の事件で係争地を他に給付", ["訴状による召文を三度出した", "被告が不参決", "原告に理なし", "対象が給付の対象"], []⟩,
    ⟨.require, "所従・馬牛・雑物等を数に従って糺し返し寺社修理に付す", ["訴状による召文を三度出した", "被告が不参決", "原告に理なし", "対象が所従・馬牛・雑物等"], []⟩
  ]⟩,
  ⟨36, 226, "実検後、非拠の訴人の所領から越境主張の分限を割く。", [
    ⟨.require, "実検使を遣わし従来の境界を調べる", ["境界を変える相論"], []⟩,
    ⟨.require, "訴人の所領から越境主張分を割き相手方へ付す", ["境界を変える相論", "実検で非拠の訴訟と判明"], []⟩
  ]⟩,
  ⟨37, 230, "傍官所領上司を傍官と所領上司に分割せず、傍官（他の御家人）の所領の上司への補任請求として扱う。", [
    ⟨.forbid, "御家人が京都に傍官の所領の上司への補任を濫望", ["関東御家人の第37条の請願"], []⟩,
    ⟨.require, "濫望した御家人の所領一所を召し上げる", ["御家人による第37条の濫望"], []⟩
  ]⟩,
  ⟨38, 233, "惣地頭による名主職の妨害、別納の御下文、名主の先例違反を区別。", [
    ⟨.forbid, "惣地頭が惣領を口実に別個の村や名主職を侵す", ["惣地頭の管内"], []⟩,
    ⟨.require, "名主に別納の御下文を給付", ["名主職に別の御下文あり", "惣地頭が沙汰の範囲を越えて妨害"], []⟩,
    ⟨.require, "先例を顧みず地頭に背いた名主の職を改める", ["名主が先例を顧みず地頭に違背"], []⟩
  ]⟩,
  ⟨39, 237, "成功時の注申、昇進の挙状の禁止、理運の受領・検非違使への御免、年廻を区別。", [
    ⟨.permit, "成功の際に所望人を注申", ["第39条の成功に際し公平に注申"], []⟩,
    ⟨.forbid, "昇進のために挙状を求める", ["昇進を望む"], []⟩,
    ⟨.permit, "挙状に代え御免を伝える", ["受領または検非違使を望む", "申請に理あり"], []⟩,
    ⟨.permit, "年廻により朝恩を受ける", ["新叙の年廻が来た"], []⟩
  ]⟩,
  ⟨40, 240, "無免許昇進に対し、寺社供僧と御帰依の僧は停止、ほかの禅侶は諷諫。", [
    ⟨.require, "無免許昇進した寺社供僧の職を停止", ["寺社供僧の無免許昇進"], []⟩,
    ⟨.require, "無免許昇進した御帰依の僧を停止", ["御帰依の僧の無免許昇進"], []⟩,
    ⟨.require, "そのほかの禅侶に帰依者が諷諫", ["そのほかの禅侶の無免許昇進"], []⟩
  ]⟩,
  ⟨41, 243, "十年の無沙汰は十年使役されなかったことと区別。年紀と男女の帰属という3原規則を登録し、帰属変更の比較用効果を後で導出。", [
    ⟨.forbid, "十年を経た奴婢・雑人の帰属を改めて沙汰", ["奴婢・雑人の帰属について無沙汰で十年を経過"], []⟩,
    ⟨.require, "奴婢の子の男子を父方に付す", ["奴婢の子が男子"], []⟩,
    ⟨.require, "奴婢の子の女子を母方に付す", ["奴婢の子が女子"], []⟩
  ]⟩,
  ⟨42, 246, "逃毀を称した拘束・奪取を抑え、年貢未済の弁償と損物の返還を分ける。", [
    ⟨.forbid, "領主が逃毀を称して住民の妻子を拘束し資財を奪う", ["住民が逃脱"], []⟩,
    ⟨.require, "年貢未済を弁償", ["第42条の召決", "年貢未済あり"], []⟩,
    ⟨.require, "領主が奪った財物を速やかに返す", ["第42条の召決", "領主が財物を奪った"], ["年貢未済あり"]⟩,
    ⟨.permit, "住民が去留を決める", ["第42条の住民"], []⟩
  ]⟩,
  ⟨43, 250, "押領物の糺返と加害者の所領没収を分離。土地自体の糺返となる場合の知行者変更は元規則から導出し、対象の同一性は入力条件とする。", [
    ⟨.require, "虚偽の押領で奪った物を速やかに糺し返す", ["虚偽による押領・収益取得が認定された"], []⟩,
    ⟨.require, "押領者の所領を没収", ["虚偽による押領・収益取得が認定された", "押領者に所領あり"], []⟩,
    ⟨.require, "所領のない押領者を遠流", ["虚偽による押領・収益取得が認定された"], ["押領者に所領あり"]⟩,
    ⟨.forbid, "当知行地につき特段の事情なく安堵御下文を申請", ["当知行地について指すべき事情なし"], []⟩
  ]⟩,
  ⟨44, 253, "兼日の競望の不採用と本来の訴訟を区別。底本の闕所後は非制限という但書を新規の望みの許可として登録。翻刻には但以下十字を欠く異本の注記があり、その異本ではこの許可は導かない。", [
    ⟨.forbid, "傍輩の所領を得るため罪科未定のうちに陥れる", ["傍輩の罪科は未断", "傍輩の所領を望む"], []⟩,
    ⟨.forbid, "幕府が罪科未定時の競望を採用", ["傍輩の所領を罪科未定の時から競望"], []⟩,
    ⟨.permit, "闕所後に新たな所領請求を申し立てる", ["所領が闕所となった", "当該請求は闕所後に新たに起こした望み"], []⟩
  ]⟩,
  ⟨45, 256, "罪科披露と糺決を区別。所職の改替前に調査と判断を要する。", [
    ⟨.forbid, "罪科を理由に所職を改替", ["罪科が披露された"], ["糺決を経た"]⟩,
    ⟨.require, "真相を究めて裁定", ["罪科が披露された"], []⟩
  ]⟩,
  ⟨46, 260, "国司一般の交代でなく所領の得替。重科による没収の対象・主体には解釈がある。", [
    ⟨.require, "新司が所当年貢を沙汰", ["所領の知行者が交代"], []⟩,
    ⟨.forbid, "新司が前司の私物・雑具・所従・牛馬等を抑留", ["所領の知行者が交代"], ["重科による没収の場合"]⟩,
    ⟨.require, "前司に恥辱を与えた新司を別に処罰", ["所領の知行者が交代", "新司が前司に恥辱を与えた"], ["重科による没収の場合"]⟩
  ]⟩,
  ⟨47, 263, "不知行地の文書を用いる寄付と、名主職を本所に無断で寄進する場合。給付先は異文あり。", [
    ⟨.require, "不知行の所領文書で寄付した者を追却", ["不知行所領の文書を用いて他人に寄付"], []⟩,
    ⟨.require, "不知行地の寄付の受領者に寺社修理を課す", ["不知行所領の文書を用いた寄付を受領"], []⟩,
    ⟨.require, "本所無断の寄進者から名主職を召し上げる", ["本所に知らせず名主職を権門に寄付"], []⟩,
    ⟨.require, "召し上げた名主職を他人に付す", ["本所に知らせず名主職を権門に寄付", "地頭がいる"], []⟩,
    ⟨.require, "地頭のいない所で召し上げた名主職を本所に付す", ["本所に知らせず名主職を権門に寄付"], ["地頭がいる"]⟩
  ]⟩,
  ⟨48, 266, "相伝私領の定法を慣行として分離。別御恩の者の売買禁止がどの権利に及ぶかは解釈を要する。", [
    ⟨.custom, "御家人が対象所領を売却", ["要用あり", "対象が相伝の私領"], []⟩,
    ⟨.forbid, "御家人が対象所領を売却", ["対象所領が別御恩の売買禁止の射程に入る"], []⟩,
    ⟨.require, "禁制に背いた売人・買人双方を処罰", ["第48条の制符に背いて売買"], []⟩
  ]⟩,
  ⟨49, 270, "両方の証文で理非が顕然なら対決を経ず直ちに成敗し得る。", [
    ⟨.permit, "対決を経ず直ちに裁定", ["両方の証文で理非が顕然"], []⟩
  ]⟩,
  ⟨50, 274, "実否を聞きに行くだけの場合を、兼日の同意・与力と区別する読み。刑の軽重は時宜。", [
    ⟨.require, "狼藉現場への関与について罪科を科す", ["以前から同意して狼藉に与力"], []⟩,
    ⟨.require, "与力者の罪科の軽重を時宜に応じ裁定", ["以前から同意して狼藉に与力"], []⟩,
    ⟨.forbid, "狼藉現場への関与について罪科を科す", ["子細を知らず実否を聞くために現場に赴いた"], ["以前から同意して狼藉に与力"]⟩
  ]⟩,
  ⟨51, 277, "訴状に就いて問状を発する定例と、顕然の僻事の例外。狼藉の主体を原告に限定しない。", [
    ⟨.custom, "訴状に基づいて問状を発行", ["訴状が提出された"], ["申立てが明白な僻事"]⟩,
    ⟨.forbid, "訴状に基づいて問状を発行", ["申立てが明白な僻事"], []⟩,
    ⟨.require, "問状を帯びて狼藉した者に罪科を科す", ["問状を帯びて狼藉"], []⟩
  ]⟩
]

structure NumberedClause where
  article : Nat
  sourceClause : Nat
  sourceAct : String
  derived : Bool := false
  clause : Clause

def allClauses (source : List Article) : List NumberedClause :=
  source.flatMap fun article =>
    article.clauses.mapIdx fun index clause =>
      { article := article.number, sourceClause := index + 1,
        sourceAct := clause.act, clause := clause }

-- 第41条・第43条の原規則を変更してからこの関数を通す。
-- 派生効果は元の条件・例外を必ず引き継ぐ。子・所領・現在の帰属先等の
-- 同一性は入力の仮定であり、この関数が歴史上の事実を認定するわけではない。
def comparisonRules (source : List NumberedClause) : List NumberedClause :=
  source.flatMap fun entry =>
    let clause := entry.clause
    let extra :=
      if entry.article == 41 &&
          clause.act == "十年を経た奴婢・雑人の帰属を改めて沙汰" then
        ["対象は第41条の年紀に服する子"]
      else if entry.article == 41 &&
          (["奴婢の子の男子を父方に付す", "奴婢の子の女子を母方に付す"].contains clause.act) then
        ["対象は第41条の年紀に服する子",
         "父母への振分けで定まる帰属先が現帰属先と異なる"]
      else if entry.article == 43 &&
          clause.act == "虚偽の押領で奪った物を速やかに糺し返す" then
        ["糺返が当該所領自体に及び現知行者が押領者である"]
      else []
    let effect := if entry.article == 43 then
      "幕府が当該所領の現知行者を交替させる"
      else "当該の子の現帰属を裁定で変更"
    if extra.isEmpty then [entry]
    else [entry, { entry with derived := true, clause := { clause with
      act := effect,
      conditions := clause.conditions ++ extra } }]

def opposite (left right : Mode) : Bool :=
  match left, right with
  | .forbid, .require | .require, .forbid
  | .forbid, .permit | .permit, .forbid
  | .forbid, .custom | .custom, .forbid => true
  | _, _ => false

def applies (clause : Clause) (facts : List String) : Bool :=
  clause.conditions.all facts.contains &&
  !clause.exceptions.any facts.contains

structure Candidate where
  left : NumberedClause
  right : NumberedClause
  present : List String
  absent : List String

def comparable (left right : NumberedClause) : Bool :=
  left.clause.act == right.clause.act &&
    opposite left.clause.mode right.clause.mode

-- 各文字列を独立な命題とみなす限定した判定。自然言語の同義・含意や
-- 事実間の排他関係は判定しない。条件の連言の和集合で同時適用を試す。
def compareClauses (left right : NumberedClause) : Option Candidate :=
  if comparable left right then
    let present := (left.clause.conditions ++ right.clause.conditions).eraseDups
    if applies left.clause present && applies right.clause present then
      some ⟨left, right, present,
        (left.clause.exceptions ++ right.clause.exceptions).eraseDups⟩
    else none
  else none

def findConflicts : List NumberedClause → List Candidate
  | [] => []
  | first :: rest =>
    rest.filterMap (compareClauses first) ++ findConflicts rest

def sameActPairCount : List NumberedClause → Nat
  | [] => 0
  | first :: rest =>
    (rest.filter (fun entry => first.clause.act == entry.clause.act)).length +
      sameActPairCount rest

def comparablePairCount : List NumberedClause → Nat
  | [] => 0
  | first :: rest =>
    (rest.filter (comparable first)).length + comparablePairCount rest

def sourceRules : List NumberedClause := allClauses articles

def baseline : List NumberedClause := comparisonRules sourceRules

structure Reading where
  article : Nat
  acts : List String
  mode : Mode
  exception : String
  explanation : String

-- 原文にない優先関係を初期モデルに埋め込まず、別々に試す。
-- 第41条は比較用効果でなく男女それぞれの原規則を変更する。
def readings : List Reading := [
  ⟨8, ["幕府が当該所領の現知行者を交替させる"], .forbid,
    "虚偽による押領・収益取得が認定された",
    "この第43条型の虚偽押領では、第8条の年紀の保護を外す"⟩,
  ⟨10, ["父に連座の罪科を科す"], .forbid, "子が父祖の敵を殺害",
    "父祖の敵の殺害を、職・財宝目的の場合の父の免責から外す"⟩,
  ⟨41, ["奴婢の子の男子を父方に付す", "奴婢の子の女子を母方に付す"], .require,
    "奴婢・雑人の帰属について無沙汰で十年を経過",
    "十年の年紀が成立した場合は、男女の振分けの原規則とそこからの帰属変更効果を適用しない"⟩,
  ⟨48, ["御家人が対象所領を売却"], .custom,
    "対象所領が別御恩の売買禁止の射程に入る",
    "禁制の射程に入る所領については私領売却の慣行を援用しない"⟩
]

def withReading (rules : List NumberedClause) (reading : Reading) :
    List NumberedClause :=
  rules.map fun entry =>
    let clause := entry.clause
    if entry.article == reading.article && reading.acts.contains clause.act &&
        decide (clause.mode = reading.mode) then
      { entry with clause := { clause with
          exceptions := reading.exception :: clause.exceptions } }
    else entry

def candidatePairs (rules : List NumberedClause) : List (Nat × Nat) :=
  (findConflicts rules).map fun candidate => (candidate.left.article, candidate.right.article)

-- 条文番号対の重複除去は表示用。異なる性別分岐などを同一の実行ケースとはしない。
def candidateArticlePairs (rules : List NumberedClause) : List (Nat × Nat) :=
  (candidatePairs rules).eraseDups

def effectsAt (rules : List NumberedClause) (article : Nat) (mode : Mode)
    (facts : List String) : List String :=
  (rules.filter fun entry => entry.article == article &&
    decide (entry.clause.mode = mode) && applies entry.clause facts).map (·.clause.act)

#guard articles.map Article.number == (List.range 51).map (· + 1)
#guard articles.all (fun article => !article.clauses.isEmpty)
#guard baseline.all (fun entry => applies entry.clause entry.clause.conditions)
#guard candidatePairs baseline == [(8, 43), (10, 10), (41, 41), (41, 41), (48, 48)]
#guard candidateArticlePairs baseline == [(8, 43), (10, 10), (41, 41), (48, 48)]
#guard readings.all (fun reading =>
  (candidateArticlePairs (comparisonRules (withReading sourceRules reading))).length == 3)
#guard (findConflicts (comparisonRules (readings.foldl withReading sourceRules))).isEmpty

-- 第12条: 悪口なしの敗訴は処罰しない。役割は原告・被告を問わない。
#guard (effectsAt sourceRules 12 .require
  ["当該当事者の論所の主張に理なし", "当該当事者に他の所領あり"]).isEmpty
#guard (effectsAt sourceRules 12 .require
  ["当該当事者の論所の主張に理なし"]).isEmpty
#guard ["原告", "被告"].all (fun role =>
  effectsAt sourceRules 12 .require
    [role, "当該当事者が問注中に悪口", "当該当事者の論所の主張に理あり"] ==
      ["悪口を吐いた当事者の相手に論所を付す"] &&
  effectsAt sourceRules 12 .require
    [role, "当該当事者が問注中に悪口", "当該当事者の論所の主張に理なし",
      "当該当事者に他の所領あり"] == ["悪口を吐いた当事者の他の所領を没収"] &&
  effectsAt sourceRules 12 .require
    [role, "当該当事者が問注中に悪口", "当該当事者の論所の主張に理なし"] ==
      ["悪口を吐いた当事者を流罪"])

-- 第41条: 年紀成立時は元の男女分岐と比較用効果の両方が止まる。
-- 年紀が成立しない時と、帰属変更を伴わない時も確認する。
def reading41 : Reading := readings[2]
def interpreted41 : List NumberedClause := withReading sourceRules reading41
#guard ["奴婢の子が男子", "奴婢の子が女子"].all (fun sex =>
  let facts := [sex, "対象は第41条の年紀に服する子",
    "父母への振分けで定まる帰属先が現帰属先と異なる"]
  let expired := "奴婢・雑人の帰属について無沙汰で十年を経過" :: facts
  (effectsAt interpreted41 41 .require expired).isEmpty &&
  (effectsAt (comparisonRules interpreted41) 41 .require expired).isEmpty &&
  (effectsAt interpreted41 41 .require facts).length == 1 &&
  (effectsAt (comparisonRules interpreted41) 41 .require facts).length == 2 &&
  !(effectsAt (comparisonRules interpreted41) 41 .require [sex]).contains
    "当該の子の現帰属を裁定で変更")

-- 第43条: 物・収益の返還だけから知行者変更を推論しない。
#guard !(effectsAt baseline 43 .require
  ["虚偽による押領・収益取得が認定された"]).contains
    "幕府が当該所領の現知行者を交替させる"
#guard (effectsAt baseline 43 .require
  ["虚偽による押領・収益取得が認定された",
    "糺返が当該所領自体に及び現知行者が押領者である"]).contains
      "幕府が当該所領の現知行者を交替させる"

-- 第44条: 闕所後の新規請求の許可は、兼日の競望の自動復活ではない。
#guard (effectsAt sourceRules 44 .permit
  ["所領が闕所となった", "傍輩の所領を罪科未定の時から競望"]).isEmpty
#guard effectsAt sourceRules 44 .forbid
  ["所領が闕所となった", "傍輩の所領を罪科未定の時から競望"] ==
    ["幕府が罪科未定時の競望を採用"]
#guard effectsAt sourceRules 44 .permit
  ["所領が闕所となった", "当該請求は闕所後に新たに起こした望み"] ==
    ["闕所後に新たな所領請求を申し立てる"]

def modeName : Mode → String
  | .require => "義務"
  | .forbid => "禁止"
  | .permit => "明示的許可"
  | .custom => "慣行"

def originName (entry : NumberedClause) : String :=
  s!"第{entry.article}条の原規則{entry.sourceClause}" ++
    (if entry.derived then s!"から導出（{entry.sourceAct}）" else "")

def displayCandidate (candidate : Candidate) : String :=
  let left := candidate.left
  let right := candidate.right
  let present := String.intercalate "、" candidate.present
  let absent :=
    if candidate.absent.isEmpty then "なし"
    else String.intercalate "、" candidate.absent
  s!"第{left.article}条（{modeName left.clause.mode}） / " ++
  s!"第{right.article}条（{modeName right.clause.mode}） — {left.clause.act}\n" ++
  s!"  出所: {originName left} / {originName right}\n" ++
  s!"  成立条件: {present}\n  除外条件: {absent}"

def report : IO Unit := do
  let count := baseline.length
  let candidates := findConflicts baseline
  IO.println s!"登録: {articles.length}条、{sourceRules.length}原規則（全条文内容の完全な形式化ではない）"
  IO.println s!"比較入力: {count}規則（うち原規則から導出した比較用効果{(baseline.filter (·.derived)).length}）"
  IO.println s!"異なる2規則の全組合せ: {count * (count - 1) / 2}組"
  IO.println s!"同一の行為名となる組: {sameActPairCount baseline}組"
  IO.println s!"同一の行為名かつ反対モードとして条件を比較する組: {comparablePairCount baseline}組"
  let customs := candidates.filter fun candidate =>
    decide (candidate.left.clause.mode = .custom ∨ candidate.right.clause.mode = .custom)
  IO.println s!"検出: {candidates.length}比較枝、条文番号対で{(candidateArticlePairs baseline).length}組（うち慣行と禁制の緊張{customs.length}枝）"
  for candidate in candidates do
    IO.println (displayCandidate candidate)
  IO.println "\n個別の解釈を適用した場合"
  for reading in readings do
    let interpreted := comparisonRules (withReading sourceRules reading)
    IO.println s!"  第{reading.article}条: {reading.explanation} → 残る候補 {(findConflicts interpreted).length}枝、条文番号対で{(candidateArticlePairs interpreted).length}組"
  IO.println s!"四つを併用 → 残る候補 {(findConflicts (comparisonRules (readings.foldl withReading sourceRules))).length}枝"
  IO.println "同義の行為名・複合行為・事実間の含意は自動で統合しない。候補ゼロはこの比較範囲と採用した解釈に限る。"
  IO.println "\n全51条の照合メモ"
  for article in articles do
    IO.println s!"  第{article.number}条（翻刻L{article.sourceLine}以下、{article.clauses.length}原規則） {article.note}"

#eval report

end ShikimokuOriginal
