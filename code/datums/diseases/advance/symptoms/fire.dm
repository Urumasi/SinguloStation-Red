/*
//////////////////////////////////////

Spontaneous Combustion

	Slightly hidden.
	Lowers resistance tremendously.
	Decreases stage tremendously.
	Decreases transmittablity tremendously.
	Fatal Level.

Bonus
	Ignites infected mob.

//////////////////////////////////////
*/

/datum/symptom/fire

	name = "Spontaneous Combustion"
	desc = "The virus turns fat into an extremely flammable compound, and raises the body's temperature, making the host burst into flames spontaneously."
	stealth = 1
	resistance = -2
	stage_speed = -3
	transmission = -3
	level = 6
	severity = 4
	base_message_chance = 20
	symptom_delay_min = 20
	symptom_delay_max = 75
	var/infective = FALSE
	threshold_desc = "<b>Stage Speed 4:</b> Increases the intensity of the flames.<br>\
					  <b>Stage Speed 8:</b> Further increases flame intensity.<br>\
					  <b>Transmission 8:</b> Host will spread the virus through skin flakes when bursting into flame.<br>\
					  <b>Stealth 4:</b> The symptom remains hidden until active."

/datum/symptom/fire/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.stage_rate >= 4)
		power = 1.5
		if(A.stage_rate >= 8)
			power = 2
	if(A.stealth >= 4)
		suppress_warning = TRUE
	if(A.transmission >= 8) //burning skin spreads the virus through smoke
		infective = TRUE

/datum/symptom/fire/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(3)
			if(prob(base_message_chance) && !suppress_warning)
				to_chat(M, "<span class='warning'>[pick("You feel hot.", "You hear a crackling noise.", "You smell smoke.")]</span>")
		if(4)
			Firestacks_stage_4(M, A)
			M.IgniteMob()
			to_chat(M, "<span class='userdanger'>Your skin bursts into flames!</span>")
			M.emote("scream")
		if(5)
			Firestacks_stage_5(M, A)
			M.IgniteMob()
			to_chat(M, "<span class='userdanger'>Your skin erupts into an inferno!</span>")
			M.emote("scream")

/datum/symptom/fire/proc/Firestacks_stage_4(mob/living/M, datum/disease/advance/A)
	M.adjust_fire_stacks(1 * power)
	M.take_overall_damage(burn = 3 * power, required_status = BODYPART_ORGANIC)
	if(infective)
		A.spread(2)
	return 1

/datum/symptom/fire/proc/Firestacks_stage_5(mob/living/M, datum/disease/advance/A)
	if(HAS_TRAIT(M, TRAIT_FAT))
		M.adjust_fire_stacks(6 * power)
	else
		M.adjust_fire_stacks(3 * power)
	M.take_overall_damage(burn = 5 * power, required_status = BODYPART_ORGANIC)
	if(infective)
		A.spread(4)
	return 1


/*
//////////////////////////////////////

Alkali perspiration

	Hidden.
	Lowers resistance.
	Decreases stage speed.
	Decreases transmittablity.
	Fatal Level.

Bonus
	Ignites infected mob.
	Explodes mob on contact with water.

//////////////////////////////////////
*/

/datum/symptom/alkali

	name = "Alkali Perspiration"
	desc = "The virus attaches to sudoriparous glands, synthesizing a chemical that bursts into flames when reacting with water, leading to self-immolation."
	stealth = 2
	resistance = -2
	stage_speed = -2
	transmission = -2
	level = 9
	severity = 5
	base_message_chance = 100
	symptom_delay_min = 30
	symptom_delay_max = 90
	var/chems = FALSE
	var/explosion_power = 1
	threshold_desc = "<b>Resistance 9:</b> Doubles the intensity of the effect, but reduces its frequency.<br>\
					  <b>Stage Speed 8:</b> Increases explosion radius when the host is wet.<br>\
					  <b>Transmission 8:</b> Additionally synthesizes chlorine trifluoride and napalm inside the host."

/datum/symptom/alkali/severityset(datum/disease/advance/A)
	. = ..()
	if(A.resistance >= 9 || A.stage_rate >= 8)
		severity = 6

/datum/symptom/alkali/Start(datum/disease/advance/A)
	if(!..())
		return
	if(A.resistance >= 9) //intense but sporadic effect
		power = 2
		symptom_delay_min = 50
		symptom_delay_max = 140
	if(A.stage_rate >= 8) //serious boom when wet
		explosion_power = 2
	if(A.transmission >= 8) //extra chemicals
		chems = TRUE

/datum/symptom/alkali/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/M = A.affected_mob
	switch(A.stage)
		if(3)
			if(prob(base_message_chance))
				to_chat(M, "<span class='warning'>[pick("Your veins boil.", "You feel hot.", "You smell meat cooking.")]</span>")
		if(4)
			if(M.fire_stacks < 0)
				M.visible_message("<span class='warning'>[M]'s sweat sizzles and pops on contact with water!</span>")
				explosion(get_turf(M),-1,(-1 + explosion_power),(2 * explosion_power))
			Alkali_fire_stage_4(M, A)
			M.IgniteMob()
			to_chat(M, "<span class='userdanger'>Your sweat bursts into flames!</span>")
			M.emote("scream")
		if(5)
			if(M.fire_stacks < 0)
				M.visible_message("<span class='warning'>[M]'s sweat sizzles and pops on contact with water!</span>")
				explosion(get_turf(M),-1,(-1 + explosion_power),(2 * explosion_power))
			Alkali_fire_stage_5(M, A)
			M.IgniteMob()
			to_chat(M, "<span class='userdanger'>Your skin erupts into an inferno!</span>")
			M.emote("scream")

/datum/symptom/alkali/proc/Alkali_fire_stage_4(mob/living/M, datum/disease/advance/A)
	var/get_stacks = 6 * power
	M.adjust_fire_stacks(get_stacks)
	M.take_overall_damage(burn = get_stacks / 2, required_status = BODYPART_ORGANIC)
	if(chems)
		M.reagents.add_reagent(/datum/reagent/clf3, 2 * power)
	return 1

/datum/symptom/alkali/proc/Alkali_fire_stage_5(mob/living/M, datum/disease/advance/A)
	var/get_stacks = 8 * power
	M.adjust_fire_stacks(get_stacks)
	M.take_overall_damage(burn = get_stacks, required_status = BODYPART_ORGANIC)
	if(chems)
		M.reagents.add_reagent_list(list(/datum/reagent/napalm = 4 * power, /datum/reagent/clf3 = 4 * power))
	return 1
