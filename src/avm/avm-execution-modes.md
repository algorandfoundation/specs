$$
\newcommand \LogicSig {\mathrm{LSig}}
\newcommand \LogicSigMaxSize {\LogicSig_\max}
\newcommand \LogicSigMaxCost {\LogicSig_{c,\max}}
\newcommand \App {\mathrm{App}}
\newcommand \MaxAppTotalProgramLen {\App_{\mathrm{prog},t,\max}}
\newcommand \MaxExtraAppProgramPages {\App_{\mathrm{page},\max}}
\newcommand \MaxAppProgramCost {\App_{c,\max}}
$$

# Execution Modes

Starting from Version 2, the AVM can run programs in two modes:

1. _Logic Signature_ (or _stateless_) mode, used to execute Logic Signatures;

2. _Application_(or _stateful_) mode, used to execute Smart Contracts.

Differences between modes include:

- The maximum allowed program size, defined by the following [Ledger parameters](../ledger/ledger-parameters.md):

  - \\( \LogicSigMaxSize \\)
  - \\( \MaxAppTotalProgramLen \\)
  - \\( \MaxExtraAppProgramPages \\)

- The maximum allowed program cost, defined by the following [Ledger parameters](../ledger/ledger-parameters.md):

  - \\( \LogicSigMaxCost \\)
  - \\( \MaxAppProgramCost \\)

- Opcode availability (refer to the [Opcodes Specifications]() for details).

- Some [Global Fields]() are only available in Application mode.

- Only Applications can observe transaction effects, such as Logs or IDs allocated
to ASAs or new Applications.