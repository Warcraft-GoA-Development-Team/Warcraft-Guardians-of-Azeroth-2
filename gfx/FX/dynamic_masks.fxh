Includes = {
    "cw/utility.fxh"
	"standardfuncsgfx.fxh"
    # MOD(godherja)
    "gh_dynamic_masks_params.fxh"
    # END MOD
}

#ifndef WINTER_COMBINED_TEXTURE
TextureSampler SnowDiffuseMap
{
	Index = 9
	MagFilter = "Linear"
	MinFilter = "Linear"
	MipFilter = "Linear"
	SampleModeU = "Wrap"
	SampleModeV = "Wrap"
	File = "gfx/map/terrain/snow_diffuse.dds"
    sRGB = yes
}
#endif
TextureSampler WinterTexture
{
	Ref = WinterTexture
	MagFilter = "Linear"
	MinFilter = "Linear"
	MipFilter = "Linear"
	SampleModeU = "Wrap"
	SampleModeV = "Wrap"
}

# MOD(godherja)
# We need to make this code available to vertex shader modifications in cw/fullscreen_vertexshader.fxh .
#PixelShader =
#{
# END MOD
    Code
    [[
        // MOD(godherja)
        #ifdef PIXEL_SHADER
            #define GH_SAMPLE_WINTER_TEXTURE PdxTex2D
        #else
            // Must explicitly specify LOD when sampling from HLSL vertex shaders.
            #define GH_SAMPLE_WINTER_TEXTURE PdxTex2DLod0
        #endif // PIXEL_SHADER
        // END MOD

#ifndef WINTER_COMBINED_TEXTURE
        float4 GetSnowDiffuseValue( in float2 Coordinate )
        {
            return PdxTex2D( SnowDiffuseMap, Coordinate );
        }
        float GetWinterSeverityValue( in float2 Coordinate )
        {
            // MOD(godherja)
            //return float4( PdxTex2D( WinterTexture, Coordinate ) ).r;
            return float4(GH_SAMPLE_WINTER_TEXTURE(WinterTexture, Coordinate)).r;
            // END MOD
        }
#else
        // The WinterTexture combines the two winter textures, to save one sampler (relevant on macOS with OpenGL):
        // - the winter severity value is in blue, this is what WinterTexture is without this define
        // - SnowDiffuseMap is in red, green, and alpha. We take its blue value from green, because we assume they are basically the same.
        // The texture isn't marked as sRGB, so we undo the double gamma correction for the diffuse value.
        float4 GetSnowDiffuseValue( in float2 Coordinate )
        {
            return ToLinear( PdxTex2D( WinterTexture, Coordinate ).rgga );
        }
        float GetWinterSeverityValue( in float2 Coordinate )
        {
            // MOD(godherja)
            //return float4( PdxTex2D( WinterTexture, Coordinate ) ).b;
            return float4(GH_SAMPLE_WINTER_TEXTURE(WinterTexture, Coordinate)).b;
            // END MOD
        }
#endif

        // MOD(godherja)
        float GH_GetAdjustedWinterSeverityValueImpl(float2 Coordinate, int TerrainVariantIndex)
        {
            float ForcedSeverityValue = 0.0f;
            if (GH_TryGetForcedWinterSeverityForTerrainVariant(TerrainVariantIndex, ForcedSeverityValue))
                return ForcedSeverityValue;

            return GetWinterSeverityValue(Coordinate);
        }

        float GH_GetAdjustedWinterSeverityValue(float2 Coordinate, int TerrainVariantIndex, int AdjacentTerrainVariantIndex, float AdjacentBlendAmount)
        {
            return lerp(
                GH_GetAdjustedWinterSeverityValueImpl(Coordinate, TerrainVariantIndex),
                GH_GetAdjustedWinterSeverityValueImpl(Coordinate, AdjacentTerrainVariantIndex),
                AdjacentBlendAmount
            );
        }
        // END MOD

        // MOD(godherja)
        //float3 ApplySnowDiffuse( in float3 TerrainColor, in float3 Normal, in float2 Coordinate )
        float3 ApplySnowDiffuse( in float3 TerrainColor, in float3 Normal, in float2 Coordinate, in int TerrainVariantIndex, in int AdjacentTerrainVariantIndex, in float AdjacentBlendAmount )
        // END MOD
        {
            float SnowScale = 150;
            float SnowScaleLarge = 0.0;
            float SnowScaleMedium = SnowScale;
            float SnowScaleSmall = SnowScale * 0.32345;

            float2 MapDimensions = float2( 2, 1 );

            float2 SnowUVLarge = Coordinate * MapDimensions * SnowScaleLarge;
            float2 SnowUVMedium = Coordinate * MapDimensions * SnowScaleMedium;
            float2 SnowUVSmall = Coordinate * MapDimensions *SnowScaleSmall;

            float4 SnowDiffuseMedium = GetSnowDiffuseValue( SnowUVMedium );
            float SnowDiffuseLarge = GetSnowDiffuseValue( SnowUVLarge ).a;
            float SnowDiffuseSmall = GetSnowDiffuseValue( SnowUVSmall ).a;

            // MOD(godherja)
            //float SnowMask = GetWinterSeverityValue( Coordinate ) * 0.6;
            float SnowMask = GH_GetAdjustedWinterSeverityValue(Coordinate, TerrainVariantIndex, AdjacentTerrainVariantIndex, AdjacentBlendAmount);
            // END MOD

            float SnowAlpha = 0;
            SnowAlpha = Overlay( SnowDiffuseLarge, SnowDiffuseMedium.a );
            SnowAlpha = Overlay( SnowAlpha, SnowDiffuseSmall );
            SnowAlpha = ToLinear( SnowAlpha );

            float GradientWidth = 0.3;
            float GradientWidthHalf = GradientWidth * 0.5;

            SnowAlpha = RemapClamped( SnowAlpha, 0, 1, GradientWidthHalf, 1 - GradientWidthHalf );
            SnowAlpha = clamp( SnowAlpha, 0, 1 );

            SnowMask = LevelsScan( SnowAlpha, 1 - SnowMask, GradientWidth );

            SnowMask *= clamp( Normal.g * Normal.g, 0, 1 );
            return lerp( TerrainColor, SnowDiffuseMedium.rgb, SnowMask );
        }

        // MOD(godherja)
        //float3 ApplySnowDiffuse( in float3 TerrainColor, in float3 Normal, in float2 Coordinate, out float SnowMask )
        float3 ApplySnowDiffuse( in float3 TerrainColor, in float3 Normal, in float2 Coordinate, out float SnowMask, in int TerrainVariantIndex )
        // END MOD
        {
            float SnowScale = 150;
            float SnowScaleLarge = 0.0;
            float SnowScaleMedium = SnowScale;
            float SnowScaleSmall = SnowScale * 0.32345;

            float2 MapDimensions = float2( 2, 1 );

            float2 SnowUVLarge = Coordinate * MapDimensions * SnowScaleLarge;
            float2 SnowUVMedium = Coordinate * MapDimensions * SnowScaleMedium;
            float2 SnowUVSmall = Coordinate * MapDimensions * SnowScaleSmall;

            float4 SnowDiffuseMedium = GetSnowDiffuseValue( SnowUVMedium );
            float SnowDiffuseLarge = GetSnowDiffuseValue( SnowUVLarge ).a;
            float SnowDiffuseSmall = GetSnowDiffuseValue( SnowUVSmall ).a;

            // MOD(godherja)
            //SnowMask = GetWinterSeverityValue( Coordinate ) * 0.6;
            SnowMask = GH_GetAdjustedWinterSeverityValue(Coordinate, TerrainVariantIndex, 0, 0.0f);
            // END MOD

            float SnowAlpha = 0;
            SnowAlpha = Overlay( SnowDiffuseLarge, SnowDiffuseMedium.a );
            SnowAlpha = Overlay( SnowAlpha, SnowDiffuseSmall );
            SnowAlpha = ToLinear( SnowAlpha );

            float GradientWidth = 0.3;
            float GradientWidthHalf = GradientWidth * 0.5;

            SnowAlpha = RemapClamped( SnowAlpha, 0, 1, GradientWidthHalf, 1 - GradientWidthHalf );
            SnowAlpha = clamp( SnowAlpha, 0, 1 );

            SnowMask = LevelsScan( SnowAlpha, 1 - SnowMask, GradientWidth );

            SnowMask *= clamp( Normal.g * Normal.g, 0, 1 );
            return lerp( TerrainColor, SnowDiffuseMedium.rgb, SnowMask );
        }

        // MOD(godherja)
        //float3 ApplyDynamicMasksDiffuse( in float3 TerrainColor, in float3 Normal, in float2 Coordinate )
        float3 ApplyDynamicMasksDiffuse( in float3 TerrainColor, in float3 Normal, in float2 Coordinate, in int TerrainVariantIndex, in int AdjacentTerrainVariantIndex = 0, in float AdjacentBlendAmount = 0.0f )
        // END MOD
        {
            TerrainColor = ApplySnowDiffuse( TerrainColor, Normal, Coordinate, TerrainVariantIndex, AdjacentTerrainVariantIndex, AdjacentBlendAmount );

            return TerrainColor;
        }

        // MOD(godherja)
        //float3 ApplyDynamicMasksDiffuse( in float3 TerrainColor, in float3 Normal, in float2 Coordinate, inout float Snow )
        float3 ApplyDynamicMasksDiffuse( in float3 TerrainColor, in float3 Normal, in float2 Coordinate, inout float Snow, in int TerrainVariantIndex )
        // END MOD
        {
            TerrainColor = ApplySnowDiffuse( TerrainColor, Normal, Coordinate, Snow, TerrainVariantIndex );

            return TerrainColor;
        }
    ]]
# MOD(godherja)
#}
# END MOD
