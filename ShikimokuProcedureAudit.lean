/-
御成敗式目の手続を追う有限状態モデル
実行: lean ShikimokuProcedureAudit.lean
原文: https://ja.wikisource.org/wiki/御成敗式目

第6・7・44条の適用が確定した受付段階から始め、第51条の問状、
第35条の召文と不参決、第49条の証文による裁定、第29条の裁許の
留保、第45条の所職改替を扱う。第30・31条等の処分は別の手続。
「受付」は、モデル化した前置の制限に該当しないことだけを表す。

問状と召文は別の出来事。召文の前に問状を置く進行と、召文を
独立に扱う進行の両方を試す。原文に手順の連結は明記されていない。
被告が出頭するか、どの証拠で理非が確認できるか、罪科が糺決
されたかは事案の入力。両方の証文で明白な枝は原告に理がある
場合を代表とする。奉行人の迂回が判明して留保を発動する時点と、
留保を解く時点は、裁定前に到達できる順をモデル内で列挙する。
-/

namespace ShikimokuProcedure

inductive Intake where
  | ordinary
  | withoutHonjoReferral
  | abusiveRepeat
  | prematureRivalClaim
  | plainlyGroundless
  deriving DecidableEq, Repr

inductive Evidence where
  | undecided
  | supportsPlaintiff
  | bothDocumentsClear
  | plaintiffLacksMerit
  deriving DecidableEq, Repr

structure Facts where
  intake : Intake
  evidence : Evidence
  inquiryBeforeSummons : Bool
  defendantAppears : Bool
  bypassedMagistrate : Bool
  officeFaultEstablished : Bool
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
  inquiryIssued : Bool := false
  summonsSent : Nat := 0
  appeared : Bool := false
  defaultRecorded : Bool := false
  meritsExamined : Bool := false
  officeChanged : Bool := false
  deriving Repr

inductive Event where
  | admit
  | stop6
  | stop7
  | stop44
  | issueInquiry51
  | sendSummons35
  | appear
  | recordDefault35
  | examineMerits
  | stayAward29
  | liftStay
  | awardPlaintiff35
  | awardAnother35
  | decideFromDocuments49
  | decideAfterAppearance
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
  | .prematureRivalClaim => (.stop44, { state with stage := .stopped })
  | .ordinary | .plainlyGroundless => (.admit, { state with stage := .admitted })

-- 二つの直接裁定経路を別々に列挙する。
-- 第35条の無理の枝は、条文にいう他への給付が対象となる事案を表す。
def directDecisions (facts : Facts) (state : State) : List Event :=
  if !state.meritsExamined then []
  else
    let under35 :=
      if state.defaultRecorded then
        match facts.evidence with
        | .supportsPlaintiff | .bothDocumentsClear => [.awardPlaintiff35]
        | .plaintiffLacksMerit => [.awardAnother35]
        | .undecided => []
      else []
    let under49 :=
      if facts.evidence == .bothDocumentsClear then [.decideFromDocuments49] else []
    under35 ++ under49

def allowedDuringStay (policy : StayPolicy) (event : Event) : Bool :=
  match policy with
  | .applyDirectRoutesIndependently => true
  | .postponePlaintiffAwards => event == .awardAnother35
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
  let stay :=
    match state.stay with
    | .none =>
      if facts.bypassedMagistrate then [(.stayAward29, { state with stay := .active })]
      else []
    | .active => [(.liftStay, { state with stay := .lifted })]
    | .lifted => []
  -- 留保の射程を、各直接裁定の枝について比較する。
  let direct :=
    (directDecisions facts state).filter fun event =>
      state.stay != .active || allowedDuringStay policy event
  let ordinary :=
    if state.appeared && state.meritsExamined && state.stay != .active then
      [.decideAfterAppearance]
    else []
  let judgments := (direct ++ ordinary).map fun event =>
    (event, { state with stage := .decided })
  inquiry ++ summons ++ appearance ++ nonappearance ++ examination ++ stay ++ judgments

def moves (policy : StayPolicy) (facts : Facts) (state : State) : List Move :=
  match state.stage with
  | .submitted => [intakeMove facts state]
  | .stopped => []
  | .admitted => admittedMoves policy facts state
  | .decided =>
    if facts.officeFaultEstablished && state.meritsExamined && !state.officeChanged then
      [(.replaceOfficeholder45, { state with officeChanged := true })]
    else []

inductive Finding where
  | stayAgainstAward35
  | stayAgainstAwardAnother35
  | stayAgainstDecision49
  | inquiryForPlainlyGroundlessClaim
  | defaultWithoutThreeSummons
  | defaultDespiteAppearance
  | decisionWithoutExaminingMerits
  | officeChangeBeforeFinding
  deriving DecidableEq, Repr

-- 検査は遷移生成から独立し、実際に試みた遷移の直前の状態を判定する。
def findings (facts : Facts) (state : State) (event : Event) : List Finding :=
  match event with
  | .issueInquiry51 =>
    if facts.intake == .plainlyGroundless then [.inquiryForPlainlyGroundlessClaim] else []
  | .awardPlaintiff35 | .awardAnother35 =>
    (if state.summonsSent != 3 || !state.defaultRecorded then [.defaultWithoutThreeSummons] else []) ++
    (if state.appeared then [.defaultDespiteAppearance] else []) ++
    (if !state.meritsExamined then [.decisionWithoutExaminingMerits] else []) ++
    (if state.stay == .active then
      [if event == .awardPlaintiff35 then .stayAgainstAward35 else .stayAgainstAwardAnother35]
     else [])
  | .decideFromDocuments49 =>
    (if !state.meritsExamined then [.decisionWithoutExaminingMerits] else []) ++
    (if state.stay == .active then [.stayAgainstDecision49] else [])
  | .decideAfterAppearance =>
    if !state.meritsExamined then [.decisionWithoutExaminingMerits] else []
  | .replaceOfficeholder45 =>
    if state.stage != .decided || !state.meritsExamined ||
        !facts.officeFaultEstablished then [.officeChangeBeforeFinding] else []
  | _ => []

