/-
御成敗式目の手続を追う有限状態モデル
実行: lean ShikimokuProcedureAudit.lean
原文: https://ja.wikisource.org/wiki/御成敗式目

第6・7条の受付、第44条の競望の不採用、第51条の問状、
第35条の召文と不参決、第49条の証文による裁定、第29条の留保、
第45条の所職改替を扱う。判決は一つの本案についてのものとする。
競望は本案と別の申出であり、その不採用によって本案を止めない。
競望を受付の直前に審査する位置はモデル上の仮定である。

問状と召文の接続は原文に明記されず、問状を前提とする進行と
しない進行を比較する。証拠の結論と双方の証文の明白さを分ける。
奉行人の迂回事実、裁判側に判明する時点、留保発動を区別するのは
モデル上の仮定である。判明前の裁定は許し、違反検査の対象外。
原文は判明イベントや留保の解除条件を定めていない。解除は外部判断
として列挙し、二十日経過で自動解除する規則は設けない。
第45条の糺決と、別の規則による改易根拠を分けて入力する。
所職改替を本案の裁定後に置く順序も仮定であり、同条からは導かない。
-/

namespace ShikimokuProcedure

inductive Intake where
  | ordinary
  | withoutHonjoReferral
  | abusiveRepeat
  | plainlyGroundless
  deriving DecidableEq, Repr

inductive Evidence where
  | undecided
  | supportsPlaintiff
  | plaintiffLacksMerit
  deriving DecidableEq, Repr

structure Facts where
  intake : Intake
  evidence : Evidence
  bothDocumentsClear : Bool
  inquiryBeforeSummons : Bool
  defendantAppears : Bool
  bypassedMagistrate : Bool
  prematureRivalClaim : Bool
  officeInvestigationComplete : Bool
  removalGroundFromOtherRule : Bool
  deriving Repr

inductive Stage where
  | submitted
  | stopped
  | admitted
  | decided
  deriving DecidableEq, Repr

inductive Stay where
  | none
  | active
  | lifted
  deriving DecidableEq, Repr

structure State where
  stage : Stage := .submitted
  stay : Stay := .none
  competitionRejected : Bool := false
  bypassKnown : Bool := false
  inquiryIssued : Bool := false
  summonsSent : Nat := 0
  appeared : Bool := false
  defaultRecorded : Bool := false
  meritsExamined : Bool := false
  officeChanged : Bool := false
  deriving DecidableEq, Repr

inductive Event where
  | rejectCompetition44
  | admit
  | stop6
  | stop7
  | issueInquiry51
  | sendSummons35
  | appear
  | recordDefault35
  | examineMerits
  | discoverBypass29
  | stayAward29
  | liftStay
  | awardPlaintiff35
  | awardAnother35
  | decidePlaintiffFromDocuments49
  | denyPlaintiffFromDocuments49
  | decidePlaintiffAfterAppearance
  | denyPlaintiffAfterAppearance
  | replaceOfficeholder45
  deriving DecidableEq, Repr

inductive StayPolicy where
  | applyDirectRoutesIndependently
  | postponePlaintiffAwards
  | postponeDirectRoutes
  deriving DecidableEq

abbrev Move := Event × State

def intakeMove (facts : Facts) (state : State) : Move :=
  match facts.intake with
  | .withoutHonjoReferral => (.stop6, { state with stage := .stopped })
  | .abusiveRepeat => (.stop7, { state with stage := .stopped })
  | .ordinary | .plainlyGroundless => (.admit, { state with stage := .admitted })

-- 第35条の無理の枝は、他への給付が対象となる事案に限定する。
-- 第49条の原告請求を認めない裁定と、第三者への給付を同一視しない。
-- 原告の無理は、被告自身に積極的な権原があることまでは意味しない。
def directDecisions (facts : Facts) (state : State) : List Event :=
  if !state.meritsExamined then []
  else
    let under35 :=
      if state.defaultRecorded then
        match facts.evidence with
        | .supportsPlaintiff => [.awardPlaintiff35]
        | .plaintiffLacksMerit => [.awardAnother35]
        | .undecided => []
      else []
    let under49 :=
      if facts.bothDocumentsClear then
        match facts.evidence with
        | .supportsPlaintiff => [.decidePlaintiffFromDocuments49]
        | .plaintiffLacksMerit => [.denyPlaintiffFromDocuments49]
        | .undecided => []
      else []
    under35 ++ under49

