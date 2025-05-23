$$
\newcommand \WS {\mathrm{WS}}
\newcommand \PtoP {\mathrm{P2P}}
\newcommand \HYB {\mathrm{HYB}}
$$

# Non-Normative

This is a non-normative description of the Algorand Network Layer, responsible for
handling connections and message transport between nodes.

The purpose of this chapter is to provide a detailed overview of all the necessary
network components and their interactions, aiding the reader’s understanding of the
infrastructure, and providing implementors with a solid foundation to instrument networking.

The information contained in this chapter is derived from the Algorand reference
implementation (`go-algorand`).

There are currently two independent _network layers_ on Algorand:

- **Relay Network** (\\( \WS \\)), based on a websockets mesh,

- **Peer-to-Peer Network** (\\( \PtoP \\)), based on the [`libp2p`](https://libp2p.io/)
networking library.

A third option, called **Hybrid Network** (\\( \HYB \\)), instantiates the constructs
to keep both networking layers running in parallel on the node.

This chapter covers first some general constructs common to \\( \WS \\) and \\( \PtoP \\)
networks, defining the notation. Then it dives deeper into each network, its components,
and interactions.

When sensible, implementation-specific notes are included to hint at possible desirable
patterns or optimizations, although the impact of these may vary according to the
implementation language of choice.