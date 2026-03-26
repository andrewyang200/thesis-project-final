# Advisor Feedback on Fall Report

> **Instructions**: Mark items as they are addressed: ✅ Done, 🔄 In Progress, ❌ Not Started. 
> Claude: When reviewing any chapter, explicitly check this list and update statuses if you fix them.

## Critical Structural Changes
- [ ] ❌ **Clarify Objective:** Explicitly state in the Introduction and Methodology that the core objective is causal inference (understanding what makes cases settle or dismiss), not machine learning prediction.
- [ ] ❌ **Restructure Results:** Organize subsections by *substantive claims* (e.g., "Claim 1: Post-PSLRA cases are X% more likely to settle"), NOT by statistical model. Weave the statistical evidence (Cox, Frailty, IPTW) underneath each claim.
- [ ] ❌ **Shorten & Focus the Text:** Condense the long, textbook-style descriptions of the models in the results chapter. The thesis is currently too long and easy to get lost in.

## Self-Containment & Accessibility
- [ ] ❌ **The "Judge/Professor" Test:** Ensure the text builds logically without jumping around. A smart non-expert (like a judge) or a math expert without legal context (an ORFE professor) should be able to follow the core objective without getting lost.
- [ ] ❌ **Define "Hazard Ratio":** Provide a clear, intuitive, plain-English definition of a hazard ratio in the text before interpreting the first set of results.
- [ ] ❌ **Define $\hat{\text{risk}}$:** Explicitly define "risk hat" in or around Equation (3.13).

## Formatting Fixes
- [ ] ❌ **Figure Readability:** Fix resizing issues on figures (specifically Figure 5.1). Ensure all text, axes, and legends in figures are legible when printed at standard page size.

---
**Original Advisor Text (For Reference):**
The thesis should be self contained that is when given to a lawyer, a professor in orfe, or a judge, etc. They should not be completely lost and don't know what is going on. That is not to say that you should explain everything down to its most basic form but to a degree where if a judge say wants to learn more about the fine gray model, they can google themselves to read about it but it should assume that the read is just an expert on this topic. Naturally this also means that the thesis should slowly be very logical with its build up and shouldn't jump all over the place (esp with the reader not knowing what the core objective is)

You also never define "hazard ratio" (although you did cite it). Since this is pretty essential to your thesis I would include a definition somewhere.
Did you define risk hat in (3.13) anywhere?
I can't read a log of the text in some of your figures because of resizing, for example Figure 5.1.
This thesis is currently too long. We have a description of survival analysis models, then a very long description of the results for each individual model. I can't really tell if the point is to understand what exactly makes cases settle, or to find the right model for prediction. If we are focusing on the first, it would make more sense for each subsection of 5 to be a claim, eg. "Post-PSLRA cases are x% more likely to settle" and then include statistical evidence for this below. If the point is the second, I should see somewhere a direct comparison between the simple survival models and the more complex models. Currently it is very easy to get lost in all this text.
Other than that the writing seems to be good, and although the statistical inference done is simple, it mostly looks good to me.

## Score: 80/100