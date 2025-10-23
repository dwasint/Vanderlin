GLOBAL_LIST_EMPTY(letters_sent)

/obj/structure/fake_machine/mail
	name = "HERMES"
	desc = "Carrier zads have fallen severely out of fashion ever since the advent of this hydropneumatic mail system."
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "mail"
	density = FALSE
	blade_dulling = DULLING_BASH
	SET_BASE_PIXEL(0, 32)
	var/coin_loaded = FALSE
	var/inqcoins = 0
	var/inqonly = FALSE // Has the Inquisitor locked Marque-spending for lessers?
	var/keycontrol = "puritan"
	var/cat_current = "1"
	var/list/all_category = list(
		"✤ RELIQUARY ✤",
		"✤ SUPPLIES ✤",
		"✤ ARTICLES ✤",
		"✤ EQUIPMENT ✤",
		"✤ WARDROBE ✤"
	)
	var/list/category = list(
		"✤ SUPPLIES ✤",
		"✤ ARTICLES ✤",
		"✤ EQUIPMENT ✤",
		"✤ WARDROBE ✤"
	)
	var/list/inq_category = list("✤ RELIQUARY ✤")
	var/ournum
	var/mailtag
	var/obfuscated = FALSE

/obj/structure/fake_machine/mail/Initialize()
	. = ..()
	SSroguemachine.hermailers += src
	ournum = SSroguemachine.hermailers.len
	name = "[name] #[ournum]"
	update_appearance()

/obj/structure/fake_machine/mail/Destroy()
	set_light(0)
	SSroguemachine.hermailers -= src
	return ..()

/obj/structure/fake_machine/mail/attack_hand(mob/user)
	if(SSroguemachine.hermailermaster && ishuman(user))
		var/obj/item/fake_machine/mastermail/M = SSroguemachine.hermailermaster
		var/mob/living/carbon/human/H = user
		var/addl_mail = FALSE
		for(var/obj/item/I in M.contents)
			if(I.mailedto == H.real_name)
				if(!addl_mail)
					I.forceMove(src.loc)
					user.put_in_hands(I)
					addl_mail = TRUE
				else
					say("You have additional mail available.")
					break
	if(!ishuman(user))
		return
	if(HAS_TRAIT(user, TRAIT_INQUISITION))
		if(!coin_loaded && !inqcoins)
			to_chat(user, span_notice("It needs a Marque."))
			return
		user.changeNext_move(CLICK_CD_MELEE)
		display_marquette(usr)

/obj/structure/fake_machine/mail/examine(mob/user)
	. = ..()
	. += span_info("Load a coin inside, then right click to send a letter.")
	. += span_info("Left click with a paper to send a prewritten letter for free.")
	if(HAS_TRAIT(user, TRAIT_INQUISITION))
		. += span_info("<br>The MARQUETTE can be accessed via a secret compartment fitted within the HERMES. Load a Marque to access it.")

		. += span_info("You can send arrival slips, accusation slips, fully loaded INDEXERs or confessions here.")
		. += span_info("Properly sign them. Include an INDEXER where needed. Stamp them for two additional Marques.")

