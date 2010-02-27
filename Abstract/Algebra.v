Require Import
  Technology.FirstClassSetoid.

Set Automatic Introduction.

Delimit Scope algebra_scope with algebra.
Open Scope algebra_scope.

Inductive Tag : Set := Additive | Multiplicative.

Class Magma (tag : Tag) (S : Setoid) := {
  operation : S -> S -> S ;
  operationRespectful : Proper (eq S ==> eq S ==> eq S) operation
}.

Infix "&" := operation (at level 50, no associativity) : algebra_scope.
Infix "+" := (@operation Additive _ _) : algebra_scope.
Infix "*" := (@operation Multiplicative _ _) : algebra_scope.

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

Class Semigroup `(M : Magma) := {
  associativity : forall a b c,
    a & (b & c) == (a & b) & c
}.

Class Abelian `(M : Magma) := {
  commutativity : forall a b,
    a & b == b & a
}.

Class Monoid `(M : Magma) := {
  identity ;
  leftIdentity : forall x, identity & x == x ;
  rightIdentity : forall x, x & identity == x
}.

Notation "'zero'" := (@identity Additive _ _ _) : algebra_scope.
Notation "'one'" := (@identity Multiplicative _ _ _) : algebra_scope.

(** tests **

Theorem monoid_test (S : Setoid) `(A : Monoid Additive S) `(M : Monoid Multiplicative S) :
  zero (x) one == zero (+) zero.
intros.
rewrite leftIdentity.
rewrite rightIdentity.
reflexivity.
Qed.

** **)

Class Group (tag : Tag) (S : Setoid) `(M : Magma tag S) `(Sem : @Semigroup tag S M) `(Mo : @Monoid tag S M) := {
  invert : S -> S ;
  invertRespectful : Proper (eq S ==> eq S) invert ;
  leftInverse : forall x, invert x & x == identity ;
  rightInverse : forall x, x & invert x == identity
}.

Notation "x '''" := (@invert _ _ _ _ _ _ x) (at level 30, no associativity) : algebra_scope.

Add Parametric Morphism (tag : Tag) (S : Setoid) `(m : Group tag S) : invert with 
signature eq S ==> eq S as invert_mor.
Proof. apply invertRespectful. Qed.

Lemma group_identity_self_inverse `(G : Group) :
  identity ' == identity.
