# THIS IS A GENERATED FILE.
#
# Source template:
# ../GHTemplates/gfx/FX/gh_constants.fxh.jinja
#
# Please avoid manually editing this file: your changes WILL be overwritten when it gets regenerated.
# Instead, edit the source template and/or variables, then run render_templates.bat .
Code [[
	//
	// Constants
	//

	// NOTE: The following constants were extracted from vanilla AddDecals() in portrait_decals.fxh
	//       and must be kept in sync with their vanilla counterparts on game updates.
	static const int  GH_VANILLA_TEXEL_COUNT_PER_DECAL = 15;    // TEXEL_COUNT_PER_DECAL
	static const uint GH_VANILLA_DATA_MAX_VALUE        = 65535; // MAX_VALUE
	// END NOTE

	static const int GH_TOTAL_BITS_PER_MARKER = 8;
	static const int GH_DATA_BITS_PER_MARKER  = 7; // Out of GH_TOTAL_BITS_PER_MARKER bits in the full marker mask.

	static const int GH_MAX_FULL_MARKER_MASK = 255;

	static const int GH_MARKERS_PER_TERRAIN_VARIANT_INDEX_BIT = 75;
	static const int GH_TERRAIN_VARIANTS_COUNT_LOG2           = 2; // Number of bits (per region), needed to encode an index for one of the 3 terrain variants (base map included).
	static const int GH_DYNAMIC_TERRAIN_MARKERS_COUNT         = 150; // GH_MARKERS_PER_TERRAIN_VARIANT_INDEX_BIT*GH_TERRAIN_VARIANTS_COUNT_LOG2;

	static const float GH_ADJACENT_TERRAIN_BLEND_PROXIMITY_RANGE    = 0.2f;
	static const float GH_ADJACENT_POSTEFFECT_BLEND_PROXIMITY_RANGE = 1.0f;

	static const float GH_DYNAMIC_TERRAIN_MAX_SMOOTH_BORDERS_CAMERA_Y = 300.0f;

	static const float GH_VERTEX_YEET_POSITION_Y = -20000.0f;

	static const float GH_DAY_NIGHT_MIN_PROVINCE_OVERLAY_BRIGHTNESS = 0.65f;
]]