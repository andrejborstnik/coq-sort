(** Podpora za algoritme za urejanje. *)

(** Delali bomo s seznami celih števil, pri čemer bomo uporabljali
    cela števila iz knjižnice [ZArith]. To so binarna cela števila,
    s katerimi lahko "učinkovito" računamo. *)

Require Import List.
Require Import Bool.
Require Import ZArith.

(** Aktiviramo notacijo za sezname. *)
Local Open Scope list_scope.
Local Open Scope Z_scope.

(** Najprej je treba definirati pojma "seznam je urejen" in
    "seznam [l1] je permutacija seznama [l2]". 
*)

(** Seznam je urejen, če je prazen, ima en element, ali je
    oblike [x :: y :: _], kjer je [x <= y] in je rep
    [y :: _] urejen. 

    Uporabili bomo vzorec [(y :: _) as l'], ki pomeni "seznam
    [l'] oblike [y :: _]". S tem hkrati dobimo prvi element
    seznama [y] in celoten seznam [l'].
*)
Fixpoint urejen (l : list Z) :=
  match l with
    | nil => True
    | _ :: nil => True
    | x :: ((y :: _) as l') => x <= y /\ urejen l'
  end.

(** Razne koristne leme o urejenosti. *)

Lemma urejen_tail (x : Z) (l : list Z) :
  urejen (x :: l) -> urejen l.
Proof.
  induction l ; firstorder.
Qed.

Lemma urejen_head (x : Z) (l : list Z) :
  urejen (x :: l) -> forall y, In y l -> x <= y.
Proof.
  generalize x ; clear x.
  induction l.
  - simpl ; tauto.
  - intros x [H G] z [K|K].
    + now destruct K.
    + transitivity a ; auto.
Qed.

Lemma urejen_lt_cons (x : Z) (l : list Z) :
  (forall y : Z, In y l -> x <= y) -> urejen l -> urejen (x :: l).
Proof.
  intros H G.
  induction l ; [ simpl ; auto | idtac ].
  split.
  - apply H ; simpl ; auto.
  - destruct l ; simpl ; auto.
Qed.

Lemma urejen_dodatek (x y : Z) (l : list Z) :
  (x<=y)%Z /\ urejen (y :: l) -> urejen (x :: y :: l).
Proof.
  intro.
  induction l; firstorder.
Qed.

Lemma urejen_menjava (x y : Z) (l : list Z) :
  (x<=y)%Z /\ urejen (y :: l) -> urejen (x :: l).
Proof.
  intro.
  induction l ; firstorder.
Qed.

Lemma urejen_pod (x : Z) (l : list Z) :
  urejen (x :: l) -> urejen l.
Proof.
  induction l; firstorder.
Qed.

Lemma urejen_pod2 (x y : Z) (l : list Z) :
  urejen (x :: y :: l) -> urejen (x :: l).
Proof.
  intros.
  destruct H.
  apply (urejen_menjava x y).
  firstorder.
Qed.  

Lemma urejen_prvi (x y : Z) (l : list Z) :
  urejen (x :: l) -> In y l -> (x <= y)%Z.
Proof.
  intros G H.
  induction l; firstorder.
  apply IHl.
  apply (urejen_menjava x a l).
  firstorder.
  assumption.
Qed.

(** Za permutacije potrebujemo funkcijo, ki prešteje, kolikokrat
    se dano število [k] pojavi v seznamu [l]. *)
Fixpoint pojavi (x : Z) (l : list Z) : nat :=
  match l with
    | nil => O
    | y :: l' =>
      if x =? y then S (pojavi x l') else pojavi x l'
  end.

(** Zveza med [pojavi] in stikanjem seznamov. *)
Lemma pojavi_app (x : Z) (l1 l2 : list Z) :
  pojavi x (l1 ++ l2) = (pojavi x l1 + pojavi x l2)%nat.
Proof.
  induction l1 ; simpl ; auto.
  case (x =? a) ; omega.
Qed.

(** Seznama [l1] in [l2] sta enaka, če imata isto število pojavitev
    za vsak [x]. *)
Definition permutiran (l1 l2 : list Z) :=
  forall x : Z, pojavi x l1 = pojavi x l2.

(** Uvedemo notacijo za [permutiran l1 l2]. *)
Notation "l1 ~~ l2" := (permutiran l1 l2) (at level 70).

(** Relacija [permutiran] je ekvivalenčna relacija. *)
Lemma permutiran_refl (l : list Z) : l ~~ l.
Proof.
  intro ; reflexivity.
Qed.

Lemma permutiran_sym (l1 l2 : list Z) : l1 ~~ l2 -> l2 ~~ l1.
Proof.
  intros E x.
  symmetry.
  apply E.
Qed.

Lemma permutiran_tran (l1 l2 l3 : list Z) : l1 ~~ l2 -> l2 ~~ l3 -> l1 ~~ l3.
Proof.
  intros E1 E2 x.
  transitivity (pojavi x l2) ; auto.
Qed.
  
(** Potrebovali bomo tudi operacije, ki sezname razdelijo na dva
    podseznama. Na primer, v urejanju z zlivanjem seznam razdelimo
    takole: *)
Fixpoint razpolovi (l : list Z) :=
  match l with
    | nil => (nil, nil)
    | x :: nil => (nil, x :: nil)
    | x :: y :: l' =>
      let (l1, l2) := razpolovi l' in
        (x :: l1, y :: l2)
  end.

(** To je pomožna oblika indukcije na seznamih. Pravi, pa tole:
    denimo, da lastnost P in da

    - nil ima lastnost P
    - seznam z enim elementom (x :: nil) ima lastnost P, za vsak x
    - če ima seznam l lastnost P, potem ima tudi x :: y :: l lastnost P,
      za vse x, y, l

    Tedaj ima vsak seznam lasnost P.

    To inačico indukcije najlažje dokažemo tako, da napišemo ustrezno
    rekurzivno funkcijo, ki je po Curry-Howardu njen dokaz.
*)
Fixpoint list_ind_2
         {A : Set}
         (P : list A -> Prop)
         (p0 : P nil)
         (p1 : forall x, P (x :: nil))
         (p2 : forall a b k, P k -> P (a :: b :: k))
         (l : list A) :=
  match l with
    | nil => p0
    | x :: nil => p1 x
    | x :: y :: l' => p2 x y l' (list_ind_2 P p0 p1 p2 l')
  end.

Lemma dolzina A (x : A) (l : list A) :
  S(length l) = length (x :: l).
Proof.
  firstorder.
Qed.

(** Osnovne lastnosti razpolavljanja. *)

Lemma razpolovi_length (l : list Z) :
  match razpolovi l with
    | (l1, l2) => length l = (length l1 + length l2)%nat
  end.
Proof.
  apply (list_ind_2 (fun l =>
                      let (l1, l2) := razpolovi l in
                        length l = length l1 + length l2))%nat ;
    simpl ; auto.
  intros x y l' H.
  replace (razpolovi l') with (fst (razpolovi l'), snd (razpolovi l')) in * |- * ;
    [ idtac | symmetry ; apply surjective_pairing ].
  simpl.
  SearchAbout (?x + S ?y).
  rewrite <- plus_n_Sm.
  now repeat f_equal.
Qed.

(** Nekateri algoritmi za urejanje razdelijo seznam na podseznama
    glede na dani kriterij [p]. *)
Fixpoint razdeli (p : Z -> bool) (l : list Z) :=
  match l with
    | nil => (nil, nil)
    | x :: l' =>
      let (l1, l2) := razdeli p l' in
        if p x then (x :: l1, l2) else (l1, x :: l2)
  end.

(** Na primer, takole razdelimo dani seznam glede na to,
    ali so elementi večji od 5. *)
 
Lemma razdeli_length (p : Z -> bool) (l : list Z) :
  let (l1, l2) := razdeli p l in
    length l = (length l1 + length l2)%nat.
Proof.
  induction l.
  - simpl ; auto.
  - simpl.
    replace (razdeli p l) with (fst (razdeli p l), snd (razdeli p l)) in * |- * ;
      [ idtac | symmetry ; apply surjective_pairing ].
    destruct (p a) ; simpl.
    + now f_equal.
    + rewrite <- plus_n_Sm.
      now f_equal.
Qed.

(** Nekateri algoritmi izračunajo minimalni element seznama. 
    Ker minimalni element praznega seznama ne obstaja, vedno
    računamo minimalni element sestavljenega seznama [x :: l].
*)
Fixpoint najmanjsi (x : Z) (l : list Z) : Z :=
  match l with
    | nil => x
    | y :: l' =>
      match Z.leb x y with
        | true => najmanjsi x l'
        | false => najmanjsi y l'
      end
  end.

(** Tako povemo, da želimo pripadajoči program v OCamlu. *)

(** Osnovne leme o najmanjsih elementih. *)

Lemma najmanjsi_inv (x : Z) (l : list Z) :
  x = najmanjsi x l \/ In (najmanjsi x l) l.
Proof.
  generalize x.
  induction l ; auto.
  intro y.
  simpl; destruct (Z.leb y a).
  - destruct (IHl y) ; auto.
  - destruct (IHl a) ; auto.
Qed. 

Lemma najmanjsi_inv1 (x y : Z) (l : list Z) :
  x = najmanjsi y l -> x = y \/ In x l.
Proof.
  generalize y.
  induction l.
  firstorder.
  intros.
  simpl in H.
  case_eq (Z.leb y0 a);
  intro H0;
  rewrite H0 in H.
   - apply IHl in H.
     destruct H as [H|H].
      + now left.
      + simpl.
        right.
        now right.
   - apply IHl in H.
     destruct H as [H|H].
      + simpl.
        right.
        now left.
      + simpl.
        right.
        now right.
Qed.

Lemma najmanjsi_In (x : Z) (l : list Z) : 
  In (najmanjsi x l) (x :: l).
Proof.
  destruct (najmanjsi_inv x l).
  - rewrite <- H ; simpl ; auto.
  - simpl ; auto.
Qed.

Lemma najmanjsi_head (x : Z) (l : list Z) :
  (najmanjsi x l <= x)%Z.
Proof.
  generalize x.
  induction l.
  - intro ; reflexivity.
  - intro y ; simpl.
    case_eq (Z.leb y a) ; intro E.
    + apply IHl.
    + transitivity a ; [apply IHl | idtac].
      apply Z.leb_gt in E; firstorder.
Qed.


Lemma najmanjsi_tail x y l : In y l -> (najmanjsi x l <= y)%Z.
Proof.
  generalize x y ; clear x y.
  induction l ; [intros ? ? H ; destruct H | idtac].
  intros x y H.
  apply in_inv in H ; destruct H as [G|G].
   - rewrite G.
     simpl.
     case_eq (Z.leb x y).
      + intro F.
        apply Zle_is_le_bool in F.
        now rewrite najmanjsi_head.
      + intro F.
        now apply najmanjsi_head.
   - simpl.
     case_eq (Z.leb x a).
      + intro F; now apply IHl.
      + intro F.
        apply Z.leb_gt in F.
        now apply (IHl a y).
Qed.

Lemma najmanjsi_spodna_meja (x : Z) (l : list Z) :
  forall y, In y (x :: l) -> najmanjsi x l <= y.
Proof.
  intros y [H|H].
  - rewrite H ; apply najmanjsi_head.
  - now apply najmanjsi_tail.
Qed.

Lemma najmanjsi_en (x : Z) :
  x = najmanjsi x nil.
Proof.
  now simpl.
Qed.

Lemma najmanjsi_neq (x y : Z) (l : list Z) :
  x <> y -> x = najmanjsi y l -> In x l.
Proof.
  generalize y.
  induction l; firstorder.
  simpl.
  simpl in H0.
  case_eq (Z.leb y0 a).
   - intro.
     rewrite H1 in H0.
     right.
     now apply IHl in H.
   - intro.
     rewrite H1 in H0.
     case_eq (Z.eqb a x).
      + intro.
        apply Z.eqb_eq in H2.
        now left.
      + intro. 
        apply Z.eqb_neq in H2.
        apply not_eq_sym in H2.
        right.
        now apply IHl in H2.
Qed.

Lemma najmanjsi_manjsi (x y : Z) (l : list Z) : 
  x = najmanjsi y l -> x = najmanjsi x l.
Proof.
  generalize y.
  induction l.
  intros.
  now simpl.
  intros.
  simpl.
  simpl in H.
  case_eq (Z.leb y0 a);
  case_eq (Z.leb x a);
  intros;
  rewrite H1 in H.
   - now apply IHl in H.
   - apply Z.leb_gt in H0.
     apply Zle_is_le_bool in H1.
     assert (y0 < x); firstorder.
     assert (najmanjsi y0 l <= y0).
     apply najmanjsi_head.
     firstorder.    
   - apply Z.leb_gt in H1.
     apply Zle_is_le_bool in H0.
     assert (x < y0); firstorder.
   - assumption.
Qed.
  
     







