includes = {
	"gh_utils.fxh"
}

Code [[
	// The general approach of encoding technical information via marker pixels in a decal mip-map
	// is adapted from a much more sophisticated implementation made by shader wizard Buck for EK2.

	//
	// Constants
	//

	// Marker enabling various effects is encoded via reserved RGBA values for top-left
	// and top-right pixels at this mip level of relevant decals' diffuse textures.
	static const int GH_MARKER_MIP_LEVEL = 6;

	static const float GH_MARKER_CHECK_TOLERANCE = 0.01f;

// 	static const float4 GH_MARKER_TOP_LEFT_FLAT            = float4(1.0f, 0.0f, 0.0f, 0.0f);
	static const float4 GH_MARKER_TOP_LEFT_STATUE          = float4(0.0f, 1.0f, 0.0f, 0.0f);
// 	static const float4 GH_MARKER_TOP_LEFT_STATUE_TEXTURED = float4(1.0f, 1.0f, 0.0f, 0.0f);
	static const float4 GH_MARKER_TOP_LEFT_MAP_TERRAIN     = float4(0.0f, 0.0f, 1.0f, 0.0f);
// 	static const float4 GH_MARKER_TOP_LEFT_FULLSCREEN      = float4(0.0f, 1.0f, 1.0f, 0.0f);
	static const float4 GH_MARKER_TOP_LEFT_DECAL           = float4(1.0f, 0.0f, 1.0f, 0.0f);

// 	static const float4 GH_MARKER_TOP_RIGHT_FLAT_SHADE_BLACK   = float4(1.0f, 0.0f, 0.0f, 0.0f);
// 	static const float4 GH_MARKER_TOP_RIGHT_FLAT_SHADE_VINDEON = float4(0.0f, 1.0f, 0.0f, 0.0f);
// 	static const float4 GH_MARKER_TOP_RIGHT_FLAT_SHADE_RED     = float4(1.0f, 1.0f, 0.0f, 0.0f);
// 	static const float4 GH_MARKER_TOP_RIGHT_FLAT_SHADE_TRIPPY  = float4(0.0f, 0.0f, 1.0f, 0.0f);
// 	static const float4 GH_MARKER_TOP_RIGHT_FLAT_FIGURE_BLACK  = float4(1.0f, 0.0f, 1.0f, 0.0f);

	static const float4 GH_MARKER_TOP_RIGHT_STATUE_GOLD        = float4(1.0f, 0.0f, 0.0f, 0.0f);
	static const float4 GH_MARKER_TOP_RIGHT_STATUE_MARBLE      = float4(0.0f, 1.0f, 0.0f, 0.0f);
	static const float4 GH_MARKER_TOP_RIGHT_STATUE_LIMESTONE   = float4(1.0f, 1.0f, 0.0f, 0.0f);
	static const float4 GH_MARKER_TOP_RIGHT_STATUE_STONE       = float4(0.0f, 0.0f, 1.0f, 0.0f);
	static const float4 GH_MARKER_TOP_RIGHT_STATUE_COPPER      = float4(1.0f, 0.0f, 1.0f, 0.0f);
	static const float4 GH_MARKER_TOP_RIGHT_STATUE_COPPER_RUST = float4(0.0f, 1.0f, 1.0f, 0.0f);

	static const float4 GH_MARKER_TOP_RIGHT_FULLSCREEN_OVERLAY = float4(1.0f, 0.0f, 0.0f, 0.0f);

	static const float4 GH_MARKER_TOP_RIGHT_DECAL_PULSE = float4(1.0f, 0.0f, 0.0f, 0.0f);

	// ENUM: portrait effect type
	static const uint GH_PORTRAIT_EFFECT_TYPE_NONE            = 0;
// 	static const uint GH_PORTRAIT_EFFECT_TYPE_FLAT            = 1;
	static const uint GH_PORTRAIT_EFFECT_TYPE_STATUE          = 2;
// 	static const uint GH_PORTRAIT_EFFECT_TYPE_STATUE_TEXTURED = 3;
	// END ENUM

	//
	// Types
	//

	struct GH_SMarkerTexels
	{
		float4 TopLeftTexel;
		float4 TopRightTexel;
		float4 BottomRightTexel; // Only used for dynamic map terrain, won't be read in portraits
		float4 BottomLeftTexel;  // ditto
	};

	//
	// Service
	//

	float2 GH_ToDecalUV(DecalData Data, float U, float V)
	{
		// TODO: Might need to be updated to take _UVTiling into account (see v1.12 changes to vanilla's AddDecals()).

		float AtlasFactor = 1.0f / Data._AtlasSize;

		return (float2(U, V) - Data._UVOffset) + (Data._AtlasPos * AtlasFactor);
	}

	//
	// Interface
	//

	bool GH_MarkerTexelEquals(float4 MarkerTexel0, float4 MarkerTexel1)
	{
		return distance(MarkerTexel0, MarkerTexel1) < GH_MARKER_CHECK_TOLERANCE;
	}

	bool GH_CheckMarkerTexels(GH_SMarkerTexels MarkerTexels, float4 TopLeftTexelReference, float4 TopRightTexelReference)
	{
		return GH_MarkerTexelEquals(MarkerTexels.TopLeftTexel,  TopLeftTexelReference)
			&& GH_MarkerTexelEquals(MarkerTexels.TopRightTexel, TopRightTexelReference);
	}

	int GH_DecodeIndexFromMarkerTexels(GH_SMarkerTexels MarkerTexels)
	{
		return (GH_DecodeIntFromRgb(MarkerTexels.TopRightTexel.rgb) << 0)
			| (GH_DecodeIntFromRgb(MarkerTexels.BottomRightTexel.rgb) << 3)
			| (GH_DecodeIntFromRgb(MarkerTexels.BottomLeftTexel.rgb) << 6);
	}
]]
