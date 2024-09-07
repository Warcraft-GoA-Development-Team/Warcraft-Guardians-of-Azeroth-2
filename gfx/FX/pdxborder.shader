Includes = {
	"cw/camera.fxh"
	"jomini/jomini_flat_border.fxh"
	"jomini/jomini_fog.fxh"
	"jomini/jomini_fog_of_war.fxh"
	"jomini/jomini_lighting.fxh"
	"standardfuncsgfx.fxh"
	# MOD(WC)
	"cw/pdxterrain.fxh"
	"WC_map.fxh"
	# END MOD
}

VertexStruct VS_OUTPUT_PDX_BORDER
{
	float4 Position : PDX_POSITION;
	float3 WorldSpacePos : TEXCOORD0;
	float2 UV : TEXCOORD1;
    float4 ShadowProj		: TEXCOORD2;
};


VertexShader =
{
	MainCode VertexShader
	{
		Input = "VS_INPUT_PDX_BORDER"
		Output = "VS_OUTPUT_PDX_BORDER"
		Code
		[[			
			PDX_MAIN
			{
				VS_OUTPUT_PDX_BORDER Out;
				
				float3 position = Input.Position;
				position.y = lerp( position.y, FlatMapHeight, FlatMapLerp );
				position.y += _HeightOffset;
				
				Out.WorldSpacePos = position;
				Out.Position = FixProjectionAndMul( ViewProjectionMatrix, float4( position, 1.0 ) );
				Out.UV = Input.UV;

				Out.ShadowProj = mul( ShadowMapTextureMatrix, float4( Out.WorldSpacePos, 1.0 ) );

				return Out;
			}
		]]
	}
}


PixelShader =
{	
	TextureSampler BorderTexture
	{
		Index = 0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
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

	MainCode PixelShader
	{
		Input = "VS_OUTPUT_PDX_BORDER"
		Output = "PDX_COLOR"
		Code
		[[			
			PDX_MAIN
			{
				float4 Diffuse = PdxTex2D( BorderTexture, Input.UV );

				Diffuse.rgb = ApplyFogOfWar( Diffuse.rgb, Input.WorldSpacePos, FogOfWarAlpha );
				Diffuse.rgb = ApplyDistanceFog( Diffuse.rgb, Input.WorldSpacePos );
				Diffuse.a *= _Alpha;

				// Apply shadows, only if we're fully in flat-map mode
 				if ( HasFlatMapLightingEnabled == 1 && FlatMapLerp > 0.0 )
				{
					float ShadowTerm = CalculateShadow( Input.ShadowProj, ShadowMap );
					SMaterialProperties MaterialProps = GetMaterialProperties( Diffuse.rgb, float3( 0.0, 1.0, 0.0 ), 1.0, 0.0, 0.0 );
					SLightingProperties LightingProps = GetSunLightingProperties( Input.WorldSpacePos, ShadowTerm );
					Diffuse.rgb = CalculateSunLighting( MaterialProps, LightingProps, EnvironmentMap );
				}
				// MOD(WC)
                float2 ColorMapCoords = Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1;
                Diffuse.a = WC_GetTerraIncognitaAlpha(float2( ColorMapCoords.x, 1.0 - ColorMapCoords.y ), Diffuse);
				// END MOD

				return Diffuse;
			}
		]]
	}
	
	MainCode PixelShaderWar
	{
		Input = "VS_OUTPUT_PDX_BORDER"
		Output = "PDX_COLOR"
		Code
		[[			
			PDX_MAIN
			{
				float4 Diffuse = PdxTex2D( BorderTexture, Input.UV );

				float vPulseFactor = saturate( smoothstep( 0.0f, 1.0f, 0.4f + sin( GlobalTime * 2.5f ) * 0.25f ) );
				Diffuse.rgb = saturate( Diffuse.rgb * vPulseFactor );
				
				Diffuse.rgb = ApplyFogOfWar( Diffuse.rgb, Input.WorldSpacePos, FogOfWarAlpha );
				Diffuse.rgb = ApplyDistanceFog( Diffuse.rgb, Input.WorldSpacePos );
				Diffuse.a *= _Alpha;

				// Apply shadows, only if we're fully in flat-map mode
 				if ( HasFlatMapLightingEnabled == 1 && FlatMapLerp > 0.0 )
				{
					float ShadowTerm = CalculateShadow( Input.ShadowProj, ShadowMap );
					SMaterialProperties MaterialProps = GetMaterialProperties( Diffuse.rgb, float3( 0.0, 1.0, 0.0 ), 1.0, 0.0, 0.0 );
					SLightingProperties LightingProps = GetSunLightingProperties( Input.WorldSpacePos, ShadowTerm );
					Diffuse.rgb = CalculateSunLighting( MaterialProps, LightingProps, EnvironmentMap );
				}
				// MOD(WC)
                float2 ColorMapCoords = Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1;
                Diffuse.a = WC_GetTerraIncognitaAlpha(float2( ColorMapCoords.x, 1.0 - ColorMapCoords.y ), Diffuse);
				// END MOD

				return Diffuse;
			}
		]]
	}

	MainCode PixelShaderStruggle
	{
		Input = "VS_OUTPUT_PDX_BORDER"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				float4 Diffuse = PdxTex2D( BorderTexture, Input.UV );

				// _UserId is 1 if struggle is highlighted and 0 if not
				float Highlight = float( _UserId );

				float lowColorMult = 0.3f;
				float colorMult = lowColorMult + ( ( 1.0f - lowColorMult ) * Highlight );

				Diffuse.rgb = saturate( Diffuse.rgb * colorMult );

				Diffuse.rgb = ApplyFogOfWar( Diffuse.rgb, Input.WorldSpacePos, FogOfWarAlpha );
				Diffuse.rgb = ApplyDistanceFog( Diffuse.rgb, Input.WorldSpacePos );
				Diffuse.a *= _Alpha;

				// Apply shadows, only if we're fully in flat-map mode
 				if ( HasFlatMapLightingEnabled == 1 && FlatMapLerp > 0.0 )
				{
					float ShadowTerm = CalculateShadow( Input.ShadowProj, ShadowMap );
					SMaterialProperties MaterialProps = GetMaterialProperties( Diffuse.rgb, float3( 0.0, 1.0, 0.0 ), 1.0, 0.0, 0.0 );
					SLightingProperties LightingProps = GetSunLightingProperties( Input.WorldSpacePos, ShadowTerm );
					Diffuse.rgb = CalculateSunLighting( MaterialProps, LightingProps, EnvironmentMap );
				}
				// MOD(WC)
                float2 ColorMapCoords = Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1;
                Diffuse.a = WC_GetTerraIncognitaAlpha(float2( ColorMapCoords.x, 1.0 - ColorMapCoords.y ), Diffuse);
				// END MOD

				return Diffuse;
			}
		]]
	}
}

BlendState BlendState
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
	WriteMask = "RED|GREEN|BLUE"
}

RasterizerState RasterizerState
{
	#DepthBias = -50
	DepthBias = -10000
	SlopeScaleDepthBias = -2
}

DepthStencilState DepthStencilState
{
	DepthEnable = no
	StencilEnable = yes
	FrontStencilFunc = not_equal
	StencilRef = 1
}


Effect PdxBorder
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"
}

Effect PdxBorderWar
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderWar"
}

Effect PdxBorderStruggle
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderStruggle"
}
