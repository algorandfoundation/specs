# Commitment

On observing \\(Bundle(r, p, Cert, v)\\) for some value \\(v\\), the player
_commits_ the entry \\(e\\) corresponding to \\(Proposal(v)\\); i.e., the
player appends \\(e\\) to the sequence of entries on its ledger \\(L\\).
(Evidently, this occurs either after a vote is received or after a
bundle is received.)

In other words, if observing a cert-vote causes the player to commit
\\(e\\),

\\[
N(S, L, Vote(I, r, p, Cert, v)) = (S', L || e, \ldots));
\\]

while if observing a bundle causes the player to commit $e$,

\\[
N(S, L, Bundle(r, p, Cert, v)) = (S', L || e, \ldots)).
\\]

> Occasionally, an implementation may not have \\(e\\) at the point \\(e\\) becomes
> committed. In this case, the implementation may wait until it receives \\(e\\)
> somehow (perhaps by requesting peers for \\(e\\)). Alternatively, the implementation
> may continue running the protocol until it receives \\(e\\). However, if the protocol
> chooses to continue running, it may not transmit any vote for which \\(v \neq \bot\\)
> until it has committed \\(e\\).