def isDirectDecision : Event → Bool
  | .awardPlaintiff35 | .awardAnother35
  | .decidePlaintiffFromDocuments49 | .denyPlaintiffFromDocuments49 => true
  | _ => false

def isDecision (event : Event) : Bool :=
  isDirectDecision event || event == .decidePlaintiffAfterAppearance ||
    event == .denyPlaintiffAfterAppearance

def awardsPlaintiff : Event → Bool
  | .awardPlaintiff35 | .decidePlaintiffFromDocuments49
  | .decidePlaintiffAfterAppearance => true
  | _ => false

def allowedWhenKnown (policy : StayPolicy) (event : Event) : Bool :=
  match policy with
  | .applyDirectRoutesIndependently => isDirectDecision event
  | .postponePlaintiffAwards => !awardsPlaintiff event
  | .postponeDirectRoutes => false

def admittedMoves (policy : StayPolicy) (facts : Facts) (state : State) : List Move :=
  let inquiry :=
    if !state.inquiryIssued && facts.intake != .plainlyGroundless then
      [(.issueInquiry51, { state with inquiryIssued := true })]
    else []
  let summons :=
    if state.summonsSent < 3 && !state.appeared &&
        (!facts.inquiryBeforeSummons || state.inquiryIssued) then
      [(.sendSummons35, { state with summonsSent := state.summonsSent + 1 })]
    else []
  let appearance :=
    if facts.defendantAppears && state.summonsSent > 0 && !state.appeared then
      [(.appear, { state with appeared := true })]
    else []
  let nonappearance :=
    if state.summonsSent == 3 && !state.appeared &&
        !facts.defendantAppears && !state.defaultRecorded then
      [(.recordDefault35, { state with defaultRecorded := true })]
    else []
  let examination :=
    if !state.meritsExamined && facts.evidence != .undecided then
      [(.examineMerits, { state with meritsExamined := true })]
    else []
  let discovery :=
    if facts.bypassedMagistrate && !state.bypassKnown then
      [(.discoverBypass29, { state with bypassKnown := true })]
    else []
  let stay :=
    match state.stay with
    | .none =>
      if state.bypassKnown then [(.stayAward29, { state with stay := .active })]
      else []
    | .active => [(.liftStay, { state with stay := .lifted })]
    | .lifted => []
  let ordinary :=
    if state.appeared && state.meritsExamined then
      match facts.evidence with
      | .supportsPlaintiff => [.decidePlaintiffAfterAppearance]
      | .plaintiffLacksMerit => [.denyPlaintiffAfterAppearance]
      | .undecided => []
    else []
  -- 判明後・未発動も制限対象。判明前は検査の射程外とする。
  let judgments := ((directDecisions facts state) ++ ordinary).filter fun event =>
    !state.bypassKnown || (state.stay == Stay.lifted) || allowedWhenKnown policy event
  let decisions : List Move := judgments.map fun event => (event, { state with stage := .decided })
  inquiry ++ summons ++ appearance ++ nonappearance ++ examination ++ discovery ++ stay ++ decisions

def moves (policy : StayPolicy) (facts : Facts) (state : State) : List Move :=
  match state.stage with
  | .submitted =>
    if facts.prematureRivalClaim && !state.competitionRejected then
      [(.rejectCompetition44, { state with competitionRejected := true })]
    else [intakeMove facts state]
  | .stopped => []
  | .admitted => admittedMoves policy facts state
  | .decided =>
    -- 糺決は必要条件。具体的な改易根拠は第45条以外から与える。
    if facts.officeInvestigationComplete && facts.removalGroundFromOtherRule &&
        state.meritsExamined && !state.officeChanged then
      [(.replaceOfficeholder45, { state with officeChanged := true })]
    else []

