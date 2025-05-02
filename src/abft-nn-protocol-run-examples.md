$$
\newcommand \Next {\mathit{next}}
\newcommand \Late {\mathit{late}}
\newcommand \Redo {\mathit{redo}}
\newcommand \Down {\mathit{down}}
$$

# Examples of Protocol Runs

The following section presents three examples of valid protocol runs, going from
simple to more complex agreement attempts, by adding partition scenarios that involve
recovery stages.

The run examples are name from "best" to "worst" respectively:

- Vanilla Run: agreement is achieved at the first attempt,
 
- Jalapeño Run: agreement is achieved with a \\( \Next \\) recovery procedure,

- Habanero Run: agreement is achieved with \\( \Late, \Redo, \Down \\) fast recovery
procedure.

Note that besides being the simplest, the _Vanilla Run_ is the most common case as
infrastructure failure is extremely rare. However, the partition scenarios in the
_Jalapeño Run_ and _Habanero Run_ shed light on the recovery mechanisms.