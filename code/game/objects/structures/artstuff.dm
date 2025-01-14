
//////////////
// CANVASES //
//////////////

#define AMT_OF_CANVASES	4 //Keep this up to date or shit will break.

//To safe memory on making /icons we cache the blanks..
GLOBAL_LIST_INIT(globalBlankCanvases, new(AMT_OF_CANVASES))

/obj/item/canvasold
	name = "canvas"
	desc = ""
	icon = 'icons/obj/artstuff.dmi'
	icon_state = "11x11"
	resistance_flags = FLAMMABLE
	var/whichGlobalBackup = 1 //List index

/obj/item/canvasold/nineteenXnineteen
	icon_state = "19x19"
	whichGlobalBackup = 2

/obj/item/canvasold/twentythreeXnineteen
	icon_state = "23x19"
	whichGlobalBackup = 3

/obj/item/canvasold/twentythreeXtwentythree
	icon_state = "23x23"
	whichGlobalBackup = 4

//HEY YOU
//ARE YOU READING THE CODE FOR CANVASES?
//ARE YOU AWARE THEY CRASH HALF THE SERVER WHEN SOMEONE DRAWS ON THEM...
//...AND NOBODY CAN FIGURE OUT WHY?
//THEN GO ON BRAVE TRAVELER
//TRY TO FIX THEM AND REMOVE THIS CODE
/obj/item/canvasold/Initialize()
	..()
	return INITIALIZE_HINT_QDEL //Delete on creation

//Find the right size blank canvas
/obj/item/canvasold/proc/getGlobalBackup()
	. = null
	if(GLOB.globalBlankCanvases[whichGlobalBackup])
		. = GLOB.globalBlankCanvases[whichGlobalBackup]
	else
		var/icon/I = icon(initial(icon),initial(icon_state))
		GLOB.globalBlankCanvases[whichGlobalBackup] = I
		. = I



//One pixel increments
/obj/item/canvasold/attackby(obj/item/I, mob/user, params)
	//Click info
	var/list/click_params = params2list(params)
	var/pixX = text2num(click_params["icon-x"])
	var/pixY = text2num(click_params["icon-y"])

	//Should always be true, otherwise you didn't click the object, but let's check because SS13~
	if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
		return

	//Cleaning one pixel with a soap or rag
	if(istype(I, /obj/item/soap) || istype(I, /obj/item/reagent_containers/glass/rag))
		//Pixel info created only when needed
		var/icon/masterpiece = icon(icon,icon_state)
		var/thePix = masterpiece.GetPixel(pixX,pixY)
		var/icon/Ico = getGlobalBackup()
		if(!Ico)
			qdel(masterpiece)
			return

		var/theOriginalPix = Ico.GetPixel(pixX,pixY)
		if(thePix != theOriginalPix) //colour changed
			DrawPixelOn(theOriginalPix,pixX,pixY)
		qdel(masterpiece)

	else
		return ..()


//Clean the whole canvas
/obj/item/canvasold/attack_self(mob/user)
	if(!user)
		return
	var/icon/blank = getGlobalBackup()
	if(blank)
		//it's basically a giant etch-a-sketch
		icon = blank
		user.visible_message("<span class='notice'>[user] cleans the canvas.</span>","<span class='notice'>I clean the canvas.</span>")


#undef AMT_OF_CANVASES
