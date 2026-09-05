# Balnazzar improvement roadmap

## Objective

Make Balnazzar's 605.6.6 story chain reliable, lore-grounded, readable in CK3's event UI, and safe for the surrounding total conversion. Preserve the existing arc and player identity; do not expand it until the current path is proven end to end.

Narrative localization must remain original, lore-grounded, and reviewed before delivery. Drafting is allowed when explicitly authorized by the project instructions.

## Phase 1 — Remove confirmed technical defects

- [x] Stop evaluating the Alexandros scheme setup while CK3 builds the `.1005` option tooltip.
- [x] Add the personal dreadlord-disguise secret without a relational `target`.
- [x] Replace the invalid modifier asset reference with an existing modifier icon.
- [x] Add the missing `secret_dreadlord_disguise_tooltip_desc` through human-authored localization.
- [ ] Reproduce `.1005` in game and confirm Renault occupies the assassin slot.

Exit gate: `.1005` starts the murder scheme without new Balnazzar errors in `error.log`.

## Phase 2 — Harden progression and DLC compatibility

- [x] Make the Alexandros decision detect only the intended murder scheme, not every murder scheme owned by Balnazzar.
- [x] Add the staged-death decision and single transition event defined in `docs/superpowers/specs/2026-09-04-balnazzar-staged-death-design.md`.
- [x] Transfer Balnazzar's landed realm to `character:42076`, keep Balnazzar alive, and converge on the existing landless Dathrohan path.
- [x] Keep title-loss and vassalization hooks as fallback paths for players who fight instead.
- [x] Draft and review the authorized English localization required by the staged-death decision and event.
- [ ] Test the loss-of-Lordaeron transition with Roads to Power enabled.
- [ ] Test the bookmark with Roads to Power disabled; either provide a supported non-landless path or clearly gate the content.
- [ ] Verify cancellation, failure, Alexandros dying by another violent cause, Renault dying, and Dathrohan dying early.
- [ ] Confirm story cleanup removes global state, flags, modifiers, and temporary secrets on every terminal path.

Exit gate: no supported player state can silently stall the chain.

## Phase 3 — Validate possession and reveal state changes

- [x] Preserve every magical school and perk Balnazzar acquired while respecting Saidan's magic-secrecy rules.
- [x] Skip magic perks already present on the possessed body instead of producing duplicate `add_perk` errors.
- [x] Restrict automatic undead-vassal conversion to revealed Balnazzar while he holds `d_wc_the_risen`.
- [ ] Verify Balnazzar-to-Dathrohan player transfer, titles, court, gold, magic traits, perks, secrets, and story ownership.
- [ ] Verify `.1007` de jure changes and vassal conversions do not damage unrelated realms.
- [x] Review the reveal army: it now spawns 24 men-at-arms stacks across four existing raised-crusader roles, not the obsolete 56-stack composition. The successful 2026-09-05 playtest produced about 3,184 troops, so no extra balance or memory system is warranted yet.
- [x] Verify `.2000` resurrection, independence, title transfer, vassal conversion, Risen army, player transfer, and death ordering. Confirmed by the successful 2026-09-05 playtest and a fresh scoped log with no Balnazzar/Risen error.
- [ ] Load a save before and after each major transition to confirm save compatibility.

Exit gate: possession and revelation survive save/reload and preserve unrelated world state.

## Phase 4 — Human lore and narrative revision

- [x] Correct `thal'kituun` to the canonical meaning “unseen guest(s)”.
- [ ] Resolve the post-Archimonde chronology and the bookmark contradiction about following his commands.
- [ ] Review Detheroc's description so defeat on Azeroth is not confused with permanent destruction.
- [x] Correct Brigitte Abbendis's gender reference.
- [ ] Clarify Dathrohan's identity and rank after possession.
- [ ] Remove writer-only knowledge of Renault's internal thoughts unless Balnazzar has evidence for it.
- [ ] Move numerical and progression mechanics out of narrative prose and into tooltips.
- [x] Preserve the user-approved comic-adjacent passage in `.1001`; do not rewrite it during later editorial passes.
- [ ] Reduce repeated motifs and cadence while preserving Balnazzar's calculating, contemptuous voice.
- [ ] Check the longest descriptions in the real event window and shorten them where the UI requires it.

