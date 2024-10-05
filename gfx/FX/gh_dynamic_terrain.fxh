includes = {
	"cw/pdxterrain.fxh"
	"cw/pdxmesh_buffers.fxh"
	"jomini/portrait_user_data.fxh"
	"gh_constants.fxh"
	"gh_portrait_constants.fxh"
	"gh_portrait_decals_shared.fxh"
	"gh_dynamic_terrain_filters.fxh"
}

#
# Textures
#

TextureSampler GH_DynamicTerrainRegionsMap
{
	Index = 12
	MagFilter = "Point"
	MinFilter = "Point"
	MipFilter = "Point"
	SampleModeU = "Clamp"
	SampleModeV = "Clamp"
	File = "map_data/GH_dynamic_terrain_regions.png"
}

TextureSampler GH_DynamicTerrainAdjacencyMap
{
	Index = 13
	MagFilter = "Point"
	MinFilter = "Point"
	MipFilter = "Point"
	SampleModeU = "Clamp"
	SampleModeV = "Clamp"
	File = "map_data/GH_dynamic_terrain_adjacency.png"
}

TextureSampler GH_DynamicTerrainProximityMap
{
	Index = 14
	MagFilter = "Linear"
	MinFilter = "Linear"
	MipFilter = "Linear"
	SampleModeU = "Clamp"
	SampleModeV = "Clamp"
	File = "map_data/GH_dynamic_terrain_proximity.png"
}

# TODO: Add coverage texture(s) for terrain variants, calculated when converting
#       terrain variant index and intensity textures and masking the parts of the map
#       that a given terrain variant is supposed to affect (based on which parts differ from the base map).
#       Then use said coverage texture(s) here in shaders to force TerrainVariantindex back to 0
#       if world space coordinate for an otherwise non-0 vertex/pixel is outside the coverage area
#       for the corresponding terrain variant.
#       If we're limited to 4 terrain variants, a single texture is enough to store all 3 non-default coverage masks.
#
#       This would avoid black line artifacts at the edges of modified terrain, which the draft solution
#       with saving only the differing parts into index/intensity textures caused during experiments.
#       At the same time this would avoid the issue where future edits to the base map would cause
#       terrain variants to affect parts of the map they are not supposed to, unless all variant maps
#       are always kept in sync with the base map, which would impose huge maintenance cost onto mappers.

Code [[
	//
	// Defines
	//

	// Enable the following define (either by uncommenting or via shader_debug console command)
	// to disable dynamic terrain (takes priority over GH_ENABLE_DYNAMIC_TERRAIN).
	// This will minimize the performance impact of dynamic terrain support.
	//
	// Additionally, it will considerably speed up shader compilation on DirectX
	// by getting rid of a couple of huge unrolled loops,
	// so it's a good idea to define this when fixing unrelated compiler errors.
	//#define GH_FORCE_DISABLE_DYNAMIC_TERRAIN

	//
	// Service
	//

	int GH_GetDynamicTerrainRegionIndexImpl(PdxTextureSampler2D MapTexture, float2 WorldSpacePosXZ)
	{
		float2 RegionsMapUV = GH_WorldSpacePosXZToMapUV(WorldSpacePosXZ);

		float4 RegionsMapSample = PdxTex2DLod0(MapTexture, RegionsMapUV);

		return (int(255.0f*RegionsMapSample.r) << 0) | (int(255.0f*RegionsMapSample.g) << 8);
	}

	float GH_GetProximityToAdjacentRegion(float2 WorldSpacePosXZ)
	{
		float2 MapUV = GH_WorldSpacePosXZToMapUV(WorldSpacePosXZ);

		#ifdef PIXEL_SHADER
			return PdxTex2D(GH_DynamicTerrainProximityMap, MapUV).a;
		#else
			return PdxTex2DLod0(GH_DynamicTerrainProximityMap, MapUV).a;
		#endif
	}

	//
	// Interface
	//

	int GH_GetTerrainVariantIndexByRegion(int RegionIndex)
	{
		int VariantIndex = 0;

		int BitIndex = (RegionIndex % GH_DATA_BITS_PER_MARKER);

		GH_UNROLL
		for (int i = 0; i < GH_TERRAIN_VARIANTS_COUNT_LOG2; i++)
		{
			int  MarkerIndex = i*GH_MARKERS_PER_TERRAIN_VARIANT_INDEX_BIT + (RegionIndex / GH_DATA_BITS_PER_MARKER);

			uint MarkerBits      = GH_GetDynamicTerrainMarkerBits(MarkerIndex);
			uint VariantIndexBit = ((MarkerBits & (1 << BitIndex)) >> BitIndex);

			VariantIndex |= (int(VariantIndexBit) << i);
		}

		return VariantIndex;
	}

	int GH_GetDynamicTerrainRegionIndex(float2 WorldSpacePosXZ)
	{
		return GH_GetDynamicTerrainRegionIndexImpl(GH_DynamicTerrainRegionsMap, WorldSpacePosXZ);
	}

	int GH_GetNearestAdjacentDynamicTerrainRegionIndex(float2 WorldSpacePosXZ)
	{
		return GH_GetDynamicTerrainRegionIndexImpl(GH_DynamicTerrainAdjacencyMap, WorldSpacePosXZ);
	}

	float GH_GetAdjacentRegionBlendAmount(float2 WorldSpacePosXZ, float ProximityRange)
	{
		float Proximity         = GH_GetProximityToAdjacentRegion(WorldSpacePosXZ);
		float AdjustedProximity = saturate((Proximity - (1.0f - ProximityRange))/ProximityRange);

		return 0.5f*AdjustedProximity;
	}

	int GH_GetTerrainVariantIndex(float2 WorldSpacePosXZ)
	{
		#if defined(GH_ENABLE_DYNAMIC_TERRAIN) && !defined(GH_FORCE_DISABLE_DYNAMIC_TERRAIN)
			int RegionIndex = GH_GetDynamicTerrainRegionIndex(WorldSpacePosXZ);

			return GH_GetTerrainVariantIndexByRegion(RegionIndex);
		#else
			return 0;
		#endif // GH_ENABLE_DYNAMIC_TERRAIN && !GH_FORCE_DISABLE_DYNAMIC_TERRAIN
	}

	int GH_GetTerrainVariantIndexAtLocalOrigin(float4x4 WorldMatrix)
	{
		float3 LocalOriginWorldSpacePos = GH_ToWorldSpace(float3(0.0f, 0.0f, 0.0f), WorldMatrix);

		return GH_GetTerrainVariantIndex(LocalOriginWorldSpacePos.xz);
	}
]]

