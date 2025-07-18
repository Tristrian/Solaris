/obj/effect/proc_holder/spell/targeted/shapeshift
	name = "Shapechange"
	desc = ""
	clothes_req = FALSE
	human_req = FALSE
	recharge_time = 200
	cooldown_min = 50
	range = -1
	include_user = TRUE
	invocation = "RAC'WA NO!"
	invocation_type = "shout"
	action_icon_state = "shapeshift"

	var/revert_on_death = TRUE
	var/die_with_shapeshifted_form = TRUE
	var/convert_damage = TRUE //If you want to convert the caster's health to the shift, and vice versa.
	var/convert_damage_type = BRUTE //Since simplemobs don't have advanced damagetypes, what to convert damage back into.

	var/shapeshift_type
	var/list/possible_shapes = list(
		/mob/living/simple_animal/pet/dog/corgi
	)
	var/list/vampire_shapes = list(
		/mob/living/simple_animal/hostile/retaliate/vampiregaseousform,
		/mob/living/simple_animal/hostile/retaliate/bat/vampirebat
	)
/obj/effect/proc_holder/spell/targeted/shapeshift/cast(list/targets,mob/user = usr)
	. = ..()
	var/datum/antagonist/vampirelord/VD = usr?.mind?.has_antag_datum(/datum/antagonist/vampirelord)
	var/mob/living/carbon/human/H = user
	if(VD)
		if(VD.disguised)
			to_chat(usr, span_warning("My curse is hidden."))
			return
	if(H.has_status_effect(/datum/status_effect/debuff/veil_up))
		to_chat(usr, span_warning("My curse is hidden."))
		return
	if(HAS_TRAIT(H,TRAIT_VAMPIRISM) && (H.vitae < 100)) 
		to_chat(src, span_warning("Not enough vitae blood."))
		return
	if(HAS_TRAIT(H,TRAIT_VAMPIRISM))
		H.vitae -= 100
	if(src in user.mob_spell_list)
		user.mob_spell_list.Remove(src)
		user.mind.AddSpell(src)
	if(user.buckled)
		user.buckled.unbuckle_mob(src,force=TRUE)
	for(var/mob/living/M in targets)
		if(!shapeshift_type)
			var/list/animal_list = list()
			for(var/path in possible_shapes)
				var/mob/living/simple_animal/A = path
				animal_list[initial(A.name)] = path
			var/new_shapeshift_type = input(M, "Choose Your Animal Form!", "It's Morphing Time!", null) as null|anything in sortList(animal_list)
			if(shapeshift_type)
				return
			shapeshift_type = new_shapeshift_type
			if(!shapeshift_type) //If you aren't gonna decide I am!
				shapeshift_type = pick(animal_list)
			shapeshift_type = animal_list[shapeshift_type]

		var/obj/shapeshift_holder/S = locate() in M
		if(S)
			Restore(M)
		else
			if(shapeshift_type == /mob/living/simple_animal/hostile/retaliate/gaseousform)
				spawn(100)
					Restore(M)
			Shapeshift(M)

/obj/effect/proc_holder/spell/targeted/shapeshift/proc/Shapeshift(mob/living/caster)
	var/obj/shapeshift_holder/H = locate() in caster
	if(H)
		to_chat(caster, "<span class='warning'>You're already shapeshifted!</span>")
		return

	var/mob/living/shape = new shapeshift_type(caster.loc)
	H = new(shape,src,caster)

	if ((shapeshift_type == /mob/living/simple_animal/hostile/retaliate/vampiregaseousform)|| (shapeshift_type == /mob/living/simple_animal/hostile/retaliate/bat/vampirebat))
		shape.name = "[shape]"
	else
		shape.name = "[shape] ([caster.real_name])"

	clothes_req = FALSE
	human_req = FALSE

/obj/effect/proc_holder/spell/targeted/shapeshift/proc/Restore(mob/living/shape)
	var/obj/shapeshift_holder/H = locate() in shape
	if(!H)
		return

	H.restore()

	if (shapeshift_type == /mob/living/simple_animal/hostile/retaliate/vampiregaseousform)
		REMOVE_TRAIT(H, TRAIT_NOFALLDAMAGE2, MAGIC_TRAIT)

	clothes_req = initial(clothes_req)
	human_req = initial(human_req)