/obj/structure/fake_machine/mail/attack_hand_secondary(mob/user, params)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	user.changeNext_move(6)
	if(!coin_loaded)
		to_chat(user, span_warning("The machine doesn't respond. It needs a coin."))
		return
	if(inqcoins)
		to_chat(user, span_warning("The machine doesn't respond."))
		return
	var/send2place = browser_input_text(user, "Where to? (Person or #number)")
	if(!send2place)
		return
	var/sentfrom = browser_input_text(user, "Who is this letter from?")
	if(!sentfrom)
		sentfrom = "Anonymous"
	var/t = stripped_multiline_input("Write Your Letter", "VANDERLIN", no_trim=TRUE)
	if(t)
		if(length(t) > 2000)
			to_chat(user, span_warning("Too long. Try again."))
			return
	if(!coin_loaded)
		return
	if(!Adjacent(user))
		return
	var/obj/item/paper/P = new
	P.info += t
	P.mailer = sentfrom
	P.mailedto = send2place
	P.update_appearance()
	if(findtext(send2place, "#"))
		var/box2find = text2num(copytext(send2place, findtext(send2place, "#")+1))
		var/found = FALSE
		for(var/obj/structure/fake_machine/mail/X in SSroguemachine.hermailers)
			if(X.ournum == box2find)
				found = TRUE
				P.mailer = sentfrom
				P.mailedto = send2place
				P.update_appearance()
				P.forceMove(X.loc)
				X.say("New mail!")
				playsound(X, 'sound/misc/mail.ogg', 100, FALSE, -1)
				break
		if(found)
			if(P.info)
				var/stripped_info = remove_color_tags(P.info)
				GLOB.letters_sent |= stripped_info

			visible_message(span_warning("[user] sends something."))
			playsound(loc, 'sound/misc/disposalflush.ogg', 100, FALSE, -1)
			SStreasury.give_money_treasury(coin_loaded, "Mail Income")
			coin_loaded = FALSE
			update_appearance()
			return
		else
			to_chat(user, span_warning("Failed to send it. Bad number?"))
	else
		if(!send2place)
			return
		if(SSroguemachine.hermailermaster)
			var/obj/item/fake_machine/mastermail/X = SSroguemachine.hermailermaster
			P.mailer = sentfrom
			P.mailedto = send2place
			P.update_appearance()
			P.forceMove(X.loc)
			var/datum/component/storage/STR = X.GetComponent(/datum/component/storage)
			STR.handle_item_insertion(P, prevent_warning=TRUE)
			X.new_mail=TRUE
			X.update_appearance()
			send_ooc_note("New letter from <b>[sentfrom].</b>", name = send2place)
			for(var/mob/living/carbon/human/H in GLOB.human_list)
				if(H.real_name == send2place)
					H.playsound_local(H, 'sound/misc/mail.ogg', 100, FALSE, -1)
		else
			to_chat(user, span_warning("The master of mails has perished?"))
			return
		if(P.info)
			var/stripped_info = remove_color_tags(P.info)
			GLOB.letters_sent |= stripped_info
		visible_message(span_warning("[user] sends something."))
		playsound(loc, 'sound/misc/disposalflush.ogg', 100, FALSE, -1)
		SStreasury.give_money_treasury(coin_loaded, "Mail")
		coin_loaded = FALSE
		update_appearance(UPDATE_OVERLAYS)