VertexShader = {
	Code = [[
		//
		// Macros
		//

		#if defined(GH_ENABLE_DYNAMIC_TERRAIN) && !defined(GH_FORCE_DISABLE_DYNAMIC_TERRAIN)

			#ifdef GH_USE_DYNAMIC_TERRAIN_FILTER

				#define GH_YEET_VERTEX_UNLESS_PASSES_DYNAMIC_TERRAIN_FILTER(TERRAIN_VARIANT_INDEX)\
					if (!GH_PassesDynamicTerrainFilter(TERRAIN_VARIANT_INDEX))\
					{\
						Out.Position.y = GH_VERTEX_YEET_POSITION_Y;\
						return Out;\
					}

			#else

				#define GH_YEET_VERTEX_UNLESS_PASSES_DYNAMIC_TERRAIN_FILTER(TERRAIN_VARIANT_INDEX)

			#endif // GH_USE_DYNAMIC_TERRAIN_FILTER

			#define GH_RETRIEVE_AND_FILTER_TERRAIN_VARIANT_EXPLICIT(WORLD_MATRIX, TERRAIN_VARIANT_INDEX_OUTPUT_VAR)\
				TERRAIN_VARIANT_INDEX_OUTPUT_VAR = GH_GetTerrainVariantIndexAtLocalOrigin(WORLD_MATRIX);\
				GH_YEET_VERTEX_UNLESS_PASSES_DYNAMIC_TERRAIN_FILTER(TERRAIN_VARIANT_INDEX_OUTPUT_VAR);

			#define GH_RETRIEVE_AND_FILTER_TERRAIN_VARIANT_STANDARD_EXPLICIT(TERRAIN_VARIANT_INDEX_OUTPUT_VAR)\
				float4x4 GH_WorldMatrix = PdxMeshGetWorldMatrix(Input.InstanceIndices.y);\
				GH_RETRIEVE_AND_FILTER_TERRAIN_VARIANT_EXPLICIT(GH_WorldMatrix, TERRAIN_VARIANT_INDEX_OUTPUT_VAR);

		#else

			#define GH_RETRIEVE_AND_FILTER_TERRAIN_VARIANT_EXPLICIT(WORLD_MATRIX, TERRAIN_VARIANT_INDEX_OUTPUT_VAR)\
				TERRAIN_VARIANT_INDEX_OUTPUT_VAR = 0;

			#define GH_RETRIEVE_AND_FILTER_TERRAIN_VARIANT_STANDARD_EXPLICIT(TERRAIN_VARIANT_INDEX_OUTPUT_VAR)\
				TERRAIN_VARIANT_INDEX_OUTPUT_VAR = 0;

		#endif // GH_ENABLE_DYNAMIC_TERRAIN && !GH_FORCE_DISABLE_DYNAMIC_TERRAIN

		#define GH_RETRIEVE_AND_FILTER_TERRAIN_VARIANT(WORLD_MATRIX)\
				GH_RETRIEVE_AND_FILTER_TERRAIN_VARIANT_EXPLICIT(WORLD_MATRIX, Out.GH_TerrainVariantIndex);

		#define GH_RETRIEVE_AND_FILTER_TERRAIN_VARIANT_STANDARD\
				GH_RETRIEVE_AND_FILTER_TERRAIN_VARIANT_STANDARD_EXPLICIT(Out.GH_TerrainVariantIndex)
	]]
}