Exit gate: lore accuracy and narrative-localization reviewers report no blocking issue, and the user approves every changed player-facing line.

## Phase 5 — Localization coverage

- [x] Finish English explicit UI-text coverage for the Balnazzar events, decisions, and vessel interaction. `loc-coverage-check` reports 51, 8, and 1 referenced keys respectively with zero missing.
- [ ] Translate the complete arc, decisions, modifier, secret, and bookmark consistently into supported languages.
- [ ] Preserve UTF-8 BOM, language headers, scripted concepts, formatting codes, and character references.
- [ ] Restart CK3 before judging newly added keys because localization is cached at process launch.

Exit gate: coverage checks and Tiger report no Balnazzar localization gap for the languages declared supported by the project.

## Phase 6 — Final verification

- [x] Run brace and encoding checks on every touched Jomini/localization file.
- [x] Run `loc-coverage-check`, `dead-event-finder`, changed-file Tiger diagnostics, and `branch-preflight`.
- [ ] Play the entire chain from the 605.6.6 bookmark through possession, Alexandros's death, Scarlet takeover, and final reveal.
- [ ] Test one failure/cancellation path and one non-standard violent death for Alexandros.
- [x] Check the fresh 2026-09-05 `error.log` for Balnazzar/Risen identifiers: zero matching findings. Two unrelated findings remain in Horde invasion script and a Drust save and stay outside this roadmap.
- [ ] Confirm memory use remains below the project's 5.5 GB manual test threshold.
- [x] Generate the PR test plan and review the final diff before committing.

Exit gate: static checks pass, the complete in-game path passes, the fresh log is clean for this arc, and no tracked change lies outside Balnazzar's scope.

## Phase 7 — Successive vessels

- [x] Reuse the vanilla murder scheme instead of adding a possession scheme type.
- [x] Store preparation only on the scheme so cancellation leaves no stale character state.
- [x] Restrict the interaction to the human-controlled, still-hidden Balnazzar story owner after the Scarlet Crusade forms.
- [x] Preserve Balnazzar's magic, disguise secret, story ownership, and player control in the new human ruler.
- [x] Kill the abandoned mortal shell only after player control moves.
- [x] Make Dathrohan's reveal seize held Tyr's Hand except Light's Hope plus the host's capital duchy, falling back to another personally held duchy when the capital is already in Tyr's Hand.
- [x] Preserve relevant direct vassal trees instead of confiscating their county titles; explicitly raise them and align existing undead with Balnazzar's faith.
- [x] Transfer the selected counties' holders directly instead of relying on their place in the Scarlet hierarchy, prevent the Scarlet succession handoff from reclaiming them, and leave Light's Hope as an independent Argent enclave.
- [x] Preserve raised characters' cultures and avoid converting unrelated Scarlet Crusade territory.
- [x] Resolve the second duchy from the current host's capital, including after a later body transfer.
- [x] Use the Nathrezim trait icon for the possession interaction.
- [x] Give the breakaway realm the event-only titular title `d_wc_the_risen` and a post-switch founding event.
- [x] Replace the generic Scourge reveal army with raised-crusader troop roles and end the titular state with Balnazzar.
- [ ] Cancel, fail, and succeed with the next-vessel murder scheme in game.
- [ ] After a successful jump, expose the disguise and verify the later-vessel fallback, Risen conversions, restored true body, and that unrelated duchies remain behind.

Exit gate: repeated hidden possession works without stale scheme state, Dathrohan's reveal is centered on Tyr's Hand, and a later host can reveal coherently elsewhere.

## Phase 8 — Rebuild the Scarlet corruption chronology

- [ ] Reorder the core arc to: staged death → Dathrohan possession → collective Scarlet founding → gradual corruption → Renault manipulation → Alexandros's death → Balnazzar's seizure and radicalization → Stratholme → the Risen.
- [ ] Add a focused Scarlet Conclave scene with Alexandros, Dathrohan, Abbendis, Isillien, Fairbanks, and Renault as an observer when useful.
- [ ] Recast `.1007` as Balnazzar's seizure and radicalization of an existing Scarlet Crusade, not its instant creation after Alexandros dies.
- [ ] Review the primary _Ashbringer_ chronology before changing ownership: Renault strikes Alexandros, the Ashbringer is corrupted, and Alexandros retains it after being raised; reserve Darion's acquisition for a later Naxxramas arc.
- [ ] Make the Kel'Thuzad choice mechanically distinct: acceptance buys easier murder or undead aid at the cost of a future debt; refusal keeps independence but makes the route harder.
- [ ] Write Balnazzar and Kel'Thuzad as mutually distrustful partners of convenience, never old allies.

