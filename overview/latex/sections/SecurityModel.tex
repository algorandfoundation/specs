\documentclass[../main.tex]{subfiles}

\begin{document}

The parameter selection of Algorand blockchain is based on a combination 
of assumptions: (1) majority of online honest stake, (2) security of cryptographic primitives, and (3) upper bound on message latency. 

\paragraph{Honest majority assumption.} 
For every $r$, at least $80\%$ of $StakeOn_{r-322}$ is \emph{honest} in round $r$. 
(Larger committee sizes would be required if we assume a smaller honest majority ratio.)

\paragraph{Cryptographic assumptions.} 
Algorand uses a digital signature scheme for message authentication. It uses a VRF and a hash function, modeled as random oracles in the context of the consensus protocol analysis. 

We allow an adversary to perform up to $2^{128}$ hash operations over the lifetime of the system. This is an extraordinarily large number! With this many hash operations, the adversary can find collisions in SHA-256 function, or to mine $100$ billion years' worth of Bitcoin blocks at today's hash rate.

\paragraph{Security Against dynamic corruption.} 

In the Algorand protocol users change their ephemeral participation keys used for every round. That is, after a user signs her message for round $r$, she deletes the ephemeral key used for signing, and fresh ephemeral keys will be used in future rounds. This allows Algorand to be secure against dynamic corruptions where an adversary may corrupt a user after seeing her propagate a message through the network. (Recall that since users use their VRFs to perform cryptographic self-selection, an adversary does not even know whom to corrupt prior to round $r$).

Moreover, even if in the future an adversary corrupts all committee members for a round $r$, as the users holding the supermajority of stakes were honest in round $r$ and erased their ephemeral keys, no two distinct valid blocks can be produced for the same round. 

\paragraph{Network model.}
Algorand guarantees liveness assuming a maximum propagation delay on messages sent through the network. Explicit conditions are specified in Section~\ref{subsection:TimingParameters}. Algorand guarantees safety (``no forks'') even in the case of network partitions. When a network partition heals, 
liveness recovers in linear time against an adversary capable of dynamic corruptions, and in constant time otherwise.

\end{document}