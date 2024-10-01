# THIS IS A GENERATED FILE.
#
# Source template:
# ../GHTemplates/gfx/FX/gh_dynamic_terrain_textures.fxh.jinja
#
# Please avoid manually editing this file: your changes WILL be overwritten when it gets regenerated.
# Instead, edit the source template and/or variables, then run render_templates.bat .
PixelShader =
{
	#
	# Textures
	#

	# Terrain variant textures start at 1 because 0 refers to default (base map) terrain
	# i.e. to DetailIndexTexture and DetailMaskTexture in pdxterrain.fxh .
	TextureSampler GH_TerrainVariantIndexTexture1
	{
		Index = 17
		MagFilter = "Point"
		MinFilter = "Point"
		MipFilter = "Point"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		File = "gfx/map/terrain/GH_detail_index_desert.png"
	}

	TextureSampler GH_TerrainVariantMaskTexture1
	{
		Index = 18
		MagFilter = "Point"
		MinFilter = "Point"
		MipFilter = "Point"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		File = "gfx/map/terrain/GH_detail_intensity_desert.png"
	}
	
	TextureSampler GH_TerrainVariantIndexTexture2
	{
		Index = 19
		MagFilter = "Point"
		MinFilter = "Point"
		MipFilter = "Point"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		File = "gfx/map/terrain/GH_detail_index_arctic.png"
	}

	TextureSampler GH_TerrainVariantMaskTexture2
	{
		Index = 20
		MagFilter = "Point"
		MinFilter = "Point"
		MipFilter = "Point"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		File = "gfx/map/terrain/GH_detail_intensity_arctic.png"
	}
	

	Code [[
		//
		// Macros
		//

		#define GH_MACRO_FOR_EACH_TERRAIN_VARIANT_INDEX_EXCEPT_ZERO(MACRO)\
			MACRO(1)\
			MACRO(2) // GH_DYNAMIC_TERRAIN_VARIANTS_COUNT - 1

		#define GH_MACRO_FOR_EACH_TERRAIN_VARIANT_INDEX(MACRO)\
			MACRO(0)\
			GH_MACRO_FOR_EACH_TERRAIN_VARIANT_INDEX_EXCEPT_ZERO(MACRO)

		//
		// Interface
		//

		float4 GH_TerrainVariantIndexPdxTex2D(int TerrainVariantIndex, PdxTextureSampler2D DefaultTexture, float2 UV)
		{
			#define GH_CASE_TERRAIN_VARIANT_INDEX_TEX_2D(INDEX) case INDEX: return PdxTex2D(GH_TerrainVariantIndexTexture##INDEX, UV);

			switch (TerrainVariantIndex)
			{
				default: return PdxTex2D(DefaultTexture, UV);
				GH_MACRO_FOR_EACH_TERRAIN_VARIANT_INDEX_EXCEPT_ZERO(GH_CASE_TERRAIN_VARIANT_INDEX_TEX_2D)
			}

			#undef GH_CASE_TERRAIN_VARIANT_INDEX_TEX_2D
		}

		float4 GH_TerrainVariantMaskPdxTex2D(int TerrainVariantIndex, PdxTextureSampler2D DefaultTexture, float2 UV)
		{
			#define GH_CASE_TERRAIN_VARIANT_MASK_TEX_2D(INDEX) case INDEX: return PdxTex2D(GH_TerrainVariantMaskTexture##INDEX, UV);

			switch (TerrainVariantIndex)
			{
				default: return PdxTex2D(DefaultTexture, UV);
				GH_MACRO_FOR_EACH_TERRAIN_VARIANT_INDEX_EXCEPT_ZERO(GH_CASE_TERRAIN_VARIANT_MASK_TEX_2D)
			}

			#undef GH_CASE_TERRAIN_VARIANT_MASK_TEX_2D
		}

		float4 GH_TerrainVariantIndexPdxTex2DLod0(int TerrainVariantIndex, PdxTextureSampler2D DefaultTexture, float2 UV)
		{
			#define GH_CASE_TERRAIN_VARIANT_INDEX_TEX_2D_LOD0(INDEX) case INDEX: return PdxTex2DLod0(GH_TerrainVariantIndexTexture##INDEX, UV);

			switch (TerrainVariantIndex)
			{
				default: return PdxTex2DLod0(DefaultTexture, UV);
				GH_MACRO_FOR_EACH_TERRAIN_VARIANT_INDEX_EXCEPT_ZERO(GH_CASE_TERRAIN_VARIANT_INDEX_TEX_2D_LOD0)
			}

			#undef GH_CASE_TERRAIN_VARIANT_INDEX_TEX_2D_LOD0
		}

		float4 GH_TerrainVariantMaskPdxTex2DLod0(int TerrainVariantIndex, PdxTextureSampler2D DefaultTexture, float2 UV)
		{
			#define GH_CASE_TERRAIN_VARIANT_MASK_TEX_2D_LOD0(INDEX) case INDEX: return PdxTex2DLod0(GH_TerrainVariantMaskTexture##INDEX, UV);

			switch (TerrainVariantIndex)
			{
				default: return PdxTex2DLod0(DefaultTexture, UV);
				GH_MACRO_FOR_EACH_TERRAIN_VARIANT_INDEX_EXCEPT_ZERO(GH_CASE_TERRAIN_VARIANT_MASK_TEX_2D_LOD0)
			}

			#undef GH_CASE_TERRAIN_VARIANT_MASK_TEX_2D_LOD0
		}
	]]
}