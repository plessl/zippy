Extending the archtitecture with support for virtualization using
temporal partitioning.
====================================================================

For efficient execution circuits that have been virtualized using
temporal partitioning the architecture needs to support automated
switching between the contexts.

The sequencing of the contexts is very simple in the case of temporal
partitioning. Given that the circuit is paritioned into P partitions,
the partitions are cyclically executed in the order, 0,1,2, .. P-1,
0,1,2, .. P-1, and so on.

For temporal partitioning we need to pay more attention to "clock
cycles". For virtualized execution, each clock cycle of the
non-virtualized circuit translates into P clock-cycles of the
virtualized circuit. To distinguish both types of clock cycles, we
denote the clock-cycles seen by the non-virtualized circuit as user
clock-cycles, and the clock-cycles ran by the virtualized circuit as
system clock-cycles.


Problem with current version of Zippy architecture
=====================================================================

It seems, that the context sequencer code was added rather in an
ad-hoc manner without extendability in mind.

The zunit code is too messy, since all context sequencer related
components are instantiated and wired at the top-level, rather than
encapsulating it nicely in a context sequencer component.



Solution: Alternative A:
======================================================================

Step 1:

First step in cleaning up the code: Move all context sequencer related
code into a new context-sequencer entity.


Step 2:

Add support for efficient execution of temporal-paritioned circuits,
such that the old functionality is preserved


Step 3:

Simplify the code. If difficult, throw away the old context sequencer
code, it is not needed for my thesis, and can be written more cleanly
later on if required.


Solution: Alternative B:
======================================================================

Step 1:

Remove all context sequencer code

Step 2:

Add virtualization support

Step 3:

Add context sequencer code at some later stage



Solution: Alternative C:
======================================================================

Step 1:

Add Quick-and-dirty solution to the problem first.

Step 2:

Cleanup code immediately after step 1



