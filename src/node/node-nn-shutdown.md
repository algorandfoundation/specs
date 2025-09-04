# Shutdown

Node shutdown refers to the graceful termination of an `algod` node.

During this process, the node ensures that all active services are properly stopped.
For example, if a [synchronization](./node-nn-sync.md) operation is currently in
progress, it is cleanly terminated to avoid leaving the node in an inconsistent
state.

Because `algod` nodes operate in a multithreaded environment, shutting down the
node requires acquiring a full lock on the node instance. This locking ensures that
no other threads can access or modify shared state during shutdown, preventing data
corruption both within the shutdown routine and across the broader system.