Proof.
  assert (identity ' & identity == identity) as Q by (rewrite leftInverse; reflexivity).
  rewrite rightIdentity in Q.
  assumption.
Qed.

Lemma group_unique_identity_left `(G : Group) : forall x y,
  x & y == y -> x == identity.
Proof.
  intros x y Q. 
  assert ((x & y) & y ' == y & y ') as Q' by (rewrite Q; reflexivity).
  rewrite <- associativity in Q'.
  repeat rewrite rightInverse in Q'.
  rewrite rightIdentity in Q'.
  assumption.
Qed.

Lemma group_unique_identity_right `(G : Group) : forall x y,
  y & x == y -> x == identity.
Proof.
  intros x y Q. 
  assert (y ' & (y & x) == y ' & y) as Q' by (rewrite Q; reflexivity).
  rewrite associativity in Q'.
  repeat rewrite leftInverse in Q'.
  rewrite leftIdentity in Q'.
  assumption.
Qed.

Lemma group_unique_inverses `(G : Group) : forall x y,
  x & y == identity -> x == y ' /\ y == x '.
Proof.
  intros x y Q.
  assert ((x & y) & y ' == identity & y ') as Qa by (rewrite Q; reflexivity).
  assert (x ' & (x & y) == x ' & identity) as Qb by (rewrite Q; reflexivity).
  rewrite <- associativity in Qa.
  rewrite associativity in Qb.
  rewrite rightInverse in Qa.
  rewrite leftInverse in Qb.
  rewrite leftIdentity in Qa.
  rewrite rightIdentity in Qa.
  rewrite rightIdentity in Qb.
  rewrite leftIdentity in Qb.
  split; assumption.
Qed.

Lemma group_left_cancellation `(G : Group) : forall k x y,
  k & x == k & y -> x == y.
Proof.
  intros k x y Q.
  assert (k ' & (k & x) == k ' & (k & y)) as Q' by (rewrite Q; reflexivity).
  repeat rewrite associativity in Q'.
  repeat rewrite leftInverse in Q'.
  repeat rewrite leftIdentity in Q'.
  assumption.
Qed.

Lemma group_right_cancellation `(G : Group) : forall k x y,
  x & k == y & k -> x == y.
Proof.
  intros k x y Q.
  assert ((x & k) & k ' == (y & k) & k ') as Q' by (rewrite Q; reflexivity).
  repeat rewrite <- associativity in Q'.
  repeat rewrite rightInverse in Q'.
  repeat rewrite rightIdentity in Q'.
  assumption.
Qed.

Theorem group_inverse_over_product `(G : Group) : forall x y,
  (x & y) ' == y ' & x '.
Proof.
  intros x y.
  assert ((x & y) & (y ' & x ') == identity) as Q.
  assert ((x & y) & (y ' & x ') == x & (y & y ') & x ') as Q by (repeat rewrite associativity; reflexivity).
  rewrite Q.
  rewrite rightInverse.
  rewrite rightIdentity.
  rewrite rightInverse.
  reflexivity.
  destruct (group_unique_inverses _ _ _ Q).
  symmetry; assumption.
Qed.

Theorem group_inverse_inverse `(G : Group) : forall a,
  a ' ' == a.
Proof.
  intro.
  assert (a ' & a == identity) as Q by apply leftInverse.
  destruct (group_unique_inverses _ _ _ Q).
  symmetry; assumption.
Qed.

(** tests

Theorem group_test `(G : Group) :
  forall x,
    x & x ' == identity.
intros.
rewrite rightInverse.
reflexivity.
Qed.

**)

Class Ring (S : Setoid) `(Add : Magma Additive S) `(Mul : Magma Multiplicative S)
  (AddSem : @Semigroup _ _ Add) (MulSem : @Semigroup _ _ Mul)
  (AddMon : @Monoid _ _ Add) (MulMon : @Monoid _ _ Mul)
  (AddGrp : @Group _ _ Add AddSem AddMon) := {
  leftDistributivity : forall k a b,
    k * (a + b) == k * a + k * b ;
  rightDistributivity : forall k a b,
    (a + b) * k == a * k + b * k
}.

Lemma ring_zero_absorbs_right `(R : Ring) : forall x,
  x * zero == zero.
Proof. (* x*0=x*0+((x*0)+-(x*0))=x*(0+0)*-x*0=x*0+-x*0=0 *)
  intros x.
  assert (x*zero == x*zero + x*zero + (x*zero)') as Q.
  rewrite <- associativity.
  rewrite rightInverse.
  rewrite rightIdentity.
  reflexivity.
  rewrite Q.
  rewrite <- leftDistributivity.
  rewrite leftIdentity.
  rewrite rightInverse.
  reflexivity.
Qed.

Lemma ring_zero_absorbant_right `(R : Ring) :
  forall a, a * zero == zero.
Proof.
  intro a.
  assert (a + zero == a) as Q by (rewrite rightIdentity; reflexivity).
  assert (a * (a + zero) == a * a) as Q' by (rewrite Q; reflexivity).
  rewrite leftDistributivity in Q'.
  exact (group_unique_identity_right _ _ _ Q').
Qed.

Theorem ring_negate_bubble_right `(R : Ring) : forall a b,
  a * b ' == (a * b) '.
Proof. (* 0 = a(0) = a(b+(-b)) = ab + a(-b) ==> ab = -a(-b) ==> -ab = --a(-b) = a(-b) *)
  intros.
  assert (zero == a * b + a * b ') as Q.
  rewrite <- leftDistributivity.
  rewrite rightInverse.
  rewrite ring_zero_absorbs_right.
  reflexivity.
  assumption. (** This goal is bad news! **)
  assert ((a*b)'+zero == (a*b)'+a*b+a*b ') as Q'.
  rewrite Q.
  rewrite associativity.
  reflexivity.
  rewrite leftInverse in Q'.
  rewrite leftIdentity in Q'.
  rewrite rightIdentity in Q'.
  symmetry; assumption.
Qed.

Class Integral `(R : Ring) := {
  nonDegernerate : one # zero ;
  noZeroDivisors : forall a b,
    a * b == zero -> a == zero \/ b == zero
}.

Theorem integral_left_cancellation `(I : Integral) : forall k a b,
  k # zero -> k * a == k * b -> a == b.
Proof.
  intros k a b.
  intros kNonzero Q.
  assert (k * a + (k * b) ' == zero) as Q'.
  rewrite Q.
  rewrite rightInverse.
  reflexivity.
  rewrite <- ring_negate_bubble_right in Q'; try assumption. (** not good!! **)
  rewrite <- leftDistributivity in Q'.
  destruct (noZeroDivisors _ _ Q') as [|N].
  pose (nonequal _ _ _ kNonzero).
  contradiction.
  destruct (group_unique_inverses _ _ _ N) as [N' N''].
  rewrite group_inverse_inverse in N'.
  assumption.
Qed.
