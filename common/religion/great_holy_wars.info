The Great Holy War system is for the most part pretty similar to the one introduced in CK2: Holy Fury.

The biggest difference is that all faiths use the system, rather than only Catholics.

== Concepts ==
Target character: The person who the war will be declared on
Target title: The dejure kingdom being targeted
Official recipient: Who the religious head wants installed as king
Countdown timer: How long it'll take before the war is declared
Pledged participants: Characters who have said they'll join when the war begins. Will be forced to join
War chest: Gold, piety, and prestige that can be divided between participants
Beneficiaries: Who the pledged attackers want to install as rulers in the target kingdom

== Undirected GHW ==
The fanciest form of GHW is the "undirected" form, where the religious head declares that a war will be launched in a while, and that everyone of the faith should help out in some way.

The progression is as follows:
1. The effect start_great_holy_war starts the GHW preparation, determinining the initial target, and the delay before the war should start
2. Attackers and defenders pledge using pledge_attacker/pledge_defender
3. Alternatively, provide things to the warchest using change_war_chest_gold/piety/prestige
4. When the timer runs out, on_great_holy_war_countdown_end is called
5. Script has to call start_ghw_war = cb_to_use. If not called, the GHW will be cancelled and on_great_holy_war_invalidation will be called
6. You can give out some of the war chest using divide_war_chest
7. A war unfolds as normal
8. War contribution gives GHW contribution, based on ghw_score_mult and ghw_max_score_percentage
9. War concludes as normal. As part of this, you can divvy up the war chest (will be divided based on contribution, as long as they have at least MINIMUM_CONTRIBUTION_FOR_REWARD contribution)
10. Titles are given out using do_ghw_title_handout. This does *not* give out the kingdom, just everything below it in the defenders' realms. You need to ensure the winner has a kingdom-tier title. Preferably, make it part of the same title and vassal change

== Directed GHW ==
As above, but steps 1 through 4 are skipped.
Declared via regular CB. Tied to a GHW by starting the GHW with a reference to the war.
When a GHW is set to directed, the only code difference is that the top contributor will act as their own beneficiary, and designated winners are not used. In vanilla, we also disable the war chest

== Various ==
is_great_holy_war = yes - Putting this on the GHW CB(s) will ensure that the counties that'll be given to the participants get correctly highlighted during war declaration