/obj/structure/fake_machine/mail/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/merctoken))
		if(!ishuman(user))
			to_chat(user, span_warning("I do not know what this is, and I do not particularly care."))

		var/mob/living/carbon/human/H = user
		if(is_merchant_job(H.mind.assigned_role) || is_gaffer_job(H.mind.assigned_role))
			to_chat(H, span_warning("This is of no use to me - I may give this to a mercenary so they may send it themselves."))
			return
		if(!is_mercenary_job(H.mind.assigned_role))
			to_chat(H, span_warning("I can't make use of this - I do not belong to the Guild."))
			return
		if(H.tokenclaimed)
			to_chat(H, span_warning("I have already received my commendation. There's always next month to look forward to."))
			return
		var/obj/item/merctoken/C = P
		if(!C.signee)
			to_chat(H, span_warning("I cannot send an unsigned token."))
			return
		qdel(C)
		visible_message(span_warning("[H] sends something."))
		playsound(loc, 'sound/misc/disposalflush.ogg', 100, FALSE, -1)

		sleep(2 SECONDS) //should be a callback...

		say("THANK YOU FOR YOUR SERVITUDE.")
		playsound(loc, 'sound/misc/mercsuccess.ogg', 100, FALSE, -1)
		playsound(src.loc, 'sound/misc/hiss.ogg', 100, FALSE, -1)
		to_chat(H, span_warning("A trinket comes tumbling down from the machine. Proof of your distinction."))
		H.adjust_triumphs(3)
		H.tokenclaimed = TRUE
		var/turf/drop_location = drop_location()
		switch(H.merctype)
			if(0)
				new /obj/item/clothing/neck/shalal(drop_location)
			if(1)
				new /obj/item/clothing/neck/mercmedal/zaladin(drop_location)
			if(2)
				new /obj/item/clothing/neck/mercmedal/grenzelhoft(drop_location)
			if(3)
				new /obj/item/clothing/neck/mercmedal/underdweller(drop_location)
			if(4)
				new /obj/item/clothing/neck/mercmedal/blackoak(drop_location)
			if(5)
				new /obj/item/clothing/neck/mercmedal/steppesman(drop_location)
			if(6)
				new /obj/item/clothing/neck/mercmedal/boltslinger(drop_location)
			if(7)
				new /obj/item/clothing/neck/mercmedal/anthrax(drop_location)
			if(8)
				new /obj/item/clothing/neck/mercmedal/duelist(drop_location)
			if(9)
				new /obj/item/clothing/neck/mercmedal(drop_location)
			if(10)
				new /obj/item/clothing/neck/mercmedal/abyssal(drop_location)
			if(11)
				new /obj/item/clothing/neck/mercmedal/goldfeather(drop_location)

	if(HAS_TRAIT(user, TRAIT_INQUISITION))
		if(istype(P, /obj/item/key))
			var/obj/item/key/K = P
			if(keycontrol in K.lockids) // Inquisitor's Key
				playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
				for(var/obj/structure/fake_machine/mail/everyhermes in SSroguemachine.hermailers)
					everyhermes.inqlock()
				to_chat(user, span_warning("I [inqonly ? "enable" : "disable"] the Puritan's Lock."))
				return display_marquette(user)
			to_chat(user, span_warning("Wrong key."))
			return
		if(istype(P, /obj/item/storage/keyring))
			var/obj/item/storage/keyring/K = P
			if(!K.contents.len)
				return
			var/list/keysy = K.contents.Copy()
			for(var/obj/item/key/KE in keysy)
				if(keycontrol in KE.lockids)
					playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
					for(var/obj/structure/fake_machine/mail/everyhermes in SSroguemachine.hermailers)
						everyhermes.inqlock()
					to_chat(user, span_warning("I [inqonly ? "enable" : "disable"] the Puritan's Lock."))
					return display_marquette(user)

	if(istype(P, /obj/item/inqarticles/bmirror))
		if((HAS_TRAIT(user, TRAIT_INQUISITION) || HAS_TRAIT(user, TRAIT_PURITAN)))
			var/obj/item/inqarticles/bmirror/I = P
			if(I.broken && !I.bloody)
				visible_message(span_warning("[user] sends something."))
				budget2change(2, user, "MARQUE")
				qdel(I)
				GLOB.vanderlin_round_stats[STATS_MARQUES_MADE] += 2
				playsound(loc, 'sound/misc/otavanlament.ogg', 100, FALSE, -1)
				playsound(loc, 'sound/misc/disposalflush.ogg', 100, FALSE, -1)
			else
				if(!I.broken)
					to_chat(user, (span_warning("It isn't broken.")))
				if(I.broken)
					to_chat(user, (span_warning("Clean it first.")))

	if(istype(P, /obj/item/paper/inqslip/confession))
		if((HAS_TRAIT(user, TRAIT_INQUISITION) || HAS_TRAIT(user, TRAIT_PURITAN)))
			var/obj/item/paper/inqslip/confession/I = P
			if(I.signee && I.signed)
				var/no
				var/accused
				var/indexed
				var/selfreport
				var/correct
				if(HAS_TRAIT(I.signee, TRAIT_INQUISITION))
					selfreport = TRUE
				if(HAS_TRAIT(I.signee, TRAIT_CABAL))
					correct = TRUE
				if(I.signee.name in GLOB.excommunicated_players)
					correct = TRUE
				if(I.paired)
					if(HAS_TRAIT(I.paired.subject, TRAIT_INQUISITION))
						selfreport = TRUE
						indexed = TRUE
					if(I.paired.subject && I.paired.full && GLOB.indexed && !selfreport)
						if(", [I.signee]" in GLOB.indexed)
							indexed = TRUE
						if("[I.signee]" in GLOB.indexed)
							indexed = TRUE
						if(!indexed)
							if(GLOB.indexed.len)
								GLOB.indexed += ", [I.signee]"
							else
								GLOB.indexed += "[I.signee]"
				if(GLOB.accused && !selfreport)
					if(", [I.signee]" in GLOB.accused)
						accused = TRUE
					if("[I.signee]" in GLOB.accused)
						accused = TRUE
				if(GLOB.confessors && !selfreport)
					if(", [I.signee]" in GLOB.confessors)
						no = TRUE
					if("[I.signee]" in GLOB.confessors)
						no = TRUE
					if(!no)
						if(GLOB.confessors.len)
							GLOB.confessors += ", [I.signee]"
						else
							GLOB.confessors += "[I.signee]"
				if(no | selfreport)
					if(I.paired)
						qdel(I.paired)
					qdel(I)
					visible_message(span_warning("[user] sends something."))
					playsound(loc, 'sound/misc/disposalflush.ogg', 100, FALSE, -1)
					if(no)
						to_chat(user, span_notice("They've already confessed."))
					if(selfreport)
						to_chat(user, span_notice("Why was that confession signed by an inquisition member? What?"))
						if(indexed)
							visible_message(span_warning("[user] recieves something."))
							var/obj/item/inqarticles/indexer/replacement = new /obj/item/inqarticles/indexer/
							user.put_in_hands(replacement)
					return
				else
					if(I.paired)
						if(!indexed && !correct)
							budget2change(2, user, "MARQUE")
							GLOB.vanderlin_round_stats[STATS_MARQUES_MADE] += 2
					else if(correct)
						if(I.paired)
							if(!indexed)
								I.marquevalue += 2
						if(accused)
							I.marquevalue -= 4
						budget2change(I.marquevalue, user, "MARQUE")
						GLOB.vanderlin_round_stats[STATS_MARQUES_MADE] += I.marquevalue
					if(I.paired)
						qdel(I.paired)
					qdel(I)
					visible_message(span_warning("[user] sends something."))
					playsound(loc, 'sound/misc/otavanlament.ogg', 100, FALSE, -1)
					playsound(loc, 'sound/misc/disposalflush.ogg', 100, FALSE, -1)
			return

	if(istype(P, /obj/item/inqarticles/indexer))
		if((HAS_TRAIT(user, TRAIT_INQUISITION) || HAS_TRAIT(user, TRAIT_PURITAN)))
			var/obj/item/inqarticles/indexer/I = P
			if(I.cursedblood)
				var/stopfarming
				if(GLOB.cursedsamples)
					if(", [I.subject.mind]" in GLOB.cursedsamples)
						stopfarming = TRUE
					if("[I.subject.mind]" in GLOB.cursedsamples)
						stopfarming = TRUE
					if(!stopfarming)
						if(GLOB.cursedsamples.len)
							GLOB.cursedsamples += ", [I.subject.mind]"
						else
							GLOB.cursedsamples += "[I.subject.mind]"
				if(stopfarming)
					qdel(I)
					visible_message(span_warning("[user] sends something."))
					playsound(loc, 'sound/misc/disposalflush.ogg', 100, FALSE, -1)
					visible_message(span_warning("[user] recieves something."))
					to_chat(user, span_notice("We've already collected a sample of their accursed blood."))
					var/obj/item/inqarticles/indexer/replacement = new /obj/item/inqarticles/indexer/
					user.put_in_hands(replacement)
				else
					var/yummers = I.cursedblood * 2	+ 2
					budget2change(yummers, user, "MARQUE")
					GLOB.vanderlin_round_stats[STATS_MARQUES_MADE] += yummers
					qdel(I)
					visible_message(span_warning("[user] sends something."))
					playsound(loc, 'sound/misc/otavanlament.ogg', 100, FALSE, -1)
					playsound(loc, 'sound/misc/disposalflush.ogg', 100, FALSE, -1)
			else if(I.subject && I.full)
				var/no
				var/selfreport
				if(HAS_TRAIT(I.subject, TRAIT_INQUISITION))
					selfreport = TRUE
				if(GLOB.indexed && !selfreport)
					if(", [I.subject]" in GLOB.indexed)
						no = TRUE
					if("[I.subject]" in GLOB.indexed)
						no = TRUE
					if(!no)
						if(GLOB.indexed.len)
							GLOB.indexed += ", [I.subject]"
						else
							GLOB.indexed += "[I.subject]"
				if(no || selfreport)
					qdel(I)
					visible_message(span_warning("[user] sends something."))
					playsound(loc, 'sound/misc/disposalflush.ogg', 100, FALSE, -1)
					visible_message(span_warning("[user] recieves something."))
					if(selfreport)
						to_chat(user, span_notice("Why did that INDEXER contain Inquisitional blood? What am I doing?"))
					else
						to_chat(user, span_notice("It appears we already had them INDEXED. I've been issued a replacement."))
					var/obj/item/inqarticles/indexer/replacement = new /obj/item/inqarticles/indexer/
					user.put_in_hands(replacement)
				else
					budget2change(2, user, "MARQUE")
					GLOB.vanderlin_round_stats[STATS_MARQUES_MADE] += 2
					qdel(I)
					visible_message(span_warning("[user] sends something."))
					playsound(loc, 'sound/misc/otavasent.ogg', 100, FALSE, -1)
					playsound(loc, 'sound/misc/disposalflush.ogg', 100, FALSE, -1)
			return

	if(istype(P, /obj/item/paper/inqslip/arrival))
		if((HAS_TRAIT(user, TRAIT_INQUISITION) || HAS_TRAIT(user, TRAIT_PURITAN)))
			var/obj/item/paper/inqslip/arrival/I = P
			if(I.signee && I.signed)
				message_admins("INQ ARRIVAL: [user.real_name] ([user.ckey]) has just arrived as a [user.job], earning [I.marquevalue] Marques.")
				log_game("INQ ARRIVAL: [user.real_name] ([user.ckey]) has just arrived as a [user.job], earning [I.marquevalue] Marques.")
				budget2change(I.marquevalue, user, "MARQUE")
				GLOB.vanderlin_round_stats[STATS_MARQUES_MADE] += I.marquevalue
				qdel(I)
				visible_message(span_warning("[user] sends something."))
				playsound(loc, 'sound/misc/otavasent.ogg', 100, FALSE, -1)
				playsound(loc, 'sound/misc/disposalflush.ogg', 100, FALSE, -1)
			return

	if(istype(P, /obj/item/paper/inqslip/accusation))
		if((HAS_TRAIT(user, TRAIT_INQUISITION) || HAS_TRAIT(user, TRAIT_PURITAN)))
			var/obj/item/paper/inqslip/accusation/I = P
			if(I.paired)
				if(I.signee && I.paired.full && I.paired.subject)
					var/no
					var/specialno
					var/indexed
					var/correct
					var/selfreport
					if(HAS_TRAIT(I.paired.subject, TRAIT_INQUISITION))
						selfreport = TRUE
					if(HAS_TRAIT(I.paired.subject, TRAIT_CABAL))
						correct = TRUE
					if(I.paired.subject.name in GLOB.excommunicated_players)
						correct = TRUE
					if(GLOB.indexed && !selfreport)
						if(", [I.paired.subject]" in GLOB.indexed)
							indexed = TRUE
						if("[I.paired.subject]" in GLOB.indexed)
							indexed = TRUE
						if(!indexed && !selfreport)
							if(GLOB.indexed.len)
								GLOB.indexed += ", [I.paired.subject]"
							else
								GLOB.indexed += "[I.paired.subject]"
					if(GLOB.accused && !selfreport)
						if(", [I.paired.subject]" in GLOB.accused)
							no = TRUE
						if("[I.paired.subject]" in GLOB.accused)
							no = TRUE
						if(!no)
							if(GLOB.accused.len)
								GLOB.accused += ", [I.paired.subject]"
							else
								GLOB.accused += "[I.paired.subject]"
					if(GLOB.confessors && !selfreport)
						if(", [I.paired.subject]" in GLOB.confessors)
							no = TRUE
							specialno = TRUE
						if("[I.paired.subject]" in GLOB.confessors)
							no = TRUE
							specialno = TRUE
					if(no || selfreport)
						qdel(I.paired)
						qdel(I)
						visible_message(span_warning("[user] sends something."))
						playsound(loc, 'sound/misc/disposalflush.ogg', 100, FALSE, -1)
						if(specialno)
							to_chat(user, span_notice("They've confessed."))
						else if(selfreport)
							to_chat(user, span_notice("Why are we accusing our own? What have we come to?"))
							visible_message(span_warning("[user] recieves something."))
							var/obj/item/inqarticles/indexer/replacement = new /obj/item/inqarticles/indexer/
							user.put_in_hands(replacement)
						else
							to_chat(user, span_notice("They've already been accused."))
						return
					else
						if(correct)
							if(!indexed)
								I.marquevalue += 2
							budget2change(I.marquevalue, user, "MARQUE")
							GLOB.vanderlin_round_stats[STATS_MARQUES_MADE] += I.marquevalue
						qdel(I.paired)
						qdel(I)
						visible_message(span_warning("[user] sends something."))
						playsound(loc, 'sound/misc/otavanlament.ogg', 100, FALSE, -1)
						playsound(loc, 'sound/misc/disposalflush.ogg', 100, FALSE, -1)
						return
				else
					if(!I.paired.full)
						to_chat(user, span_warning("[I.paired] needs to be full of the accused's blood."))
						return
					else
						to_chat(user, span_warning("[I] is missing a signature."))
						return
			else
				to_chat(user, span_warning("[I] is missing an INDEXER."))
				return

	if(istype(P, /obj/item/paper))
		var/obj/item/paper/PA = P
		if(inqcoins)
			to_chat(user, span_warning("The machine doesn't respond."))
			return
		if(alert(user, "Send Mail?",,"YES","NO") == "YES")
			var/send2place = input(user, "Where to? (Person or #number)", "Vanderlin", null)
			var/sentfrom = input(user, "Who is this from?", "Vanderlin", null)
			if(!sentfrom)
				sentfrom = "Anonymous"
			if(findtext(send2place, "#"))
				var/box2find = text2num(copytext(send2place, findtext(send2place, "#")+1))
				testing("box2find [box2find]")
				var/found = FALSE
				for(var/obj/structure/fake_machine/mail/X in SSroguemachine.hermailers)
					if(X.ournum == box2find)
						found = TRUE
						P.mailer = sentfrom
						P.mailedto = send2place
						P.update_appearance()
						P.forceMove(X.loc)
						X.say("New mail!")
						playsound(X, 'sound/misc/mail.ogg', 100, FALSE, -1)
						break
				if(found)
					if(PA.info)
						var/stripped_info = remove_color_tags(PA.info)
						GLOB.letters_sent |= stripped_info
					visible_message(span_warning("[user] sends something."))
					playsound(loc, 'sound/misc/disposalflush.ogg', 100, FALSE, -1)
					return
				else
					to_chat(user, span_warning("Cannot send it. Bad number?"))
			else
				if(!send2place)
					return
				var/findmaster
				if(SSroguemachine.hermailermaster)
					var/obj/item/fake_machine/mastermail/X = SSroguemachine.hermailermaster
					findmaster = TRUE
					P.mailer = sentfrom
					P.mailedto = send2place
					P.update_appearance()
					P.forceMove(X.loc)
					var/datum/component/storage/STR = X.GetComponent(/datum/component/storage)
					STR.handle_item_insertion(P, prevent_warning=TRUE)
					X.new_mail=TRUE
					X.update_appearance()
					playsound(src.loc, 'sound/misc/mail.ogg', 100, FALSE, -1)
				if(!findmaster)
					to_chat(user, span_warning("The master of mails has perished?"))
				else
					if(PA.info)
						var/stripped_info = remove_color_tags(PA.info)
						GLOB.letters_sent |= stripped_info
					visible_message(span_warning("[user] sends something."))
					playsound(loc, 'sound/misc/disposalflush.ogg', 100, FALSE, -1)
					send_ooc_note("New letter from <b>[sentfrom].</b>", name = send2place)
					for(var/mob/living/carbon/human/H in GLOB.human_list)
						if(H.real_name == send2place)
							H.playsound_local(H, 'sound/misc/mail.ogg', 100, FALSE, -1)
					return


	if(istype(P, /obj/item/coin/inqcoin))
		if(HAS_TRAIT(user, TRAIT_INQUISITION))
			if(coin_loaded && !inqcoins)
				return
			var/obj/item/coin/M = P
			coin_loaded = TRUE
			inqcoins += M.quantity
			update_appearance()
			qdel(M)
			playsound(src, 'sound/misc/coininsert.ogg', 100, FALSE, -1)
			return display_marquette(usr)
		else
			return

	if(istype(P, /obj/item/coin))
		if(coin_loaded)
			return
		var/obj/item/coin/C = P
		if(C.quantity > 1)
			return
		coin_loaded = C.get_real_price()
		qdel(C)
		playsound(src, 'sound/misc/coininsert.ogg', 100, FALSE, -1)
		update_appearance()
		return
	..()

