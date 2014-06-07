Require Import List.
Require Import Bool.
Require Import ZArith.
Require Import pomozne.
Require Import Recdef.


Local Open Scope list_scope.

Fixpoint najmanjsi (x : Z) (l : list Z) :=
  match l with
    | nil => (x,nil)
    | y :: l' => let (z,l'') := najmanjsi y l' in if (Z.leb x z) then (x,l) else (z,x::l'')
  end.

Eval compute in (najmanjsi 5%Z (7::20::3::nil)%Z).

Lemma naj_head (x : Z) (l : list Z) :
  (fst (najmanjsi x l) <= x)%Z.
Proof.
  induction l.
  - simpl.
    apply Z.le_refl.
  - simpl.
    replace (najmanjsi a l) with (fst (najmanjsi a l), snd (najmanjsi a l));
      [ idtac | symmetry ; apply surjective_pairing ].
    case_eq (Z.leb x (fst (najmanjsi a l))).
    + intro.
      simpl; apply Z.le_refl.
    + intro.
      simpl.
      apply Z.leb_gt in H.
      firstorder.
Qed.

Lemma najmanjsi_dod (x y : Z) (l : list Z) :
  (fst(najmanjsi x (y :: l)) <= fst(najmanjsi x l))%Z.
Proof.
  induction l.
   - simpl.
     case_eq (Z.leb x y).
      + intro.
        simpl.
        apply Z.le_refl.
      + intro.
        simpl.
        apply Z.leb_gt in H.
        firstorder.
   - simpl.
     replace (najmanjsi a l) with (fst (najmanjsi a l), snd (najmanjsi a l));
      [ idtac | symmetry ; apply surjective_pairing ].
     case_eq (Z.leb y (fst (najmanjsi a l)));
     case_eq (Z.leb x (fst (najmanjsi a l)));
     case_eq (Z.leb x y).
      + intros G H F.
        simpl.
        apply Z.le_refl.
      + intros G H F.
        simpl.
        apply Z.leb_gt in G.
        firstorder.
      + intros G H F.
        simpl.
        transitivity y.
        now apply Zle_is_le_bool in G.
        now apply Zle_is_le_bool in F.
      + intros G H F.
        simpl.
        now apply Zle_is_le_bool in F.
      + intros G H F.
        simpl.
        apply Z.le_refl.
      + intros G H F; simpl.
        apply Z.le_refl.
      + intros G H F; simpl.
        apply Z.le_refl.
      + intros G H F; simpl.
        apply Z.le_refl.
Qed.

Lemma najmanjsi_dod2 (x y z : Z) (l : list Z) :
  (fst(najmanjsi x (y :: z :: l)) <= fst(najmanjsi x (y :: l)))%Z.
Proof.
  induction l.
  - simpl.
    case_eq (Z.leb y z);
    case_eq (Z.leb x y);
    case_eq (Z.leb x z); 
    intros G H F; 
    simpl;
    try apply Z.le_refl.
    + apply Z.leb_gt in G;firstorder.
    + apply Z.leb_gt in F.
      apply Zle_is_le_bool in G.
      transitivity z; firstorder.
    + apply Z.leb_gt in F;firstorder.
  - simpl.
    replace (najmanjsi a l) with (fst (najmanjsi a l), snd (najmanjsi a l));
      [ idtac | symmetry ; apply surjective_pairing ].
    case_eq (Z.leb z (fst(najmanjsi a l)));
    case_eq (Z.leb y (fst(najmanjsi a l)));
    case_eq (Z.leb x (fst(najmanjsi a l)));
    case_eq (Z.leb x y);
    case_eq (Z.leb y z);
    case_eq (Z.leb x z);
    intros G H F E D C; simpl;
    try apply Z.le_refl;
    try (rewrite F; simpl; apply Z.le_refl);
    try (rewrite G; simpl; apply Z.le_refl);
    try (rewrite H; simpl; apply Z.le_refl);
    try (apply Z.leb_gt in G; firstorder);
    try (apply Z.leb_gt in F; firstorder);
    try (apply Z.leb_gt in H; firstorder).
    + transitivity z.
      now apply Zle_is_le_bool in G.
      firstorder.
    + transitivity z.
      now apply Zle_is_le_bool in G.
      firstorder.
    + apply Z.leb_gt in F.
      rewrite F.
      simpl.
      apply Z.leb_gt in F.
      firstorder.
    + apply Z.leb_gt in F.
      rewrite F.
      simpl.
      apply Z.leb_gt in F.
      firstorder.
    + rewrite F.
      simpl.
      transitivity z.
      now apply Zle_is_le_bool in G.
      now apply Zle_is_le_bool in C.
    + rewrite F; simpl.
      transitivity z.
      transitivity y.
      now apply Zle_is_le_bool in F.
      now apply Zle_is_le_bool in H.
      now apply Zle_is_le_bool in C.
    + transitivity z.
      now apply Zle_is_le_bool in G.
      now apply Zle_is_le_bool in C.
    + now apply Zle_is_le_bool in C.
    + apply Z.leb_gt in F; rewrite F; simpl.
      transitivity z.
      now apply Zle_is_le_bool in H.
      now apply Zle_is_le_bool in C.
    + apply Z.leb_gt in F; rewrite F; simpl.
      transitivity z.
      now apply Zle_is_le_bool in H.
      now apply Zle_is_le_bool in C.
    + transitivity z.
      now apply Zle_is_le_bool in G.
      now apply Zle_is_le_bool in C.
    + now apply Zle_is_le_bool in C.
