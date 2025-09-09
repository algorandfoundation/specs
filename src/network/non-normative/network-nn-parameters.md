# Parameters

The following tables present the parametrization of the `go-algorand` network messages
timing and sizing.

## Performance Monitoring

| NAME                                                                                                                                                  | VALUE (seconds) | DESCRIPTION            |
|-------------------------------------------------------------------------------------------------------------------------------------------------------|:---------------:|------------------------|
| [`pmPresyncTime`](https://github.com/algorand/go-algorand/blob/b7b3e5e3c9a83cbd6bd038f4f1856039d941b958/network/connPerfMon.go#L40)                   |   \\( 10 \\)    | Performance monitoring |
| [`pmSyncIdleTime`](https://github.com/algorand/go-algorand/blob/b7b3e5e3c9a83cbd6bd038f4f1856039d941b958/network/connPerfMon.go#L41)                  |    \\( 2 \\)    | Performance monitoring |
| [`pmSyncMaxTime`](https://github.com/algorand/go-algorand/blob/b7b3e5e3c9a83cbd6bd038f4f1856039d941b958/network/connPerfMon.go#L42)                   |   \\( 25 \\)    | Performance monitoring |
| [`pmAccumulationTime`](https://github.com/algorand/go-algorand/blob/b7b3e5e3c9a83cbd6bd038f4f1856039d941b958/network/connPerfMon.go#L43)              |   \\( 60 \\)    | Performance monitoring |
| [`pmAccumulationTimeRange`](https://github.com/algorand/go-algorand/blob/b7b3e5e3c9a83cbd6bd038f4f1856039d941b958/network/connPerfMon.go#L44)         |   \\( 30 \\)    | Performance monitoring |
| [`pmAccumulationIdlingTime`](https://github.com/algorand/go-algorand/blob/b7b3e5e3c9a83cbd6bd038f4f1856039d941b958/network/connPerfMon.go#L45)        |    \\( 2 \\)    | Performance monitoring |
| [`pmMaxMessageWaitTime`](https://github.com/algorand/go-algorand/blob/b7b3e5e3c9a83cbd6bd038f4f1856039d941b958/network/connPerfMon.go#L46)            |   \\( 15 \\)    | Performance monitoring |
| [`pmUndeliveredMessagePenaltyTime`](https://github.com/algorand/go-algorand/blob/b7b3e5e3c9a83cbd6bd038f4f1856039d941b958/network/connPerfMon.go#L47) |    \\( 5 \\)    | Performance monitoring |
| [`pmDesiredMessegeDelayThreshold`](https://github.com/algorand/go-algorand/blob/b7b3e5e3c9a83cbd6bd038f4f1856039d941b958/network/connPerfMon.go#L48)  |  \\( 0.05 \\)   | Performance monitoring |
| [`pmMessageBucketDuration`](https://github.com/algorand/go-algorand/blob/b7b3e5e3c9a83cbd6bd038f4f1856039d941b958/network/connPerfMon.go#L49)         |    \\( 1 \\)    | Performance monitoring |

## Message Sizes

| NAME                                                                                                                                          |           VALUE (Bytes)           | DESCRIPTION                                      |
|-----------------------------------------------------------------------------------------------------------------------------------------------|:---------------------------------:|--------------------------------------------------|
| [`AgreementVoteTagMaxSize`](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/protocol/tags.go#L54)       |           \\( 1228 \\)            | Maximum size of an `AgreementVoteTag` message    |
| [`MsgOfInterestTagMaxSize`](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/protocol/tags.go#L57)       |            \\( 45 \\)             | Maximum size of a `MsgOfInterestTag` message     |
| [`MsgDigestSkipTagMaxSize`](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/protocol/tags.go#L60)       |            \\( 69 \\)             | Maximum size of a `MsgDigestSkipTag` message     |
| [`NetPrioResponseTagMaxSize`](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/protocol/tags.go#L63)     |            \\( 850 \\)            | Maximum size of a `NetPrioResponseTag` message   |
| [`NetIDVerificationTagMaxSize`](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/protocol/tags.go#L66)   |            \\( 215 \\)            | Maximum size of a `NetIDVerificationTag` message |
| [`ProposalPayloadTagMaxSize`](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/protocol/tags.go#L70)[^1] |       \\( 5{,}250{,}313 \\)       | Maximum size of a `ProposalPayloadTag` message   |
| [`StateProofSigTagMaxSize`](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/protocol/tags.go#L73)       |           \\( 6378 \\)            | Maximum size of a `StateProofSigTag` message     |
| [`TopicMsgRespTagMaxSize`](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/protocol/tags.go#L79)        | \\( 6 \times 1024 \times 1024 \\) | Maximum size of a `TopicMsgRespTag` message      |
| [`TxnTagMaxSize`](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/protocol/tags.go#L97)                 |       \\( 5{,}000{,}000 \\)       | Maximum size of a `TxnTag` message               |
| [`UniEnsBlockReqTagMaxSize`](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/protocol/tags.go#L100)     |            \\( 67 \\)             | Maximum size of a `UniEnsBlockReqTag` message    |
| [`VoteBundleTagMaxSize`](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/protocol/tags.go#L104)         | \\( 6 \times 1024 \times 1024 \\) | Maximum size of a `VoteBundleTag` message        |
| [`MaxMessageLength`](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/network/wsPeer.go#L45)             | \\( 6 \times 1024 \times 1024 \\) | Maximum length of a message                      |
| [`averageMessageLength`](https://github.com/algorand/go-algorand/blob/df0613a04432494d0f437433dd1efd02481db838/network/wsPeer.go#L46)         |       \\( 2 \times 1024 \\)       | Average length of a message (base allocation)    |

---

[^1]: This value is dominated by `MaxTxnBytesPerBlock`, see ledger parameters
[normative section](../../ledger/ledger-parameters.md).