inductive Finding where
  | decisionBeforeStayActivation29
  | decisionDuringStay29
  | inquiryForPlainlyGroundlessClaim
  | defaultWithoutThreeSummons
  | defaultDespiteAppearance
  | decisionWithoutExaminingMerits
  | documentsDecisionWithoutClearEvidence
  | officeChangeWithoutInvestigation
  | officeChangeWithoutRemovalGround
  deriving DecidableEq, Repr

-- 広義の留保を共通の照合基準とし、各解釈との差を検出する。
-- これは各解釈そのものの論理矛盾という意味ではない。
def findings (facts : Facts) (state : State) (event : Event) : List Finding :=
  let decisionChecks :=
    if isDecision event then
      (if !state.meritsExamined then [.decisionWithoutExaminingMerits] else []) ++
      (if state.bypassKnown && state.stay == .none then [.decisionBeforeStayActivation29]
       else if state.stay == .active then [.decisionDuringStay29] else [])
    else []
  let specific :=
    match event with
    | .issueInquiry51 =>
      if facts.intake == .plainlyGroundless then [.inquiryForPlainlyGroundlessClaim] else []
    | .awardPlaintiff35 | .awardAnother35 =>
      (if state.summonsSent != 3 || !state.defaultRecorded then [.defaultWithoutThreeSummons] else []) ++
      (if state.appeared then [.defaultDespiteAppearance] else [])
    | .decidePlaintiffFromDocuments49 | .denyPlaintiffFromDocuments49 =>
      if !facts.bothDocumentsClear || facts.evidence == .undecided then
        [.documentsDecisionWithoutClearEvidence] else []
    | .replaceOfficeholder45 =>
      (if !facts.officeInvestigationComplete then [.officeChangeWithoutInvestigation] else []) ++
      (if !facts.removalGroundFromOtherRule then [.officeChangeWithoutRemovalGround] else [])
    | _ => []
  decisionChecks ++ specific

structure Path where
  state : State
  reversedEvents : List Event
  multiplicity : Nat := 1

structure Witness where
  finding : Finding
  events : List Event
  deriving Repr

def extend (policy : StayPolicy) (facts : Facts) (path : Path) : List Path :=
  (moves policy facts path.state).map fun (event, next) =>
    ⟨next, event :: path.reversedEvents, path.multiplicity⟩

def witnessesAt (policy : StayPolicy) (facts : Facts) (path : Path) : List Witness :=
  (moves policy facts path.state).flatMap fun (event, _) =>
    (findings facts path.state event).map fun finding =>
      ⟨finding, (event :: path.reversedEvents).reverse⟩

structure Search where
  witnesses : List Witness
  terminalPaths : Nat
  frontier : List Path

-- 同じ深さの同じ状態をまとめ、到達経路数を加算する。
-- 遷移と検査は履歴でなく状態・入力だけに依存するため、存在する経路を
-- 失わない。反例には代表の最短経路を一つ保持し、終端経路数は全順序を数える。
def mergeFrontier (paths : List Path) : List Path :=
  paths.foldl (fun merged path =>
    if merged.any (fun old => old.state == path.state) then
      merged.map fun old =>
        if old.state == path.state then
          { old with multiplicity := old.multiplicity + path.multiplicity }
        else old
    else merged ++ [path]) []

-- 14手後に探索前線が空であることも検査する。
-- compact=false は代表事案で集約前後を比較するために使用する。
def explore (policy : StayPolicy) (facts : Facts) (compact : Bool) (depth : Nat)
    (frontier : List Path) : Search :=
  match depth with
  | 0 => ⟨[], 0, frontier⟩
  | remaining + 1 =>
    let expanded := frontier.flatMap (extend policy facts)
    let next := if compact then mergeFrontier expanded else expanded
    let terminal := (frontier.filter fun path => (moves policy facts path.state).isEmpty)
      |>.foldl (fun count path => count + path.multiplicity) 0
    let rest := explore policy facts compact remaining next
    ⟨frontier.flatMap (witnessesAt policy facts) ++ rest.witnesses,
      terminal + rest.terminalPaths, rest.frontier⟩

def check (policy : StayPolicy) (facts : Facts) : Search :=
  explore policy facts true 14 [⟨{}, [], 1⟩]

def bools : List Bool := [false, true]

