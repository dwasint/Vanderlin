GLOBAL_VAR_INIT(noise_seed, 0)


/proc/init_world_seed(seed = 0)
	if(!seed)
		seed = world.realtime
	GLOB.noise_seed = seed
	world.log << "World seed: [seed]"

//this is like cavemen level noise, used in a few places
/proc/simple_noise(x, y, seed = 0)
	// Use the global noise seed plus local seed
	var/combined_seed = (GLOB.noise_seed + seed) % 10000

	// Create pseudo-random value using simple operations
	var/ix = round(x * 100) % 1000
	var/iy = round(y * 100) % 1000

	// Multiple mixing operations to create randomness
	var/hash = ix * 127 + iy * 311 + combined_seed * 74
	hash = (hash * 269) % 32768
	hash = (hash * 69) % 16384
	hash = (hash * 137) % 8192

	// Convert to -1 to 1 range
	return (hash / 4096.0) - 1.0

/proc/perlin_noise(x, y, seed = 0)
	var/combined_seed = (GLOB.noise_seed + seed) % 10000

	// Get integer and fractional parts
	var/xi = floor(x)
	var/yi = floor(y)
	var/xf = x - xi
	var/yf = y - yi

	// Generate gradients at corners
	var/g00 = perlin_gradient(xi, yi, combined_seed)
	var/g10 = perlin_gradient(xi + 1, yi, combined_seed)
	var/g01 = perlin_gradient(xi, yi + 1, combined_seed)
	var/g11 = perlin_gradient(xi + 1, yi + 1, combined_seed)

	// Calculate dot products
	var/d00 = dot_product(g00, xf, yf)
	var/d10 = dot_product(g10, xf - 1, yf)
	var/d01 = dot_product(g01, xf, yf - 1)
	var/d11 = dot_product(g11, xf - 1, yf - 1)

	// Smooth interpolation
	var/sx = smooth_step(xf)
	var/sy = smooth_step(yf)

	// Interpolate
	var/i1 = lerp(d00, d10, sx)
	var/i2 = lerp(d01, d11, sx)

	return lerp(i1, i2, sy)

/proc/perlin_gradient(x, y, seed)
	var/hash = (x * 127 + y * 311 + seed * 74) % 4
	switch(hash)
		if(0) return list(1, 1)
		if(1) return list(-1, 1)
		if(2) return list(1, -1)
		if(3) return list(-1, -1)

/proc/dot_product(list/gradient, x, y)
	return gradient[1] * x + gradient[2] * y

/proc/smooth_step(t)
	return t * t * (3 - 2 * t)
