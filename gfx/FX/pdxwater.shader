Includes = {
	"cw/heightmap.fxh"
	"bordercolor.fxh"
	"jomini/jomini_water_default.fxh"
	"jomini/jomini_water_pdxmesh.fxh"
	"jomini/jomini_water.fxh"
	"jomini/jomini_fog_of_war.fxh"
	"jomini/jomini_mapobject.fxh"
	"standardfuncsgfx.fxh"
}

PixelShader =
{
	TextureSampler FogOfWarAlpha
	{
		Ref = JominiFogOfWar
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler FlatMapTexture
	{
		Ref = TerrainFlatMap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
	}
	
	MainCode PixelShader
	{
		Input = "VS_OUTPUT_WATER"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				float4 Water = CalcWater( Input )._Color;

				#ifdef WATER_COLOR_OVERLAY
					// Not enough texture slots, so use only secondary colors on water.
					#if defined( PDX_OSX ) && defined( PDX_OPENGL )
						ApplySecondaryColorGame( Water.rgb, float2( Input.UV01.x, 1.0f - Input.UV01.y ) );
					#else
						float3 BorderColor;
						float BorderPreLightingBlend;
						float BorderPostLightingBlend;
						GetProvinceOverlayAndBlend( Input.WorldSpacePos.xz, BorderColor, BorderPreLightingBlend, BorderPostLightingBlend );
						GetBorderColorAndBlendGame( Input.WorldSpacePos.xz, Water.rgb, BorderColor, BorderPreLightingBlend, BorderPostLightingBlend );

						// Don't draw too close to the shore to not duplicate the colors with stripes over the land.
						float AccurateHeight = GetHeight( Input.WorldSpacePos.xz );
						BorderPreLightingBlend *= 1.0f - Levels( max( AccurateHeight - ( _WaterHeight - 0.05f ), 0.0f ), 0.0f, 0.05f );

						Water.rgb = lerp( Water.rgb, BorderColor, BorderPreLightingBlend );
					#endif
				#endif
				
				Water.rgb = ApplyFogOfWarMultiSampled( Water.rgb, Input.WorldSpacePos, FogOfWarAlpha );
				Water.rgb = ApplyDistanceFog( Water.rgb, Input.WorldSpacePos );

				Water.rgb = FlatMapLerp > 0.0f ? lerp( Water.rgb, PdxTex2D( FlatMapTexture, Input.UV01 ).rgb, FlatMapLerp ) : Water.rgb;

				return Water;
			}
		]]
	}

	MainCode PixelShaderLowSpec
	{
		Input = "VS_OUTPUT_WATER"
		Output = "PDX_COLOR"
		Code
		[[			
			// low spec version of CalcWater
			float4 CalcWaterLowSpec( VS_OUTPUT_WATER Input, out float Depth )
			{
				float Height = GetHeightMultisample( Input.WorldSpacePos.xz, 0.65 );
				Depth = Input.WorldSpacePos.y - Height;
				
				float WaterFade = 1.0 - saturate( (_WaterFadeShoreMaskDepth - Depth) * _WaterFadeShoreMaskSharpness );
				float4 WaterColorAndSpec = PdxTex2D( WaterColorTexture, Input.UV01 );
				
				return float4(WaterColorAndSpec.xyz, WaterFade);
			}

			PDX_MAIN
			{
				float Depth;
				float4 Water = CalcWaterLowSpec( Input, Depth );

				#ifdef WATER_COLOR_OVERLAY
						ApplySecondaryColorGame( Water.rgb, float2( Input.UV01.x, 1.0f - Input.UV01.y ) );
				#endif
				
				Water.rgb = ApplyFogOfWarMultiSampled( Water.rgb, Input.WorldSpacePos, FogOfWarAlpha );
				Water.rgb = ApplyDistanceFog( Water.rgb, Input.WorldSpacePos );

				Water.rgb = FlatMapLerp > 0.0f ? lerp( Water.rgb, PdxTex2D( FlatMapTexture, Input.UV01 ).rgb, FlatMapLerp ) : Water.rgb;

				return Water;
			}
		]]
	}
}


Effect water
{
	VertexShader = "JominiWaterVertexShader"
	PixelShader = "PixelShader"

    # MOD(WC)
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" }
	# END MOD
}

Effect waterLowSpec
{
	VertexShader = "JominiWaterVertexShader"
	PixelShader = "PixelShaderLowSpec"

    # MOD(WC)
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" }
	# END MOD
}

Effect lake
{
	VertexShader = "VS_jomini_water_mesh"
	PixelShader = "PixelShader"

    # MOD(WC)
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" }
	# END MOD
}
Effect lake_mapobject
{
	VertexShader = "VS_jomini_water_mapobject"
	PixelShader = "PixelShader"

    # MOD(WC)
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" }
	# END MOD
}
