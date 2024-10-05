includes = {
	"jomini/texture_decals_base.fxh"
	"jomini/portrait_user_data.fxh"
	# MOD(godherja)
	"standardfuncsgfx.fxh"
	"gh_portrait_decal_data.fxh"
	"gh_markers.fxh"
	"gh_constants.fxh"
	"gh_utils.fxh"
	# END MOD
}

Code
[[
	//
	// Types
	//

	struct GH_SReducedDecalData
	{
		uint  DiffuseIndex;
		uint  RawWeight;
		float Weight;
	};

	//
	// Constants
	//

	// NOTE: The offsets are taken from vanilla pixel shader's GetDecalData()
	//       and need to be kept in sync with it in the face of vanilla updates.
	static const int GH_VANILLA_DIFFUSE_INDEX_DECAL_DATA_OFFSET = 0;
	static const int GH_VANILLA_RAW_WEIGHT_DECAL_DATA_OFFSET    = 7;
	// END NOTE

	//
	// Service
	//

	int GH_DecalIndexToDataOffset(int DecalIndex)
	{
		return DecalIndex * GH_VANILLA_TEXEL_COUNT_PER_DECAL;
	}

	uint GH_GetDiffuseDecalTextureIndex(int DecalIndex)
	{
		return PdxReadBuffer(DecalDataBuffer, GH_DecalIndexToDataOffset(DecalIndex) + GH_VANILLA_DIFFUSE_INDEX_DECAL_DATA_OFFSET);
	}

	uint GH_GetRawDecalWeight(int DecalIndex)
	{
		return PdxReadBuffer(DecalDataBuffer, GH_DecalIndexToDataOffset(DecalIndex) + GH_VANILLA_RAW_WEIGHT_DECAL_DATA_OFFSET);
	}

	int GH_GetDynamicTerrainMarkerDecalIndex(int MarkerIndex)
	{
		// This function assumes that:
		//   1. All dynamic terrain marker decals are always present in DecalDataBuffer before DecalCount index.
		//   2. Said decals are contiguous in the buffer and ordered according to their intended index.
		//   3. Said ordered contiguous block immediately precedes DecalCount position in the buffer
		//      (i.e. there are no active decals located after terrain markers in the buffer).

		int MinMarkerDecalIndex = DecalCount - GH_DYNAMIC_TERRAIN_MARKERS_COUNT;

		return MinMarkerDecalIndex + MarkerIndex;
	}

	uint GH_GetDynamicTerrainMarkerBits(int MarkerIndex)
	{
		int  MarkerDecalIndex = GH_GetDynamicTerrainMarkerDecalIndex(MarkerIndex);
		uint MarkerRawWeight  = GH_GetRawDecalWeight(MarkerDecalIndex);

		return GH_DecodeDataMaskFromDecalRawWeight(MarkerRawWeight);
	}

	GH_SReducedDecalData GH_GetReducedDecalData(int DataOffset)
	{
		// DecalDataBuffer access pattern is based on vanilla pixel shader's GetDecalData().

		GH_SReducedDecalData Data;

		Data.DiffuseIndex = PdxReadBuffer(DecalDataBuffer, DataOffset + GH_VANILLA_DIFFUSE_INDEX_DECAL_DATA_OFFSET);
		Data.RawWeight    = PdxReadBuffer(DecalDataBuffer, DataOffset + GH_VANILLA_RAW_WEIGHT_DECAL_DATA_OFFSET);
		Data.Weight       = float(Data.RawWeight) / GH_VANILLA_DATA_MAX_VALUE;

		return Data;
	}

	// FIXME: Temporary functions to support dynamic sun brightness (day-night value)
	float GH_GetDynamicTerrainMarkerValue(int MarkerIndex)
	{
		int  MarkerDecalIndex = GH_GetDynamicTerrainMarkerDecalIndex(MarkerIndex);
		uint MarkerRawWeight  = GH_GetRawDecalWeight(MarkerDecalIndex);

		return float(MarkerRawWeight) / GH_VANILLA_DATA_MAX_VALUE;
	}

	//float GH_GetPandariaHiddenValue()
	//{
	//	return GH_GetDynamicTerrainMarkerValue(0);
	//}

	float GH_MipLevelToLod(float MipLevel)
	{
		// This function (originally GetMIP6Level()) was graciously provided by Buck (EK2).

		#ifndef PDX_OPENGL
			// If running on DX or Vulkan, use the below to get decal texture size.
			float3 TextureSize;
			DecalDiffuseArray._Texture.GetDimensions( TextureSize.x , TextureSize.y , TextureSize.z );
		#else
			// If running on OpenGL, use the below to get decal texture size.
			ivec3 TextureSize = textureSize(DecalDiffuseArray, 0);
		#endif

		// Get log base 2 for current texture size (1024px - 10, 512px - 9, etc.)
		// Take that away from 10 to find the current MIP level.
		// Take that away from MipLevel to find which MIP We need to sample in the texture buffer to retrieve the "absolute" MIP6 containing our encoded pixels

		return MipLevel - (10.0f - log2(TextureSize.x));
	}

	GH_SMarkerTexels GH_ExtractMarkerTexels(uint DiffuseIndex)
	{
		// Max pixel coordinate for the GH_MARKER_MIP_LEVEL-th mip-map.
		// TODO: Actually use a formula based on GH_MARKER_MIP_LEVEL here, instead of a literal?
		static const int MAX_MARKER_PIXEL_COORD = 15; // 6th mip-map is 16x16 for decals

		static int MarkerLod = int(GH_MipLevelToLod(GH_MARKER_MIP_LEVEL));

		static const int2 TOP_LEFT_UV     = int2(0, 0);
		static const int2 TOP_RIGHT_UV    = int2(MAX_MARKER_PIXEL_COORD, 0);
		static const int2 BOTTOM_RIGHT_UV = int2(MAX_MARKER_PIXEL_COORD, MAX_MARKER_PIXEL_COORD);
		static const int2 BOTTOM_LEFT_UV  = int2(0, MAX_MARKER_PIXEL_COORD);

		GH_SMarkerTexels MarkerTexels;
		MarkerTexels.TopLeftTexel     = GH_PdxTex2DArrayLoad(DecalDiffuseArray, int3(TOP_LEFT_UV, DiffuseIndex), MarkerLod);
		MarkerTexels.TopRightTexel    = GH_PdxTex2DArrayLoad(DecalDiffuseArray, int3(TOP_RIGHT_UV, DiffuseIndex), MarkerLod);

// 		#ifndef PIXEL_SHADER
// 			MarkerTexels.BottomRightTexel = GH_PdxTex2DArrayLoad(DecalDiffuseArray, int3(BOTTOM_RIGHT_UV, DiffuseIndex), MarkerLod);
// 			MarkerTexels.BottomLeftTexel  = GH_PdxTex2DArrayLoad(DecalDiffuseArray, int3(BOTTOM_LEFT_UV, DiffuseIndex), MarkerLod);
// 		#else
// 			// The other two corners are not currently used by pixel shaders, so no use sampling them from there.
// 			MarkerTexels.BottomRightTexel = float4(0.0f, 0.0f, 0.0f, 0.0f);
// 			MarkerTexels.BottomLeftTexel  = float4(0.0f, 0.0f, 0.0f, 0.0f);
// 		#endif // !PIXEL_SHADER

		return MarkerTexels;
	}

	int GH_AvoidTerrainMarkerDecalIndices(int DecalIndex, bool IsDynamicTerrainLoaded)
	{
		int MinTerrainMarkerDecalIndex = DecalCount - GH_DYNAMIC_TERRAIN_MARKERS_COUNT;

		// This is a workaround for bookmark characters having broken decals.
		if (!IsDynamicTerrainLoaded)
			return DecalIndex;

		// We're allowing min marker index, since that corresponds
		// to vanilla logic for PreSkinColorDecalCount in calls to AddDecals().
		return min(DecalIndex, MinTerrainMarkerDecalIndex);
	}

	bool GH_AreTerrainMarkerDecalsLoaded()
	{
		// While we're in game, we expect the last decal in the buffer to always be a terrain marker.
		// If this isn't the case, we assume terrain markers are not available (this is the case for bookmark screen, for example),
		// which means we shouldn't try skipping over terrain marker decal index range (see GH_AvoidTerrainMarkerDecalIndices()).

		uint LastDecalDiffuseIndex = GH_GetDiffuseDecalTextureIndex(DecalCount - 1);

		GH_SMarkerTexels MarkerTexels = GH_ExtractMarkerTexels(LastDecalDiffuseIndex);

		return GH_MarkerTexelEquals(MarkerTexels.TopLeftTexel, GH_MARKER_TOP_LEFT_MAP_TERRAIN);
	}
]]