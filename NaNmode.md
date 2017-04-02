Appendix X: NaN mode
====================

Due to overwhelming demand, we describe an optional **NaN mode** which some
implementers may choose to include.  Using **NaN mode** comes with risks and
abandons programming saftey and the comfort of mathematical rigor.  Only
numerical wizards who are comfortable with flying fast and loose with safety,
and losing precious computational time from NaN values spilling out of their
memory buckets should consider using this mode.

1.  **NaN mode** is *strictly optional* - not including it does not disqualify a
posit implementation from being 'complete'.
2.  **NaN mode** *must* conform to the following specifications:
  - **NaN mode** *must not* be the default operational mode.  We suggest using a
    hardware CSR switch that activates **NaN mode**, but other choices may be
    desirable
  - the NaN value is 0b10000....  It supplants the +/- Inf value.  If you
    must have both undefined and infinite values, we suggest boxing the posit
    type with `Nullable` or `None` or `Null` values, or using *Valids*, which
    implement NaN as the null set.
  - the results of attempting to calculate with NaN are shown below.  For
    reference, we show the corresponding operation with Inf, which should give
    hardware designers a hint as to how one might implement **NaN mode**.  
    Note NaN! means signal and halt execution.

      | Posit operation   | Posit **NaN mode** operation |
      |-------------------|------------------------------|
      | Inf + X => Inf    | NaN + X => NaN               |
      | Inf + Inf => NaN! | NaN + NaN => NaN             |
      | Inf * X => Inf    | NaN * X => NaN               |
      | Inf * 0 => NaN!   | NaN * 0 => NaN               |
      | Inf * Inf => Inf  | NaN * NaN => NaN             |
      | Inf / X => Inf    | NaN / X => NaN               |
      | Inf / Inf => NaN! | NaN / NaN => NaN             |
      | X / Inf => 0      | **X / NaN => NaN**           |
      | sqrt(Inf) => Inf  | sqrt(NaN) => NaN             |
      | log(Inf) => Inf   | log(NaN) => NaN              |
      | exp(Inf) => Inf   | exp(NaN) => NaN              |

  - the results of applying a NaN value to the required fused operations are
    also defined:

      | Fused operation     | Posit **NaN mode** result, when passed an NaN value |
      |---------------------|-----------------------------------------------------|
      | fused multiply-add  | outputs NaN always                                  |
      | fused add-multiply  | outputs NaN always                                  |
      | fused cross product | outputs NaN always                                  |
      | exact summation     | ignore the NaN value and sum around it              |
      | exact dot product   | ignore the NaN product pair and sum around it       |

  - the following table lists the result of comparison to NaN, again with the
    corresponding Posit operation shown.  Any implementation of **NaN mode**
    *must* include an === operation that is distinct from the == operation.  For
    software implementations, this need not *strictly* be an operator (it may be
    a standalone function), but if implementing it as an operator is *possible*
    in the language, then it *must* implement it to be consistent with the
    expected language constructs.

      | Posit operation     | Posit **NaN mode** operation |
      |-------------------- |------------------------------|
      | Inf < X => True     | NaN < X => False             |
      | Inf > X => True     | NaN > X => False             |
      | Inf < Inf => True   | NaN < NaN => False           |
      | Inf <= Inf => True  | NaN <= NaN => False          |
      | Inf == Inf => True  | NaN == NaN => False          |
      | Inf === Inf => True | **NaN === NaN => True**      |