-- 明白な僻事は証拠未確定とする比較用の設定。
-- 双方証文明白かつ理非未確定という矛盾した入力は列挙しない。
def allFacts : List Facts := Id.run do
  let mut cases := #[]
  for intake in [Intake.ordinary, .withoutHonjoReferral, .abusiveRepeat, .plainlyGroundless] do
    let choices :=
      if intake == .plainlyGroundless then [Evidence.undecided]
      else [.undecided, .supportsPlaintiff, .plaintiffLacksMerit]
    for evidence in choices do
      for bothDocumentsClear in (if evidence == .undecided then [false] else bools) do
        for inquiryBeforeSummons in bools do
          for defendantAppears in bools do
            for bypassedMagistrate in bools do
              for prematureRivalClaim in bools do
                for officeInvestigationComplete in bools do
                  for removalGroundFromOtherRule in bools do
                    cases := cases.push ⟨intake, evidence, bothDocumentsClear,
                      inquiryBeforeSummons, defendantAppears, bypassedMagistrate,
                      prematureRivalClaim, officeInvestigationComplete, removalGroundFromOtherRule⟩
  return cases.toList

def exampleCase : Facts :=
  ⟨.ordinary, .supportsPlaintiff, true, true, false, true, false, true, true⟩

def shortest (finding : Finding) (search : Search) : Option Witness :=
  search.witnesses.find? (fun witness => witness.finding == finding)

def follow (policy : StayPolicy) (facts : Facts) (state : State) :
    List Event → Option State
  | [] => some state
  | event :: rest =>
    match (moves policy facts state).find? (fun move => move.1 == event) with
    | none => none
    | some (_, next) => follow policy facts next rest

-- 集約前後で終端経路数、検出する(違反,イベント)の組、最短反例長が一致する。
#guard let compact := check .applyDirectRoutesIndependently exampleCase
       let expanded := explore .applyDirectRoutesIndependently exampleCase false 14 [⟨{}, [], 1⟩]
       let kinds := fun (result : Search) =>
         (result.witnesses.map fun witness => (witness.finding, witness.events.getLast?)).eraseDups
       compact.terminalPaths == expanded.terminalPaths &&
       compact.frontier.isEmpty == expanded.frontier.isEmpty &&
       (kinds compact).all (kinds expanded).contains &&
       (kinds expanded).all (kinds compact).contains &&
       [Finding.decisionBeforeStayActivation29, .decisionDuringStay29].all (fun finding =>
         (shortest finding compact).map (fun witness => witness.events.length) ==
         (shortest finding expanded).map (fun witness => witness.events.length))

#guard allFacts.length == 1024
#guard allFacts.all (fun facts => !facts.bothDocumentsClear || facts.evidence != .undecided)
#guard (allFacts.filter (fun facts => !(check .applyDirectRoutesIndependently facts).witnesses.isEmpty)).length == 96
#guard (allFacts.filter (fun facts => !(check .postponePlaintiffAwards facts).witnesses.isEmpty)).length == 64
#guard allFacts.all fun facts =>
  (check .applyDirectRoutesIndependently facts).frontier.isEmpty &&
  (check .postponePlaintiffAwards facts).frontier.isEmpty &&
  (check .postponeDirectRoutes facts).frontier.isEmpty
#guard (shortest .decisionBeforeStayActivation29 (check .applyDirectRoutesIndependently exampleCase)).isSome
#guard (shortest .decisionDuringStay29 (check .applyDirectRoutesIndependently exampleCase)).isSome
#guard allFacts.all (fun facts => (check .postponeDirectRoutes facts).witnesses.isEmpty)
#guard allFacts.all fun facts =>
  (check .postponePlaintiffAwards facts).witnesses.all fun witness =>
    (witness.finding == .decisionBeforeStayActivation29 || witness.finding == .decisionDuringStay29) &&
    (witness.events.getLast? == some .awardAnother35 ||
     witness.events.getLast? == some .denyPlaintiffFromDocuments49 ||
     witness.events.getLast? == some .denyPlaintiffAfterAppearance)

