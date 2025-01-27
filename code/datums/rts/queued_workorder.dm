/datum/queued_workorder
	var/datum/work_order/work_path

	var/arg_1
	var/arg_2
	var/arg_3
	var/arg_4

/datum/queued_workorder/New(datum/work_order/work_path, arg1, arg2, arg3, arg4)
	. = ..()
	src.work_path = work_path
	src.arg_1 = arg1
	src.arg_2 = arg2
	src.arg_3 = arg3
	src.arg_4 = arg4