/obj/structure/fake_machine/mail/r
	SET_BASE_PIXEL(32, 0)

/obj/structure/fake_machine/mail/l
	SET_BASE_PIXEL(-32, 0)

/obj/structure/fake_machine/mail/update_overlays()
	. = ..()
	cut_overlays()
	if(coin_loaded)
		if(inqcoins > 0)
			. += mutable_appearance(icon, "mail-i")
			set_light(1, 1, 1, l_color = "#ffffff")
		else
			. += mutable_appearance(icon, "mail-f")
			set_light(1, 1, 1, l_color = "#1b7bf1")
	else
		. += mutable_appearance(icon, "mail-s")
		set_light(1, 1, 1, l_color = "#ff0d0d")

/obj/structure/fake_machine/mail/examine(mob/user)
	. = ..()
	. += "<a href='?src=[REF(src)];directory=1'>Directory:</a> [mailtag]"

/obj/structure/fake_machine/mail/Topic(href, href_list)
	..()

	if(!usr)
		return

	if(href_list["directory"])
		view_directory(usr)

/obj/structure/fake_machine/mail/proc/view_directory(mob/user)
	var/dat
	for(var/obj/structure/fake_machine/mail/X in SSroguemachine.hermailers)
		if(X.obfuscated)
			continue
		if(X.mailtag)
			dat += "#[X.ournum] [X.mailtag]<br>"
		else
			dat += "#[X.ournum] [capitalize(get_area_name(X))]<br>"

	var/datum/browser/popup = new(user, "hermes_directory", "<center>HERMES DIRECTORY</center>", 387, 420)
	popup.set_content(dat)
	popup.open(FALSE)

