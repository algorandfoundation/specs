$$
\newcommand \UnauthenticatedVote {\mathrm{UnauthenticatedVote}}
\newcommand \UnauthenticatedCredential {\mathrm{UnauthenticatedCredential}}
\newcommand \Sender {\mathrm{Sender}}
\newcommand \Round {\mathrm{Round}}
\newcommand \Period {\mathrm{Period}}
\newcommand \Step {\mathrm{Step}}
\newcommand \Proposal {\mathrm{Proposal}}
\newcommand \VrfOut {\mathrm{VrfOut}}
\newcommand \Credential {\mathrm{Credential}}
\newcommand \Cred {\mathrm{Cred}}
\newcommand \Weight {\mathrm{Weight}}
\newcommand \DomainSeparationEnabled {\mathrm{DomainSeparationEnabled}}
\newcommand \Hashable {\mathrm{Hashable}}
\newcommand \Vote {\mathrm{Vote}}
\newcommand \Sig {\mathrm{Signature}}
$$

# VRF Selection Keys

To check the validity of a voting message, its _VRF Selection key_
needs to be verified. Algorand uses _Verifiable Random Function_ (VRF) to
generate selection keys.

<!-- TODO: VRF normative: For further details on the VRF, refer to the Cryptography
primitives [specification](). -->

More specifically, an unverified vote (\\( \UnauthenticatedVote \\)) has the
following fields:

- _Raw Vote_ (\\( \mathrm{R} \\)), an inner struct contains \\( \Sender \\), \\( \Round \\),
\\( \Period \\), \\( \Step \\), and \\( \Proposal \\).

- _Unverified Credential_ (\\( \Cred \\)) contains a single field \\( \mathrm{Proof} \\),
which is a VRF proof.

- _Signature_ (\\( \Sig \\)), one-time signature of the vote.

{{#include ../_include/styles.md:impl}}
> Unauthenticated vote [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/vote.go#L42).

Once receiving an unverified vote (\\( \UnauthenticatedVote \\)) from the network,
an Algorand node verifies its VRF selection key by checking the validity
of the VRF Proof (in \\( \Cred \\)), the committee membership parameters that
it is conditioned on, and the voter’s voting stake.

If verified, the result of this verification is
wrapped in a \\( \Credential \\) struct, containing the following fields:

- _Unverifed Credential_ (\\( \UnauthenticatedCredential \\)), the unverified
selection key from the VRF proof.

- _Weight_ (\\( \Weight \\)), the weight of the vote.

- _VRF Output_ (\\( \VrfOut \\)), the cached output of VRF verification.

- _Domain Separation Enabled_ (\\( \DomainSeparationEnabled \\), domain separation
flag, now must be true by the protocol.

- _Hashable_ (\\( \Hashable \\)), the original credential.

And this verified credential is wrapped in a \\( \Vote \\) struct with _Raw Vote_
(\\( \mathrm{R} \\)), _Verified Credential_ (\\( \Credential \\)), and _Signature_
(\\( \Sig \\)).

{{#include ../_include/styles.md:impl}}
> Vote struct [reference implementation](https://github.com/algorand/go-algorand/blob/b6e5bcadf0ad3861d4805c51cbf3f695c38a93b7/agreement/vote.go#L50).
