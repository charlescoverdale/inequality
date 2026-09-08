# CRAN submission comments: inequality 0.2.1

## Reason for this submission

A patch to 0.2.0 fixing one side effect. No returned value changes.

`iq_sample_data()` called `set.seed(42L)` without restoring the previous
state, so a call to it reseeded the user's global random stream. Anyone
who used it to obtain a demonstration data frame had every later random
draw in their session silently reset, which breaks reproducibility for
the surrounding analysis without any indication.

The seed now applies for the duration of the call only, and the user's
`.Random.seed` is restored on exit. The helper touches `globalenv()`
because `.Random.seed` lives there by definition; it preserves the
caller's state rather than adding to it.

Verified: the caller's stream is unchanged across a call, `.Random.seed`
is restored, the generated data is still deterministic and now
independent of the caller's seed, and no stray `.Random.seed` is left
behind when none existed beforehand.

## R CMD check results

0 errors | 0 warnings | 0 notes

Local check: macOS (aarch64), R 4.5.2, `devtools::check(cran = TRUE)`.
The local run emits "checking for future file timestamps: unable to
verify current time", which is the checking machine being unable to
reach worldclockapi.com rather than a package fault.

## Downstream dependencies

None.
