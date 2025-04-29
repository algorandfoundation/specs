$$
\newcommand \BlockProposal {\mathrm{BlockProposal}}
\newcommand \BlockAssembly {\mathrm{BlockAssembly}}
\newcommand \SoftVote {\mathrm{SoftVote}}
\newcommand \CertificationVote {\mathrm{CertificationVote}}
\newcommand \Commitment {\mathrm{Commitment}}
\newcommand \Recovery {\mathrm{Recovery}}
\newcommand \FastRecovery {\mathrm{FastRecovery}}
\newcommand \DeadlineTimeout {\mathrm{DeadlineTimeout}}
\newcommand \Bundle {\mathrm{Bundle}}
\newcommand \HandleProposal {\mathrm{HandleProposal}}
\newcommand \HandleVote {\mathrm{HandleVote}}
\newcommand \HandleBundle {\mathrm{HandleBundle}}
\newcommand \Propose {\mathit{propose}}
\newcommand \Soft {\mathit{soft}}
\newcommand \Cert {\mathit{cert}}
\newcommand \Next {\mathit{next}}
\newcommand \Late {\mathit{late}}
\newcommand \Redo {\mathit{redo}}
\newcommand \Down {\mathit{down}}
\newcommand \function {\textbf{function }}
\newcommand \endfunction {\textbf{end function}}
\newcommand \if {\textbf{if }}
\newcommand \then {\textbf{ then}}
\newcommand \else {\textbf{else}}
\newcommand \elseif {\textbf{else if }}
\newcommand \endif {\textbf{end if}}
\newcommand \ev {\mathit{ev}}
\newcommand \t {\mathit{time}}
\newcommand \s {\mathit{step}}
\newcommand \data {\mathit{msg}_\text\{data}}
\newcommand \TimeoutEvent {\texttt{TimeoutEvent}}
\newcommand \MessageEvent {\texttt{MessageEvent}}
\newcommand \DynamicFilterTimeout {\mathrm{DynamicFilterTimeout}}
\newcommand \comment {\qquad \small \textsf}
$$

# Agreement Stages

The Algorand Agreement Protocol can be split into a series of stages.

In the normative section, these stages are univocally associated with infinite subsets
of protocol states. These subsets are disjoint and together represent the whole
space of possible states for the node state machine to be in.

The stages are, in chronological order within a given round:

- \\( \BlockProposal \\),
- \\( \SoftVote \\),
- \\( \CertificationVote \\), which includes a final \\( \Commitment \\).

If \\( \Commitment \\) is not possible because of external reasons (i.e., a network
partition), two fallback stages:

- \\( \FastRecovery \\),
- \\( \Recovery \\).

By abstracting away some implementation-specific complexity, we propose a model for
the Agreement Protocol state machine that captures how and when transitions between
different states happen.

## Algorithm

We may model the state machine’s main algorithm in the following way:

---

\\( \textbf{Algorithm 2} \text{: Main State Machine} \\)