/obj/item/fake_machine/mastermail
	name = "MASTER OF MAILS"
	icon = 'icons/roguetown/misc/machines.dmi'
	icon_state = "mailspecial"
	SET_BASE_PIXEL(0, 32)
	max_integrity = 0
	density = FALSE
	blade_dulling = DULLING_BASH
	anchored = TRUE
	w_class = WEIGHT_CLASS_GIGANTIC
	var/new_mail

/obj/item/fake_machine/mastermail/update_icon_state()
	. = ..()
	if(new_mail)
		icon_state = "mailspecial-get"
	else
		icon_state = "mailspecial"
	set_light(1, 1, 1, l_color = "#ff0d0d")

/obj/item/fake_machine/mastermail/attack_hand(mob/user)
	var/datum/component/storage/CP = GetComponent(/datum/component/storage)
	if(CP)
		if(new_mail)
			new_mail = FALSE
			update_appearance()
		return TRUE

/obj/item/fake_machine/mastermail/Initialize()
	. = ..()
	AddComponent(/datum/component/storage/concrete/grid/mailmaster)
	SSroguemachine.hermailermaster = src
	update_appearance()

/obj/item/fake_machine/mastermail/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/paper))
		var/obj/item/paper/PA = P
		if(!PA.mailer && !PA.mailedto && PA.cached_mailer && PA.cached_mailedto)
			PA.mailer = PA.cached_mailer
			PA.mailedto = PA.cached_mailedto
			PA.cached_mailer = null
			PA.cached_mailedto = null
			PA.update_appearance()
			to_chat(user, span_warning("I carefully re-seal the letter and place it back in the machine, no one will know."))
		P.forceMove(loc)
		var/datum/component/storage/STR = GetComponent(/datum/component/storage)
		STR.handle_item_insertion(P, prevent_warning=TRUE)
	..()