-- 第44条：競望を拒否しても、別の本案は裁定できる。
#guard (follow .postponeDirectRoutes { exampleCase with prematureRivalClaim := true } {}
  [.rejectCompetition44, .admit, .examineMerits, .decidePlaintiffFromDocuments49]).isSome
-- 第49条：双方の証文で原告の無理が明白な枝。狭義留保でも請求を退けられる。
#guard (follow .postponePlaintiffAwards { exampleCase with evidence := .plaintiffLacksMerit } {}
  [.admit, .examineMerits, .discoverBypass29, .stayAward29, .denyPlaintiffFromDocuments49]).isSome
#guard !(follow .postponePlaintiffAwards exampleCase {}
  [.admit, .examineMerits, .discoverBypass29, .stayAward29, .decidePlaintiffFromDocuments49]).isSome
-- 第29条：厳格設定は判明後・未発動でも裁定を止める。判明前は射程外。
#guard !(follow .postponeDirectRoutes exampleCase {}
  [.admit, .examineMerits, .discoverBypass29, .decidePlaintiffFromDocuments49]).isSome
#guard (follow .postponeDirectRoutes exampleCase {}
  [.admit, .examineMerits, .decidePlaintiffFromDocuments49]).isSome
#guard (follow .postponeDirectRoutes exampleCase {}
  [.admit, .issueInquiry51, .sendSummons35, .sendSummons35, .sendSummons35,
   .recordDefault35, .examineMerits, .discoverBypass29, .stayAward29, .liftStay, .awardPlaintiff35]).isSome
#guard (follow .postponeDirectRoutes exampleCase {}
  [.admit, .examineMerits, .discoverBypass29, .stayAward29, .liftStay, .decidePlaintiffFromDocuments49]).isSome
-- 第45条：糺決のみでも改易根拠のみでも所職改替を許さない。
#guard !(follow .postponeDirectRoutes { exampleCase with removalGroundFromOtherRule := false } {}
  [.admit, .examineMerits, .decidePlaintiffFromDocuments49, .replaceOfficeholder45]).isSome
#guard !(follow .postponeDirectRoutes { exampleCase with officeInvestigationComplete := false } {}
  [.admit, .examineMerits, .decidePlaintiffFromDocuments49, .replaceOfficeholder45]).isSome
#guard (follow .postponeDirectRoutes exampleCase {}
  [.admit, .examineMerits, .decidePlaintiffFromDocuments49, .replaceOfficeholder45]).isSome

def report (policy : StayPolicy) : IO Unit := do
  let results := allFacts.map (check policy)
  let flagged := results.filter fun result => !result.witnesses.isEmpty
  IO.println s!"事案 {allFacts.length} / 衝突候補のある事案 {flagged.length} / 終端経路 {(results.map Search.terminalPaths).foldl (· + ·) 0}"
  for finding in [Finding.decisionBeforeStayActivation29, .decisionDuringStay29] do
    let matching := flagged.filter fun result => (shortest finding result).isSome
    IO.println s!"  {repr finding}: {matching.length}事案"
  for event in [Event.awardPlaintiff35, .awardAnother35,
      .decidePlaintiffFromDocuments49, .denyPlaintiffFromDocuments49,
      .decidePlaintiffAfterAppearance, .denyPlaintiffAfterAppearance] do
    let matching := flagged.filter fun result =>
      result.witnesses.any (fun witness => witness.events.getLast? == some event)
    IO.println s!"  {repr event}: {matching.length}事案"

#eval do
  IO.println "第29条の制限と直接裁定を独立に適用（広義の留保を基準に照合）"
  report .applyDirectRoutesIndependently
  let exampleSearch := check .applyDirectRoutesIndependently exampleCase
  IO.println s!"判明後・留保未発動の経路 {repr (shortest .decisionBeforeStayActivation29 exampleSearch)}"
  IO.println s!"留保中の経路 {repr (shortest .decisionDuringStay29 exampleSearch)}"
  IO.println "第29条の制限を原告への裁許に限る（広義の留保を基準に照合）"
  report .postponePlaintiffAwards
  IO.println "判明後は直接裁定を含む全裁定を留保解除まで見合わせる"
  report .postponeDirectRoutes

end ShikimokuProcedure