$$
\begin{aligned}
&\text{1: } \function \mathrm{EventHandler}(ev) \\\\
&\text{2: } \qquad \if \ev \text{ is a } \TimeoutEvent \then \\\\
&\text{3: } \qquad \quad \t \gets \ev_\t \\\\
&\text{4: } \qquad \quad \if \t = 0 \then \comment{# Last round should have left us with s := propose} \\\\
&\text{5: } \qquad \quad \quad \BlockProposal() \\\\
&\text{6: } \qquad \quad \quad \if \text{finished a block} \lor \mathrm{CurrentTime}() = \mathrm{AssemblyDeadline}() \then \\\\
&\text{7: } \qquad \quad \quad \quad \s \gets \Soft \\\\
&\text{8: } \qquad \quad \quad \endif \\\\
&\text{9: } \qquad \quad \elseif time = \DynamicFilterTimeout(p) \then \\\\
&\text{10:} \qquad \quad \quad \SoftVote() \\\\
&\text{11:} \qquad \quad \quad \s \gets \Cert \\\\
&\text{12:} \qquad \quad \elseif \t = \DeadlineTimeout(p) \then \\\\
&\text{13:} \qquad \quad \quad \s \gets \Next_0 \\\\
&\text{14:} \qquad \quad \quad \Recovery() \\\\
&\text{15:} \qquad \quad \elseif \t = \DeadlineTimeout(p) + 2^{s_t - 3}\lambda \text{ for } 4 \le s_t \le 252 \then \\\\
&\text{16:} \qquad \quad \quad \s \gets \Next_{s_t} \\\\
&\text{17:} \qquad \quad \quad \Recovery() \\\\
&\text{18:} \qquad \quad \elseif \t = k\lambda_f + rnd \text{ for } k, rnd \in \mathbb{Z}, k > 0, 0 \le rnd \le \lambda_f \then \\\\
&\text{19:} \qquad \quad \quad \FastRecovery() \\\\
&\text{20:} \qquad \quad \endif \\\\
&\text{21:} \qquad \else \comment{# MessageEvent could trigger a commitment and round advancement} \\\\
&\text{22:} \qquad \quad msg \gets ev_{msg} \\\\
&\text{23:} \qquad \quad \if \data \text{ is of type } \texttt{Proposal } pp \then \\\\
&\text{24:} \qquad \quad \quad \HandleProposal(pp) \\\\
&\text{25:} \qquad \quad \elseif \data \text{ is of type } \texttt{Vote } v \then \\\\
&\text{26:} \qquad \quad \quad \HandleVote(v) \\\\
&\text{27:} \qquad \quad \elseif \data \text{ is of type } \texttt{Bundle } b \then \\\\
&\text{28:} \qquad \quad \quad \HandleBundle(b) \\\\
&\text{29:} \qquad \quad \endif \\\\
&\text{30:} \qquad \endif \\\\
&\text{31: } \endfunction
\end{aligned}
$$

---

The first three steps (\\( \Propose, \Soft, \Cert \\)) are the fundamental parts,
and will be the only steps run in regular “healthy” functioning conditions.

The following steps are _recovery procedures_ if there’s no observable consensus
before their trigger times.

Note that in the case of \\( \Propose \\), if a block is not assembled and finalized
in time for the \\( \BlockAssembly() \\) timeout, this might trigger advancement
to the next step.

> For more information on this process, refer to the Algorand Ledger [non-normative section](./ledger-overview.md#block-assembly).

The \\( \Next_{s-3} \\) with \\( s \in [3, 252] \\) are _recovery_ steps, while
the last three (\\( \Late, \Redo, \Down \\)) are special _fast recovery_ steps.

A _period_ is an execution of a subset of steps, executed in order until one of 
them achieves a _bundle_ for a specific _value_.

A round always starts with a \\( \Propose \\) step and finishes with a \\( \Cert \\)
step (when a block becomes commitable, it is certified and committed to the Ledger).

However, multiple periods might be executed inside a round until:

- A _certification bundle_ (\\( \Bundle(r,p,s,v) \\) where \\( s = \Cert \\)) is
observable by the network, and

- The corresponding _proposal_ \\( Proposal(v) \\) has been received and validated,
and

- The _proposal payload_ is available at the moment of commitment.

## Events

Events are _the only way_ for the node state machine to transition internally and
produce output.

{{#include ./.include/styless.md:impl}}
> Events [reference implementation](https://github.com/algorand/go-algorand/blob/c60db8dbc4b0dd164f0bb764e1464d4ebef38bb4/agreement/events.go#L76).

If an event is not identified as _misconstrued_ or _malicious_, it will produce
a state change. Also, it will almost certainly cause a receiving node to
produce and then broadcast or relay an output, consumed by its peers in the network.

There are two main kinds of events:

- \\( \TimeoutEvent \\), which are produced once the _internal clock_ of a node
reaches a specific time since the start of the _current period_;

- \\( \MessageEvent \\), which are outputs produced by nodes in response to some
stimulus (including the receiving node itself).

Internally, we consider the structure of an event to be composed of:

- A floating point number, representing time (in seconds) from the start of the
_current period_, in which the event has been triggered;

- An _event type_, from an enumeration;

- A _data type_;

- Some _attached data_, plain bytes to be cast and interpreted according to the attached
data type, or empty in case of a timeout event.

### Time Events

\\( \TimeoutEvent \\) are triggered when a specific time has elapsed after the start
of a new period.

- \\( \Soft \\) timeout (a.k.a. Filtering): is run after a timeout of \\( \DynamicFilterTimeout(p) \\)
is observed (where \\( p \\) is the currently running period). Note that it only
depends on the period, whether it’s the first period in the round or a later one.
In response to this, the node state machine will perform a filtering action, finding
the highest priority proposal observed to produce a _soft vote_ (as detailed in
the \\( \SoftVote \\) algorithm).

- \\( \Next_0 \\) timeout: it triggers the first recovery step, only executed if
no consensus for a specific value was observed, and no \\( \Cert \\) bundle is
constructible with observed votes. It plays after observing a timeout of \\( \DeadlineTimeout(p) \\).
In this step, the node will _next vote_ a value and attempt to reach a consensus
for a \\( \Next_0 \\) bundle, that would kickstart a new period.

- \\( \Next_s \\) timeout: this family of timeouts runs whenever the elapsed time
since the start of the _current period_ reaches \\( \DeadlineTimeout(p) + 2^{s_t-3}\lambda \\)
for some \\( 4 \le s_t \le 252 \\). The algorithm run is the same as in the \\( \Next_0 \\)
step.

{{#include ./.include/styless.md:impl}}
> Next vote ranges [to reference implementation](https://github.com/algorand/go-algorand/blob/55011f93fddb181c643f8e3f3d3391b62832e7cd/agreement/types.go#L103C15-L103C29).

- (\\( \Late, \Redo, \Down \\)) fast recovery timeouts: on observing a timeout of
\\( k\lambda_f + rnd \\) with \\( rnd \\) a uniform random sample in \\( [0, \lambda_f] \\)
and \\( k \\) a positive integer, the fast recovery algorithm is executed. It works
very similarly to \\( \Next_k \\) timeouts, with some subtle differences (besides
trigger time).

> For a detailed description, refer to its [subsection](#late-redo-and-down-votes).

### Message Events

\\( \MessageEvent \\) are events triggered after observing a specific message carrying
data.

In **Algorithm 2**, we focused on three kinds of messages:

- \\( \texttt{Proposal} \\),
- \\( \texttt{Vote} \\),
- \\( \texttt{Bundle} \\),

Each carries the corresponding construct (coinciding with their attached data type
field).