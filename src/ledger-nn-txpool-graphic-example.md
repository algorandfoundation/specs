$$
\newcommand \TP {\mathrm{TxPool}}
$$

# Graphic Run Example

This section is a high-level step-by-step graphic example of a \\( \TP \\) “vanilla
run”, which provides an intuition about the typical operations:

1. Receiving transactions from the Network and prioritizing them,
1. Parallel transactions verification,
1. Enqueuing transactions in the \\( \TP \\),
1. Serial transaction (FIFO) queue verification and gossip,
1. Re-verification on a new appended block,
1. Block assembly.

## Step 1: Reception and Prioritization

![TxPool-1](images/tx-pool-1.svg "TxPool Step 1: Reception and Prioritization")

## Step 2: Parallel Verification

![TxPool-2](images/tx-pool-2.svg "TxPool Step 2: Parallel Verification")

## Step 3: Enqueuing

![TxPool-3](images/tx-pool-3.svg "TxPool Step 3: Enqueuing")

## Step 4: Serial Verification and Gossip

![TxPool-4](images/tx-pool-4.svg "TxPool Step 4: Serial Verification and Gossip")

## Step 5: Verification on New Block

![TxPool-5](images/tx-pool-5.svg "TxPool Step 5: Verification on New Block")

## Step 6: Block Assembly

![TxPool-6](images/tx-pool-6.svg "TxPool Step 6: Block Assembly")