/obj/item/fake_machine/mastermail/Destroy()
	set_light(0)
	SSroguemachine.hermailers -= src
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	if(STR)
		var/list/things = STR.contents()
		for(var/obj/item/I in things)
			STR.remove_from_storage(I, get_turf(src))
	return ..()

/obj/structure/fake_machine/mail/proc/any_additional_mail(obj/item/fake_machine/mastermail/M, name)
	for(var/obj/item/I in M.contents)
		if(I.mailedto == name)
			return TRUE
	return FALSE


/*
	INQUISITION INTERACTIONS - START
*/

/obj/structure/fake_machine/mail/proc/inqlock()
	inqonly = !inqonly

/obj/structure/fake_machine/mail/proc/decreaseremaining(datum/inqports/PA)
	PA.remaining -= 1
	PA.name = "[initial(PA.name)] ([PA.remaining]/[PA.maximum]) - ᛉ [PA.marquescost] ᛉ"
	if(!PA.remaining)
		PA.name = "[initial(PA.name)] (OUT OF STOCK) - ᛉ [PA.marquescost] ᛉ"
	return

/obj/structure/fake_machine/mail/proc/display_marquette(mob/user)
	var/contents
	contents = "<center>✤ ── L'INQUISITION MARQUETTE D'OTAVA ── ✤<BR>"
	contents += "POUR L'ÉRADICATION DE L'HÉRÉSIE, TANT QUE PSYDON ENDURE.<BR>"
	if(HAS_TRAIT(user, TRAIT_PURITAN))
		contents += "✤ ── <a href='?src=[REF(src)];locktoggle=1]'> PURITAN'S LOCK: [inqonly ? "OUI":"NON"]</a> ── ✤<BR>"
	else
		contents += "✤ ── PURITAN'S LOCK: [inqonly ? "OUI":"NON"] ── ✤<BR>"
	contents += "ᛉ <a href='?src=[REF(src)];eject=1'>MARQUES LOADED: [inqcoins]</a>ᛉ<BR>"

	if(cat_current == "1")
		contents += "<BR> <table style='width: 100%' line-height: 40px;'>"
