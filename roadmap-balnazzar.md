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
- [x] Resolve the post-Archimonde chronology and the bookmark contradiction about following his commands. The 605 description treats Archimonde as already dead and presents revenge against the Lich King as Balnazzar's possible response to the Legion's defeat, not a documented personal order from Kil'jaeden.
- [x] Review Detheroc's presentation so defeat on Azeroth is not confused with permanent destruction. No player-facing Detheroc description exists in current English localization. A history comment calls his 605 defeat a banishment, although the implemented death reason remains the generic `death_battle`; no unsupported narrative rewrite was added.
- [x] Correct Brigitte Abbendis's gender reference.
- [x] Clarify Dathrohan's identity after possession. `.1002` establishes the stolen identity, while `.1003` shows Balnazzar using Dathrohan's authority without inventing an unsupported canonical rank.
- [x] Remove writer-only knowledge of Renault's internal thoughts unless Balnazzar has evidence for it. `.1005` uses observed behavior and Balnazzar's questions; `.1006` depicts the murder and its visible consequences directly.
- [x] Move numerical and progression mechanics out of narrative prose and into tooltips. Current Balnazzar event prose contains no exposed numerical progression instructions.
- [x] Preserve the user-approved comic-adjacent passage in `.1001`; do not rewrite it during later editorial passes.
- [x] Reduce repeated motifs and cadence while preserving Balnazzar's calculating, contemptuous voice. The repeated possession title and stacked triplets in `.1007`/`.2001` were replaced with concrete scene language; the evolving face/mask motif remains intentional.
- [x] Check the longest descriptions against their event windows. `.1001`, `.1007`, `.2000`, and `.2001` use `big_event_window`; the reviewer found no remaining blocking length issue, and the user-approved `.1001` remains untouched.

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

- [x] Supersede the pre-death founding design with `docs/superpowers/specs/2026-09-05-balnazzar-ashbringer-chronology-design.md`.
- [x] Reorder the core arc to: staged death → Dathrohan possession → final Silver Hand council → Kel'Thuzad pact → Renault manipulation → Alexandros's death and raising → Balnazzar reforms the remnants as the Scarlet Crusade → Stratholme → the Risen.
- [x] Add a focused final Silver Hand council with Alexandros, Dathrohan, Abbendis, Isillien, and Fairbanks when alive, without founding the Scarlet Crusade early.
- [x] Recast `.1007` as Balnazzar's post-mortem reorganization of the surviving Silver Hand into the Scarlet Crusade; keep its separate 56-stack founding army removed instead of confusing it with the 24-stack Risen reveal army.
- [x] Preserve the primary _Ashbringer_ chronology: Renault strikes Alexandros, the Ashbringer is corrupted, and Alexandros retains it after being raised; reserve Darion's acquisition for a later Naxxramas arc.
- [x] Make the Kel'Thuzad choice mechanically distinct: acceptance buys easier murder and Alexandros's resurrection at the cost of a favor hook; refusal keeps independence but makes the route harder and leaves the corrupted blade with Renault.
- [x] Write Balnazzar and Kel'Thuzad as mutually distrustful partners of convenience, never old allies.

Exit gate: Alexandros remains Highlord of the Silver Hand until his death, Balnazzar creates the Scarlet Crusade afterward, Ashbringer continuity is not compressed, and both pact branches have distinct consequences.

Validated in game on 2026-09-06, including `.1006`, Corrupted Ashbringer, and the post-transfer Scarlet founding.

## Phase 9 — Make secrecy and revelation reactive

- [x] Add one lightweight suspicion value with three thresholds: odd behavior, formal investigation, then exposure or confrontation.
- [x] Raise suspicion from purges in living, non-Mord'truari counties; lower it through manipulation, imprisonment, eliminating informed witnesses, or a successful change of body that breaks the trail.
- [ ] Add suspicion from visible forbidden magic only after the shared magic runtime exposes a reliable witnessed-cast signal.
- [x] Split revelation by host context: Dathrohan uses Tyr's Hand except Light's Hope; later vessels use only their current personal base.
- [ ] Do not add another culture, faith, government, or generic Nathrezim framework unless playtests expose a concrete mechanical need.

Exit gate: hidden play produces readable counter-pressure and exposure changes the campaign without expanding the system beyond Balnazzar.

## Phase 10 — 1000-series consistency pass

Scope this pass to `wc_balnazzar_story.1001` through `.1011`. Do not add Argent or Light's Hope content until their earlier history has its own supported arc.

- [x] Label canon and alternate-history beats honestly in the staged-death, Ashbringer, vessel, suspicion, and Risen design notes. Player-facing tooltips describe mechanics without presenting them as historical canon.
- [x] Treat staged death, Dathrohan possession, Scarlet corruption, Stratholme exposure, and the later Risen as the canon spine.
- [x] Treat repeat body-hopping, the Tyr's Hand-wide transformation, the sovereign Risen title, and collective Sargerite conversion as explicit GoA2 player-driven departures.
- [x] Reduce repeated `mask`, `face`, `lie`, and `throne as scaffolding` imagery; preserve the user-approved `.1001`, rename `.1002` to `Borrowed Authority`, and keep Renault's knowledge grounded in observed conduct or reports.
- [x] Keep the concrete scene craft already working in `.0110`, `.0111`, and the opening of `.1005`; keep numerical mechanics in tooltips.
- [x] Bridge the murder scheme at 15 and 65 percent visible success chance: `.1010` builds Renault's Darion bait, `.1011` sends Alexandros and Fairbanks toward Stratholme, and `.1006` reaches Balnazzar as Renault's report.

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
