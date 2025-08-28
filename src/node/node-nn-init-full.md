{{#include ../_include/tex-macros/pseudocode.md}}

$$
\newcommand \RootDir {\mathrm{rootDir}}
\newcommand \Config {\mathrm{nodeConfig}}
\newcommand \Phonebook {\mathrm{phonebookAddrs}}
\newcommand \Genesis {\mathrm{genesisBlock}}
\newcommand \Node {\mathrm{node}}
\newcommand \FullNode {\mathrm{FullNode}}
\newcommand \Logger {\mathrm{Logger}}
\newcommand \Hash {\mathrm{Hash}}
\newcommand \Network {\mathrm{Network}}
\newcommand \WS {\mathrm{WS}}
\newcommand \PtoP {\mathrm{P2P}}
\newcommand \HYB {\mathrm{HYB}}
\newcommand \Peer {\mathrm{Peer}}
\newcommand \CryptoPool {\mathrm{CryptoPool}}
\newcommand \Registry {\mathrm{Registry}}
\newcommand \Ledger {\mathrm{Ledger}}
\newcommand \Block {\mathrm{Block}}
\newcommand \Agreement {\mathrm{Agreement}}
\newcommand \AccountManager {\mathrm{AccountManager}}
\newcommand \StateProof {\mathrm{StateProof}}
\newcommand \Heartbeat {\mathrm{Heartbeat}}
\newcommand \TP {\mathrm{TxPool}}
\newcommand \Catchup {\mathrm{Catchup}}
\newcommand \Service {\mathrm{Service}}
\newcommand \Create {\mathrm{Create}}
$$

# Initialize Full Node

The `algod` Full Node is responsible for:

- **Validating and propagating** transactions and blocks,

- **Maintaining the blockchain state**, either fully (_Archival_) or partially (_Non Archival_),
as defined in the [Ledger](../ledger/ledger-overview.md),

- **Participating in the consensus protocol**, as outlined in the [ABFT specification](../abft/abft-overview.md).

## Initialization

The pseudocode below outlines the main steps involved when initializing an `algod`
_Full Node_:

---

\\( \textbf{Algorithm 1} \text{: Full Node Initialization} \\)

$$
\begin{aligned}
&\text{1: } \PSfunction \FullNode.\mathrm{Start}(\RootDir, \Config, \Phonebook, \Genesis) \\\\
&\text{2: } \quad \Node \gets {\textbf{new }} \FullNode \\\\
&\text{3: } \quad \Node.\mathrm{log} \gets \Logger(\Config) \\\\
&\text{4: } \quad \Node.\Genesis.\mathrm{ID} \gets \Genesis.\mathrm{ID}() \\\\
&\text{5: } \quad \Node.\Genesis.\mathrm{ID} \gets \Genesis.\Hash() \\\\
&\text{6: } \PScomment{# Network Initialization} \\\\
&\text{7: } \quad \PSif \Config.\mathrm{EnableHybridMode} \PSthen \\\\
&\text{8: } \quad \quad \Node.\Network \gets \Create\HYB\Network(\Phonebook) \\\\
&\text{9: } \quad \PSelseif \Config.\mathrm{EnableP2P} \PSthen \\\\
&\text{10:} \quad \quad \Node.\Network \gets \Create\PtoP\Network(\Phonebook) \\\\
&\text{11:} \quad \PSelse \\\\
&\text{12:} \quad \quad \Node.\Network \gets \Create\WS\Network(\Phonebook) \\\\
&\text{13:} \quad \PSendif \\\\
&\text{14:} \PScomment{# Crypto Resource Pools Initialization} \\\\
&\text{15:} \quad \Node.\CryptoPool \gets \Create\mathrm{ExecutionPool}() \\\\
&\text{16:} \quad \Node.\CryptoPool.\mathrm{lowPriority} \gets \Create\mathrm{BacklogPool()} \\\\
&\text{17:} \quad \Node.\CryptoPool.\mathrm{highPriority} \gets \Create\mathrm{BacklogPool()} \\\\
&\text{18:} \PScomment{# Ledger Initialization} \\\\
&\text{19:} \quad \mathrm{ledgerPaths} \gets \mathrm{ResolvePaths}(\RootDir, \Config) \\\\
&\text{20:} \quad \Node.\Ledger \gets \mathrm{LoadLedger}(\mathrm{ledgerPaths}, \Genesis) \\\\
&\text{21:} \PScomment{# Account Management} \\\\
&\text{22:} \quad \Registry \gets \mathrm{ParticipationRegistry}() \\\\
&\text{23:} \quad \Node.\AccountManager \gets \Create\AccountManager(\Registry) \\\\
&\text{24:} \quad \mathrm{LoadParticipationKeys}(\Node) \\\\
&\text{25:} \PScomment{# Transaction Pool Initialization} \\\\
&\text{26:} \quad \Node.\TP \gets \Create\TP(\Node.\Ledger) \\\\
&\text{27:} \quad \mathrm{RegisterBlockListeners}(\Node.\TP) \\\\
&\text{28:} \PScomment{# Services Initialization} \\\\
&\text{29:} \quad \Node.\Block\Service \gets \Create\Block\Service() \\\\
&\text{30:} \quad \Node.\Ledger\Service \gets \Create\Ledger\Service() \\\\
&\text{31:} \quad \Node.\TP\Service \gets \Create\TP\mathrm{Syncer}() \\\\
&\text{32:} \quad \Node.\Agreement\Service \gets \Create\Agreement\Service() \\\\
&\text{33:} \quad \Node.\Catchup\Service \gets \Create\Catchup\Service() \\\\
&\text{34:} \quad \Node.\StateProof\Service \gets \Create\StateProof\Service() \\\\
&\text{35:} \quad \Node.\Heartbeat\Service \gets \Create\Heartbeat\Service() \\\\
&\text{36:} \quad \PSreturn \Node \\\\
&\text{37: } \PSendfunction
\end{aligned}
$$

---

{{#include ../_include/styles.md:impl}}
> Full Node initialization [reference implementation](https://github.com/algorand/go-algorand/blob/e60d3ddd1d63e60f32bda6935554b34fdb0e1515/node/node.go#L184-L347).

### Network

The _network layer_ is set up depending on the configuration:

- \\( \WS \\) (WebSocket) for the Relay Network setups,

- \\( \PtoP \\) for Peer-to-Peer Network, or

- \\( \HYB \\) for the \\( \PtoP \\)-\\( \WS \\) Hybrid Network, for nodes operating
in a unified network layer.

The network layer manages:

- \\( \Peer \\) discovery using _phonebook addresses_,

- Connection pools, and

- Message routing.

> For further details on the network layer, refer to Algorand Network [non-normative specification](../network/network-overview.md).

### Cryptography Resource Pools

The node initializes worker pools for handling cryptographic tasks with priority
queues:

- \\( \CryptoPool \\) handles general-purpose cryptographic operations,

- \\( \CryptoPool.\mathrm{lowPriority} \\) and \\( \CryptoPool.\mathrm{highPriority} \\)
handle transaction verification, grouped by priority.

> For further details on the transaction validation, see the Ledger [specification](../ledger/ledger-overview.md).

> For further details on the cryptographic primitives and algorithms, see the Crypto [specification](../crypto/crypto-overview.md).

### Ledger

The node loads its local view of the blockchain state from disk (accounts, blocks, protocol data, etc.),
based on the specified genesis configuration.

If the Ledger is empty, it initializes the required structures.

It also validates:

- The genesis configuration, and

- Ledger integrity.

> For further details on the Ledger entities, see the Ledger [specification](../ledger/ledger-overview.md).

### Account Management (Agreement)

The node prepares for consensus participation and registered account tracking by:

- Creating and managing a registry of participation keys,

- Loading any pre-existing participation keys from disk,

- Setting up participation key rotation.

> For further details on the Algorand keys, see the Keys [specification](../keys/keys-overview.md).

> For further details on the key registration transactions, see the Ledger [specification](../ledger/ledger-overview.md).

### Transaction Pool

The node creates the _Transaction Pool_ (\\( \TP \\)), which:

- Accepts and validates new transactions,

- Maintains the queue of uncommitted transactions,

- Manages transaction synchronization across the network,

- Creates Block Listeners reacting to new blocks to prune already committed transactions
and update pending transactions.

> For further details on the Transaction Pool, see the Ledger [non-normative specification](../ledger/ledger-nn-txpool.md).

### Services

Finally, the node launches all essential background services:

<!-- TODO: Fix links once all chapters are finalized -->

- [Catchup](#node-catchup) Service,

- [Agreement](abft.md) Service,

- [Transaction Pool](ledger-overview.md#transaction-pool) Syncer Service,

- [Block](ledger.md#blocks) Service,

- [Ledger](ledger.md) Service,

- [Transaction](ledger.md#transactions) Handler,

- [State Proof](crypto.md#state-proofs) Worker.

- [Heartbeat](ledger.md#heartbeat-transaction) Service.