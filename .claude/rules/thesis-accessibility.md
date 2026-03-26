# Thesis Accessibility & Self-Containment

## Advisor Directive
The thesis must be self-contained. A lawyer, an ORFE professor, or a judge should be able to read it without being lost. They may not understand every mathematical detail, but they should:
1. Always know what the thesis is trying to answer
2. Always understand WHY each method is being used (even if they can't derive it)
3. Always understand WHAT a result means in plain terms (even if they skip the formula)
4. Never encounter a term, acronym, or concept that hasn't been at least briefly explained

## The Buildup Rule
The thesis must progress logically from accessible to technical:
- Start with the real-world problem (securities litigation takes too long, outcomes are uncertain)
- Frame it as a data question (can we predict resolution timing and type?)
- Introduce tools progressively (each method building on the last)
- Present results in the same order as methods
- End with real-world implications

At NO point should the reader think "wait, what are we trying to do again?"

## Practical Guidelines
- **First mention of any statistical method**: one sentence of plain-English intuition BEFORE the formula
  - Good: "The Cox model relates each case characteristic to its effect on the speed of resolution, holding all other factors constant. Formally, ..."
  - Bad: "We estimate $\lambda(t|X) = \lambda_0(t)\exp(X'\beta)$."
- **First mention of any legal concept**: one sentence of context
  - Good: "The PSLRA, enacted in 1995 to curb frivolous securities lawsuits by imposing stricter pleading requirements, ..."
  - Bad: "The PSLRA indicator captures post-reform effects."
- **Every figure and table**: caption should be interpretable without reading the surrounding text
- **Research question**: restated or echoed at least once in Introduction, once in Methodology, once in Results, and once in Discussion. The reader should never lose the thread.

## The "Drop-In" Test
Pick any page of the thesis at random. A reader who opens to that page should be able to:
1. Tell what chapter they're in (from chapter headers)
2. Understand the main point of the current paragraph
3. Know how it connects to the overall research question
If any page fails this test, it needs a connecting sentence or context reminder.
