Includes = {
	"jomini/countrynames.fxh"
	# MOD(WC)
	#"jomini/jomini_fog.fxh"
	"wc_jomini_fog.fxh"
	# END MOD
	"jomini/jomini_fog_of_war.fxh"
	"standardfuncsgfx.fxh"
	"cw/lighting.fxh"
	"jomini/jomini_lighting.fxh"
	# MOD(WC)
	"cw/pdxterrain.fxh"
	"wc_map.fxh"
	# END MOD
}

VertexShader =
{
	MainCode MapNameVertexShader
	{
		Input = "VS_INPUT_MAPNAME"
		Output = "VS_OUTPUT_MAPNAME"
		Code
		[[
			PDX_MAIN
			{
				VS_OUTPUT_MAPNAME Out = MapNameVertexShader( Input, FlatMapHeight, FlatMapLerp );
				return Out;
			}
		]]
	}
}

PixelShader =
{
	TextureSampler FontAtlas
	{
		Ref = PdxTexture0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
	}
	TextureSampler FogOfWarAlpha
	{
		Ref = JominiFogOfWar
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler ShadowMap
	{
		Ref = PdxShadowmap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		CompareFunction = less_equal
		SamplerType = "Compare"
	}
	TextureSampler EnvironmentMap
	{
		Ref = JominiEnvironmentMap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		Type = "Cube"
	}

	MainCode MapNamePixelShader
	{
		Input = "VS_OUTPUT_MAPNAME"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
			float4 TextColor = float4( 0, 0, 0, 1 );
			float4 OutlineColor = float4( 1, 1, 1, 1 );

			float Sample = PdxTex2D( FontAtlas, Input.TexCoord ).r;
			
			float2 TextureCoordinate = Input.TexCoord * TextureSize;
			float Ratio = CalcTexelPixelRatio( TextureCoordinate );
			
			float Smoothing = 0.2f + Ratio * LodFactor;
			float Mid = 0.52f;

			float Factor = smoothstep( Mid - Smoothing, Mid, Sample );

			float4 MixedColor = lerp( OutlineColor, TextColor, Factor );

			// Set OutlineWidth to control outline width
			float OutlineWidth = 0.1;
			float OutlineSmoothing = OutlineWidth + Ratio * LodFactor * 0.4f;
			float OutlineFactor = smoothstep( Mid - OutlineSmoothing, Mid, Sample );
			MixedColor.a *= OutlineFactor;
			
			MixedColor.a *= Transparency;

			MixedColor.rgb = ApplyFogOfWar( MixedColor.rgb, Input.WorldSpacePos, FogOfWarAlpha );
			MixedColor.rgb = ApplyDistanceFog( MixedColor.rgb, Input.WorldSpacePos );

			// Apply lighting and shadows, only if we're fully in flat-map mode
			if ( HasFlatMapLightingEnabled == 1 && FlatMapLerp > 0.0 )
			{
				float ShadowTerm = CalculateShadow( Input.ShadowProj, ShadowMap );
				SMaterialProperties NamesMaterialProps = GetMaterialProperties( MixedColor.rgb, float3( 0.0, 1.0, 0.0 ), 1.0, 0.0, 0.0 );
				SLightingProperties NamesLightingProps = GetSunLightingProperties( Input.WorldSpacePos, ShadowTerm );
				MixedColor.rgb = CalculateSunLighting( NamesMaterialProps, NamesLightingProps, EnvironmentMap );
			}
            // MOD(WC)
            float2 ColorMapCoords = Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1;
            MixedColor.a = WC_GetTerraIncognitaAlpha(float2( ColorMapCoords.x, 1.0 - ColorMapCoords.y ), MixedColor);
            // END MOD
			
			return MixedColor;
			}
		]]
	}
}


BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "src_alpha"
	DestBlend = "inv_src_alpha"
	WriteMask = "RED|GREEN|BLUE"
}

RasterizerState RasterizerState
{
	frontccw = yes
}

# This makes the man names appear 'under' map objects, while actually being above them
# Doesn't use the normal depthbuffer, but instead a specific stencil-buffer written into by other objects.
DepthStencilState DepthStencilStateFromStencil
{
	DepthEnable = no
	StencilEnable = yes
	FrontStencilFunc = not_equal
	StencilRef = 1
}

Effect mapname
{
	VertexShader = "MapNameVertexShader"
	PixelShader = "MapNamePixelShader"
	DepthStencilState = DepthStencilStateFromStencil

	Defines = { "PDX_NAMES_SHADOW_PROJ" }
}
