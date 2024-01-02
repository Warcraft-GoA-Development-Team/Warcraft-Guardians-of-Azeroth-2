Genes connect to the /ethnicities

=== Structure (very incomplete) ===

color_genes = {
	hair_color = {
		index = 0					# index within the DNA
		color = hair				# one of hair/eye/skin
		blend_range = { 0.4 0.6 }	# When inheriting the color, blend between "dominant" and "recessive" parent in this ratio. E.g. { 0.0 0.0 } will pick the "dominant" parent, and { 0.3 0.7 } with pick something 30% to 70% between parent's values.
	}
	...
}

decal = {
	type = skin						#decal type: skin or paint. Skin decals are added before skin color and use skin-diffuse+normal maps. Paint decals are added after skin color and use paint-diffuse+property maps.
	atlas_pos = { 0 0 }				#position of the decal in the atlas texture
	alpha_curve = {					#controls decal alpha relative to gene strength. Will give a linear interpolation if left unspecified
		#gene strength, decal alpha
		{ 0.0	0.6 }
		{ 1.0	0.6 }
	}
}


ugliness_feature_categories = { chin mouth } # A list of features the gene is associated with, used by ugliness_portrait_extremity_shift in traits