Exit gate: the Scarlet Crusade exists before Alexandros's death, Ashbringer continuity is not compressed, and both pact branches have distinct consequences.

## Phase 9 — Make secrecy and revelation reactive

- [ ] Add one lightweight suspicion value with three thresholds: odd behavior, formal investigation, then exposure or confrontation.
- [ ] Raise suspicion from purges, visible forbidden magic, and repeated body changes; lower it through manipulation, imprisonment, or eliminating informed witnesses.
- [ ] Split revelation by host context: Dathrohan uses Tyr's Hand except Light's Hope; later vessels use only their current personal base.
- [ ] Add `The Light Still Burns` as the immediate reaction to the Risen, making Light's Hope the sacred resistance point and first post-reveal antagonist.
- [ ] Add a focused objective or war to extinguish or corrupt Light's Hope, plus a Scarlet or Argent reaction.
- [ ] Do not add another culture, faith, government, or generic Nathrezim framework unless playtests expose a concrete mechanical need.

Exit gate: hidden play produces readable counter-pressure, exposure changes the campaign, and Light's Hope matters without expanding the system beyond Balnazzar.

## Phase 10 — Narrative consistency pass

- [ ] Label canon and alternate-history beats honestly in design notes and tooltips where needed.
- [ ] Treat staged death, Dathrohan possession, Scarlet corruption, Stratholme exposure, and the later Risen as the canon spine.
- [ ] Treat repeat body-hopping, the Tyr's Hand-wide transformation, the sovereign Risen title, and collective Sargerite conversion as explicit GoA2 player-driven departures.
- [ ] Reduce repeated `mask`, `face`, `lie`, and `throne as scaffolding` imagery; avoid polished triplets and narrator omniscience about Renault.
- [ ] Keep the concrete scene craft already working in `.0110`, `.0111`, and the opening of `.1005`; keep mechanics in tooltips.

Exit gate: the lore reviewer finds no accidental canon claim, the narrative reviewer finds no blocking repetition or omniscience, and the user approves every changed line.

## Immediate in-game test

Use a fresh 605.6.6 Balnazzar game; the existing 2026-09-03 logs predate this change.

- [ ] At peace, confirm `A Death of My Choosing` is visible only while Balnazzar, Varimathras, and Sylvanas are alive.
- [ ] Take it and confirm `.0002` shows Balnazzar, Varimathras, and Sylvanas in Undercity without killing Balnazzar.
- [ ] Confirm Sylvanas receives every landed title and vassal, Balnazzar becomes a landless adventurer, and no duplicate transition fires.
- [ ] Confirm the Dathrohan decision becomes available immediately after the landless transition.
- [ ] Take the Dathrohan decision and confirm control, story ownership, magic, titles, court, and gold transfer correctly.
- [ ] Confirm pre-existing perks on Saidan are skipped and a fresh `error.log` contains no duplicate `add_perk` error.
- [x] Trigger `.2000` as Dathrohan and confirm held Tyr's Hand plus the current capital duchy convert, their selected vassal trees remain under the Risen, Light's Hope becomes an independent Argent enclave, and unrelated Scarlet lands remain unchanged. Confirmed in game on 2026-09-05.
- [ ] As another revealed Nathrezim, gain a living vassal and confirm the Balnazzar/Risen undead cascade does not fire.
- [ ] In a separate save, ignore the decision and lose Lordaeron or accept vassalization; confirm the fallback reaches the same landless state.
- [ ] Repeat once without Roads to Power and record whether the landless transition is supported or must be gated.
- [x] Exit CK3 and triage the fresh `error.log` with Balnazzar/Risen keywords. Zero matching findings on 2026-09-05; unrelated Horde/Drust findings were left untouched.

## Out of scope for this branch

- A new Balnazzar campaign, scheme type, custom interface, or general dreadlord framework.
- Retconning unrelated Warcraft history to fit this story.
- Broad narrative rewrites outside the staged-death transition.
- Broad cleanup of copied vanilla systems exposed only through Tiger's total-conversion baseline.