structure Path where
  state : State
  reversedEvents : List Event

structure Witness where
  finding : Finding
  events : List Event
  deriving Repr

def extend (policy : StayPolicy) (facts : Facts) (path : Path) : List Path :=
  (moves policy facts path.state).map fun (event, next) =>
    ⟨next, event :: path.reversedEvents⟩

def witnessesAt (policy : StayPolicy) (facts : Facts) (path : Path) : List Witness :=
  (moves policy facts path.state).flatMap fun (event, _) =>
    (findings facts path.state event).map fun finding =>
      ⟨finding, (event :: path.reversedEvents).reverse⟩

structure Search where
  witnesses : List Witness
  terminalPaths : Nat
  frontier : List Path

-- 深さごとに展開。12手後の探索前線が全事案で空になることも検査する。
def explore (policy : StayPolicy) (facts : Facts) (depth : Nat)
    (frontier : List Path) : Search :=
  match depth with
  | 0 => ⟨[], 0, frontier⟩
  | remaining + 1 =>
    let next := frontier.flatMap (extend policy facts)
    let terminal := (frontier.filter fun path => (moves policy facts path.state).isEmpty).length
    let rest := explore policy facts remaining next
    ⟨frontier.flatMap (witnessesAt policy facts) ++ rest.witnesses,
      terminal + rest.terminalPaths, rest.frontier⟩

def check (policy : StayPolicy) (facts : Facts) : Search :=
  explore policy facts 12 [⟨{}, []⟩]

def bools : List Bool := [false, true]

def allFacts : List Facts := Id.run do
  let mut cases := #[]
  for intake in [Intake.ordinary, .withoutHonjoReferral, .abusiveRepeat,
      .prematureRivalClaim, .plainlyGroundless] do
    let choices :=
      if intake == .plainlyGroundless then [Evidence.undecided]
      else [.undecided, .supportsPlaintiff, .bothDocumentsClear, .plaintiffLacksMerit]
    for evidence in choices do
      for inquiryBeforeSummons in bools do
        for defendantAppears in bools do
          for bypassedMagistrate in bools do
            for officeFaultEstablished in bools do
              cases := cases.push ⟨intake, evidence, inquiryBeforeSummons,
                defendantAppears, bypassedMagistrate, officeFaultEstablished⟩
  return cases.toList

def exampleCase : Facts :=
  ⟨.ordinary, .bothDocumentsClear, true, false, true, true⟩

def shortest (finding : Finding) (search : Search) : Option Witness :=
  search.witnesses.find? (fun witness => witness.finding == finding)

def follow (policy : StayPolicy) (facts : Facts) (state : State) :
    List Event → Option State
  | [] => some state
  | event :: rest =>
    match (moves policy facts state).find? (fun move => move.1 == event) with
    | none => none
    | some (_, next) => follow policy facts next rest

#guard allFacts.length == 272
#guard allFacts.all fun facts =>
  (check .applyDirectRoutesIndependently facts).frontier.isEmpty &&
  (check .postponePlaintiffAwards facts).frontier.isEmpty &&
  (check .postponeDirectRoutes facts).frontier.isEmpty
#guard (shortest .stayAgainstAward35 (check .applyDirectRoutesIndependently exampleCase)).isSome
#guard (shortest .stayAgainstDecision49 (check .applyDirectRoutesIndependently exampleCase)).isSome
#guard allFacts.all (fun facts => (check .postponeDirectRoutes facts).witnesses.isEmpty)
#guard allFacts.all fun facts =>
  (check .postponePlaintiffAwards facts).witnesses.all fun witness =>
    witness.finding == .stayAgainstAwardAnother35
#guard (follow .postponeDirectRoutes exampleCase {}
  [.admit, .issueInquiry51, .sendSummons35, .sendSummons35, .sendSummons35,
   .recordDefault35, .examineMerits, .stayAward29, .liftStay, .awardPlaintiff35]).isSome
#guard (follow .postponeDirectRoutes exampleCase {}
  [.admit, .examineMerits, .stayAward29, .liftStay, .decideFromDocuments49]).isSome

def report (policy : StayPolicy) : IO Unit := do
  let results := allFacts.map (check policy)
  let flagged := results.filter fun result => !result.witnesses.isEmpty
  IO.println s!"事案 {allFacts.length} / 衝突候補のある事案 {flagged.length} / 終端経路 {(results.map Search.terminalPaths).foldl (· + ·) 0}"
  for finding in [Finding.stayAgainstAward35, .stayAgainstAwardAnother35, .stayAgainstDecision49] do
    let matching := flagged.filter fun result => (shortest finding result).isSome
    IO.println s!"  {repr finding}: {matching.length}事案"

#eval do
  IO.println "第29条の留保と直接裁定を独立に適用"
  report .applyDirectRoutesIndependently
  let exampleSearch := check .applyDirectRoutesIndependently exampleCase
  IO.println s!"問状を経る例の第35条の経路 {repr (shortest .stayAgainstAward35 exampleSearch)}"
  IO.println s!"同じ事案の第49条の経路 {repr (shortest .stayAgainstDecision49 exampleSearch)}"
  IO.println "第29条の留保を原告への裁許に限る（広義の留保を基準に照合）"
  report .postponePlaintiffAwards
  IO.println "第29条の留保中は直接裁定も見合わせる"
  report .postponeDirectRoutes

end ShikimokuProcedure
