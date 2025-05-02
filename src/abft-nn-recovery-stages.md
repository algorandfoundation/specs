$$
\newcommand \DeadlineTimeout {\mathrm{DeadlineTimeout}}
$$

# Recovery Stages

Whenever the threshold for a certification vote is not achieved in the allowed time
for the _current period_, \\( DeadlineTimeout(p) \\), the protocol enters in _recovery mode_.

The protocol employs a series of recovery routines to provide a quick response once
normal network conditions are reestablished.

In the "best case scenario" the protocol tries to "preserve and carry over" some
information from the failed consensus attempt to speed up the recovery process. 

In the "worst case scenario" the protocol tries to reach an "agreement to disagree",
that is a bundle of votes to start the _next period_ without any previous assumptions,
and goes back to the block assembly and proposal stage.

The following sections present the recovery stages and routines.