Qed.   
      

Lemma najmanjsi_pod (x y : Z) (l : list Z) :
  (x <= fst(najmanjsi x (y :: l)))%Z -> (x <= fst(najmanjsi x l))%Z.
Proof.
  intro.
  induction l.
  - simpl.
    apply Z.le_refl.
  - transitivity (fst(najmanjsi x (y :: a :: l))).
    assumption.
    apply najmanjsi_dod.
Qed.

Lemma pomo (x y : Z) (l : list Z) :
  (x <= fst (najmanjsi x (y :: l)))%Z -> (x <= fst (najmanjsi y l))%Z.
Proof.
  intro.
  simpl.
  simpl in H.
  replace (najmanjsi y l) with (fst (najmanjsi y l), snd (najmanjsi y l)) in H;
      [ idtac | symmetry ; apply surjective_pairing ].
  case_eq (Z.leb x (fst(najmanjsi y l))).
  - intro G.
    now apply Zle_is_le_bool in G.
  - intro G.
    rewrite G in H.
    now simpl in H.
Qed.

Lemma najmanjsi_ostanek (x : Z) (l : list Z) :
  (x <= fst (najmanjsi x l))%Z -> l = snd (najmanjsi x l).
Proof.
  intro.
  induction l; auto.
  simpl.
  replace (najmanjsi a l) with (fst (najmanjsi a l), snd (najmanjsi a l));
      [ idtac | symmetry ; apply surjective_pairing ].
  
  case_eq (Z.leb x (fst(najmanjsi a l))).
  + now intro G.
  + intro G; simpl.
    apply pomo in H.
    apply Z.leb_gt in G.
    apply Zlt_not_le in G.
    contradiction.
Qed.

Lemma naj_tail (x y : Z) (l : list Z) :
  In y (snd (najmanjsi x l)) -> (fst (najmanjsi x l) <= y)%Z.
Proof.
  intro.
  induction l.
  - simpl in H.
    contradiction.
  - simpl.
    replace (najmanjsi a l) with (fst (najmanjsi a l), snd (najmanjsi a l));
      [ idtac | symmetry ; apply surjective_pairing ].
    case_eq (Z.leb x (fst(najmanjsi a l))).
    + intro G.
      simpl.
      simpl in H.
      replace (najmanjsi a l) with (fst (najmanjsi a l), snd (najmanjsi a l)) in H;
          [ idtac | symmetry ; apply surjective_pairing ].
      rewrite G in H.
      simpl in H.
      destruct H.
      * rewrite H in G.
        apply Zle_bool_imp_le in G.
        assert ((fst (najmanjsi y l) <= y)%Z).
        apply naj_head.
        transitivity (fst (najmanjsi y l)).
        assumption. assumption.
      * admit.
    + intro G.
      simpl.
      admit.
Qed.
  


Lemma ohranjanje_dolzine (x:Z) (l: list Z) :
  length (snd (najmanjsi x l)) = length l.
Proof.
  induction l;auto.
  simpl.
  replace (najmanjsi a l) with (fst (najmanjsi a l), snd (najmanjsi a l));
      [ idtac | symmetry ; apply surjective_pairing ].
  case_eq (Z.leb x (fst (najmanjsi a l))).
    + intro.
      simpl.
      auto.
    + intro.
      simpl.
      .
      admit.
Qed.
    

    
Function brutesort (l : list Z) {measure length l} :=
  match l with 
    | nil => nil
    | x::l' => let (y,l'') := najmanjsi x l' in y::(brutesort l'')
end.
Proof.
  intros.
  simpl.
  rewrite  <- (ohranjanje_dolzine x l').
  rewrite teq0.
  simpl.
  auto.
Qed.

Eval compute in (brutesort (2::5::1::3::nil)%Z).
  
  



