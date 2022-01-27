# Filter resolution based on the aspect ratio of the user's screen 
# @category: Filter
extends Filter


func apply(options: Array) -> Array:
	#	get screen ratio
	var screen_size := OS.get_screen_size()
	var screen_ratio := screen_size.x / screen_size.y
	var result := []
	for option in options:
		if option.ratio.empty():
			result.append(option)
			continue

		var ratio_arr = option.ratio.rsplit(":")
		var ratio = float(ratio_arr[0]) / float(ratio_arr[1])
		if ratio != screen_ratio:
			continue

		result.append(option)

	return result