/*		if(HAS_TRAIT(user, TRAIT_PURITAN))
			for(var/i = 1, i <= inq_category.len, i++)
				contents += "<tr>"
				contents += "<td style='width: 100%; text-align: center;'>\
					<a href='?src=[REF(src)];changecat=[inq_category[i]]'>[inq_category[i]]</a>\
					</td>"
				contents += "</tr>"*/
		for(var/i = 1, i <= category.len, i++)
			contents += "<tr>"
			contents += "<td style='width: 100%; text-align: center;'>\
				<a href='?src=[REF(src)];changecat=[category[i]]'>[category[i]]</a>\
				</td>"
			contents += "</tr>"
		contents += "</table>"
	else
		contents += "<center>[cat_current]<BR></center>"
		contents += "<center><a href='?src=[REF(src)];changecat=1'>\[RETURN\]</a><BR><BR></center>"
		contents += "<center>"
		var/list/items = list()
		for(var/pack in GLOB.inqsupplies)
			var/datum/inqports/PA = pack
			if(all_category[PA.category] == cat_current && PA.name)
				items += GLOB.inqsupplies[pack]
				if(PA.name == "Seizing Garrote" && !HAS_TRAIT(user, TRAIT_BLACKBAGGER))
					items -= GLOB.inqsupplies[pack]
		for(var/pack in sortNames(items, order=0))
			var/datum/inqports/PA = pack
			var/name = uppertext(PA.name)
			if(inqonly && !HAS_TRAIT(user, TRAIT_PURITAN) || (PA.maximum && !PA.remaining) || inqcoins < PA.marquescost)
				contents += "[name]<BR>"
			else
				contents += "<a href='?src=[REF(src)];buy=[PA.type]'>[name]</a><BR>"
		contents += "</center>"
	var/datum/browser/popup = new(user, "VENDORTHING", "", 500, 600)
	popup.set_content(contents)
	if(inqcoins == 0)
		popup.close()
		return
	else
		popup.open()

