---- MODULE bus_nodes ----
(* Specification that describes node behavior in a bus that implements MBus.

  Reference
  ---------
  Pannuto P., Lee Y., Kuo. Y.-S., Foo Z., Kempke B., Blaauw D., Dutta P.
  "MBus specification", Rev.1.0-alpha
  14 Jun 2015 *)

EXTENDS Naturals, Sequences

CONSTANT N (* The bus is made of N nodes. *)
ASSUME N \in Nat \ {0}
VARIABLES node, signal

(* The set of bus nodes. *)
Node == 1..N
(* The set of states that each bus node can be in.
   These originate from Fig.3, p.6.
   So, this specification models only member nodes.
   Mediator nodes need to be modeled too. *)
NodeState == {
    "receive",
    "control",
    "idle",
    "address match",
    "ignore",
    "arbitrate",
    "send",
    "not connected"}
Signal == {
    "arbitration clk pulse",
    "request",
    "win arbitration",
    "response",
    "match",
    "will not ack"}

(* The system should satisfy this invariant.
   In other words, this is an assertion, NOT an assumption. *)
TypeInvariant ==
    /\ node \in [Node -> NodeState]
    /\ signal \in [Node -> [Signal -> BOOLEAN]]

(* The signals should be refined to be equal to
   the behavior that results from interpreting the bits traveling in
   the bus. *)
Init ==
    /\ node = [u \in Node |-> "idle"]
    /\ signal = [
        u \in Node |->
        [sig \in Signal |-> FALSE]]

(* Tuple of all variables. *)
vars == << node, signal >>

GoTo(u, state) == node' = [node EXCEPT ![u] = state]

Receiving(u) ==
    \/ /\ node[u] = "receive"
       /\ GoTo(u, "control")
       (* Here, the signal "will not ack" is redundant. *)

    \/ /\ node[u] = "control"
       /\ GoTo(u, "idle")


Forwarding(u) ==
    \/ /\ node[u] = "idle"
       /\ \/ /\ signal[u]["arbitration clk pulse"]
             /\ GoTo(u, "address match")
          \/ /\ signal[u]["request"]
             /\ GoTo(u, "arbitrate")
          \/ UNCHANGED node

    \/ /\ node[u] = "address match"
       /\ IF signal[u]["match"] THEN GoTo(u, "receive")
                                ELSE GoTo(u, "ignore")

    \/ /\ node[u] = "ignore"
       /\ GoTo(u, "control")


Transmitting(u) ==
    \/ /\ node[u] = "arbitrate"
       /\ IF signal[u]["response"] THEN
              IF signal[u]["win arbitration"]
                  THEN GoTo(u, "send")
                  ELSE GoTo(u, "address match")
          ELSE GoTo(u, "not connected")

    \/ /\ node[u] = "send"
       /\ GoTo(u, "control")


(* To keep things easier to understand,
   assume that signals of at most one node change in a single step.
   This assumption may need to change. *)
SignalNext ==
    /\ UNCHANGED node
    (* These changes will need to be specified by the lower level. *)
    /\ \E u \in Node:  signal' = [signal
        EXCEPT ![u] = [sig \in Signal |-> TRUE]]
    (* This level of granularity results in too many states. *)
    (*
        \E sig \in Signal:
            signal' = [signal EXCEPT ![u][sig] = TRUE]
    *)


NodeNext ==
    /\ UNCHANGED signal
    /\ \E u \in Node:
        \/ Receiving(u)
        \/ Forwarding(u)
        \/ Transmitting(u)
        (* Is "not connected" a deadend, leading to infinite stuttering ? *)

Next == \/ SignalNext
        \/ NodeNext


(* The possible bus behaviors. *)
MBusSpec ==
    /\ Init
    /\ [][Next]_vars
    /\ []<> << NodeNext >>_vars

(* Liveness properties *)
SomeIdleRecurs ==
    \E u \in Node:
        []<> (node[u] = "idle")

AllIdleRecur ==
    \A u \in Node:
        []<> (node[u] = "idle")

THEOREM MBusSpec => [] TypeInvariant
THEOREM MBusSpec => SomeIdleRecurs
(* Should prove the below, after extra details added. *)
(* THEOREM MBusSpec => AllIdelRecur *)

===================
