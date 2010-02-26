Require Import
  Technology.FirstClassSetoid.

Inductive Tag : Set := Additive | Multiplicative.

Class Magma (tag : Tag) (S : Setoid) := {
  operation : S -> S -> S ;
  operationRespectful : Proper (eq S ==> eq S ==> eq S) operation
}.

Infix "&" := operation (at level 50, no associativity).
Infix "(+)" := (@operation Additive _ _) (at level 50, no associativity).
Infix "(x)" := (@operation Multiplicative _ _) (at level 40, no associativity).

Add Parametric Morphism (tag : Tag) (S : Setoid) `(m : Magma tag S) : operation with 
signature eq S ==> eq S ==> eq S as operation_mor.
Proof. apply operationRespectful. Qed.

(** tests **

Lemma magma_morph_test `{m : Magma} : forall x y a,
  x == y -> a&x == a&y.
intros tag M m x y a Q.
rewrite Q; reflexivity.
Qed.

Lemma magma_ops_test (S : Setoid) `(A : Magma Additive S) (B : Magma Multiplicative S) :
  forall a b c,
    a (+) b (x) c ==
    @operation Additive _ _ a (@operation Multiplicative _ _ b c).
reflexivity.
Qed.

** **)