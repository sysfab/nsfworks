-- AMBIENCE SETUP (begin) --

require("ambience"):set({
	sky = {
		skyColor = Color(0,168,255),
		horizonColor = Color(137,222,229),
		abyssColor = Color(76,144,255),
		lightColor = Color(142,180,204),
		lightIntensity = 0.600000,
	},
	fog = {
		color = Color(19,159,204),
		near = 300,
		far = 700,
		lightAbsorbtion = 0.400000,
	},
	sun = {
		color = Color(255,247,204),
		intensity = 1.000000,
		rotation = Number3(1.096077, 2.635441, 0.000000),
	},
	ambient = {
		skyLightFactor = 0.100000,
		dirLightFactor = 0.200000,
	}
})

-- AMBIENCE SETUP (end) --
