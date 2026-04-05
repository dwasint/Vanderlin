/datum/book_entry/cavity_access
	name = "Accessing Body Cavities"

/datum/book_entry/cavity_access/inner_book_html(mob/user)
	return {"
		<div>
		<h2>Accessing Body Cavities</h2>
		To access the organs within a body cavity, the area must first be surgically opened.
		Remove any clothing covering the target area before beginning.
		</div>
		<br>
		<div>
		<h3>Standard Cavities</h3>
		For unencased areas such as the abdomen or limbs, you will need to:
		<ol>
			<li>Make an <b>incision</b> using a scalpel or other sharp instrument.</li>
			<li>Use a <b>retractor</b> to hold the wound open.</li>
		</ol>
		The cavity is now accessible. Organs within can be severed, healed, or removed.
		</div>
		<br>
		<div>
		<h3>Encased Cavities</h3>
		For encased areas such as the skull or ribcage, additional steps are required:
		<ol>
			<li>Make an <b>incision</b> using a scalpel or other sharp instrument.</li>
			<li>Use a <b>retractor</b> to hold the wound open.</li>
		</ol>
		</div>
	"}

/datum/book_entry/organ_surgery
	name = "Operating on Organs"

/datum/book_entry/organ_surgery/inner_book_html(mob/user)
	return {"
		<div>
		<h2>Operating on Organs</h2>
		Once a cavity is open, you may interact directly with the organs inside.
		All organ operations require the cavity to be properly accessed first - see <i>Accessing Body Cavities</i>.
		</div>
		<br>
		<div>
		<h3>Severing an Organ</h3>
		Use any <b>sharp instrument or scalpel</b> on the organ inside the open cavity.
		The operation takes approximately <b>6 seconds</b>, the patient must remain still throughout.
		<br><br>
		Once severed, the organ will remain in the cavity and can be removed by hand.
		A severed organ still inside its owner will not function until reattached.
		</div>
		<br>
		<div>
		<h3>Reattaching a Severed Organ</h3>
		Use the appropriate <b>attaching material</b> on the severed organ while it remains inside the patient.
		This consumes <b>2 units</b> of the material and takes approximately <b>3 seconds</b>.
		<br><br>
		Each organ has its own attaching requirements - consult the relevant organ page for specifics.
		</div>
		<br>
		<div>
		<h3>Healing a Damaged Organ</h3>
		Damaged organs can be treated directly using the appropriate <b>healing items or tools</b>.
		This consumes <b>2 units</b> of material where applicable and takes approximately <b>5 seconds</b>.
		Each application restores a significant portion of the organ's health.
		<br><br>
		Organs that are fully destroyed or necrotic cannot be healed by this method.
		Consult the organ's page to see what items and tools it accepts.
		</div>
	"}

/datum/book_entry/lobotomy
	name = "Lobotomy"

/datum/book_entry/lobotomy/inner_book_html(mob/user)
	return {"
		<div>
		<h2>Lobotomy</h2>
		A lobotomy is a crude but effective procedure that severs connections within the brain,
		removing certain traits and mutations at the cost of the patient's cognitive integrity.
		</div>
		<br>
		<div>
		<h3>Procedure</h3>
		<ol>
			<li>Access the <b>skull cavity</b>; incise, retract, then fracture the skull.</li>
			<li>Use a <b>hemostat</b> directly on the <b>brain</b>.</li>
		</ol>
		The procedure is immediate once the tool is applied.
		</div>
		<br>
		<div>
		<h3>Effects</h3>
		A lobotomy will remove certain genetic mutations and traits from the patient.
		The procedure is <b>irreversible</b> without further medical intervention.
		<br><br>
		<b>Warning:</b> This is a destructive procedure. Consider carefully before performing it on an unwilling or unconscious patient.
		</div>
	"}