/obj/structure/fake_machine/mail/Topic(href, href_list)
	..()
	if(href_list["eject"])
		if(inqcoins <= 0)
			return
		coin_loaded = FALSE
		update_appearance()
		budget2change(inqcoins, usr, "MARQUE")
		inqcoins = 0

	if(href_list["changecat"])
		cat_current = href_list["changecat"]

	if(href_list["locktoggle"])
		playsound(loc, 'sound/misc/beep.ogg', 100, FALSE, -1)
		for(var/obj/structure/fake_machine/mail/everyhermes in SSroguemachine.hermailers)
			everyhermes.inqlock()

	if(href_list["buy"])
		var/path = text2path(href_list["buy"])
		var/datum/inqports/PA = GLOB.inqsupplies[path]

		inqcoins -= PA.marquescost
		if(PA.maximum)
			decreaseremaining(PA)
		visible_message(span_warning("[usr] sends something."))
		if(!inqcoins)
			coin_loaded = FALSE
			update_appearance()
		playsound(loc, 'sound/misc/disposalflush.ogg', 100, FALSE, -1)
		var/list/turfs = list()
		var/area/A = GLOB.areas_by_type[/area/rogue/indoors/inq/import]
		for(var/turf/T in A)
			turfs += T
		var/turf/T = pick(turfs)
		var/pathi = pick(PA.item_type)
		playsound(T, 'sound/misc/disposalflush.ogg', 100, FALSE, -1)
		new pathi(get_turf(T))

	return display_marquette(usr)

/*
	INQUISITION INTERACTIONS - END
*/
