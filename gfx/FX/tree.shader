Includes = {
	"cw/pdxmesh.fxh"
	
	# MOD(godherja)
	"jomini/jomini_lighting.fxh"
	#"gh_jomini_lighting.fxh"
	# END MOD
	# MOD(godherja)
	"jomini/jomini_fog.fxh"
	#"gh_jomini_fog.fxh"
	"jomini/jomini_fog_of_war.fxh"
	#"gh_atmospheric.fxh"
	# END MOD
	"jomini/jomini_mapobject.fxh"
	"bordercolor.fxh"
	"dynamic_masks.fxh"
	"legend.fxh"
	"disease.fxh"
	# MOD(godherja)
	"jomini/portrait_user_data.fxh"
	"gh_portrait_constants.fxh"
	"gh_portrait_decals_shared.fxh"
	"gh_dynamic_terrain.fxh"
	"gh_tree.fxh"
	# END MOD
}

PixelShader = 
{
	TextureSampler DiffuseMap
	{
		Index = 0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler PropertiesMap
	{
		Index = 1
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler NormalMap
	{
		Index = 2
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}	
	TextureSampler TintMap
	{
		Index = 3
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
	}
	TextureSampler ShadowTexture
	{
		Ref = PdxShadowmap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		CompareFunction = less_equal
		SamplerType = "Compare"
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
	#TextureSampler TerrainColorMapTexture
	#{
	#	Ref = PdxTerrainColorMap
	#	MagFilter = "Linear"
	#	MinFilter = "Linear"
	#	MipFilter = "Linear"
	#	SampleModeU = "Clamp"
	#	SampleModeV = "Clamp"
	#}
}

VertexStruct VS_OUTPUT_TREE
{
	float4 	Position 		: PDX_POSITION;
	float3 	Normal			: TEXCOORD0;
	float3 	Tangent			: TEXCOORD1;
	float3 	Bitangent		: TEXCOORD2;
	float2 	UV0				: TEXCOORD3;
	float3 	WorldSpacePos	: TEXCOORD5;
	uint	InstanceIndex	: TEXCOORD6;
	float3	Scale_Seed_Yaw	: TEXCOORD7;
	# MOD(godherja)
	int GH_TerrainVariantIndex : TEXCOORD8;
	# END MOD
}

VertexShader = 
{	
	Code
	[[	
		VS_OUTPUT_TREE ConvertOutput( VS_OUTPUT_PDXMESH In )
		{
			VS_OUTPUT_TREE Out;
			Out.Position = In.Position;
			Out.Normal = In.Normal;
			Out.Tangent = In.Tangent;
			Out.Bitangent = In.Bitangent;
			Out.UV0 = In.UV0;
			Out.WorldSpacePos = In.WorldSpacePos;
			return Out;
		}

		void FinalizeOutput( inout VS_OUTPUT_TREE Out, in uint InstanceIndex, in float4x4 WorldMatrix )
		{
			Out.InstanceIndex = InstanceIndex;
			Out.Scale_Seed_Yaw.x = 1.0f;
			Out.Scale_Seed_Yaw.y = CalcRandom( float2( GetMatrixData( WorldMatrix, 0, 2 ), GetMatrixData( WorldMatrix, 2, 2 ) ) );
			Out.Scale_Seed_Yaw.z = frac(Out.Scale_Seed_Yaw.y) * TWO_PI; //We could calculate a correct Yaw from the WorldMatrix, we could also just fake it!
		}
	]]
	MainCode VS_standard
	{	
		Input = "VS_INPUT_PDXMESHSTANDARD"
		Output = "VS_OUTPUT_TREE"
		Code
		[[			
			PDX_MAIN
			{				
				VS_OUTPUT_TREE Out = ConvertOutput( PdxMeshVertexShaderStandard( Input ) );
				// MOD(godherja)
				float4x4 GH_WorldMatrix = PdxMeshGetWorldMatrix(Input.InstanceIndices.y);
				GH_RETRIEVE_AND_FILTER_TERRAIN_VARIANT(GH_WorldMatrix);

				//FinalizeOutput( Out, Input.InstanceIndices.y, PdxMeshGetWorldMatrix( Input.InstanceIndices.y ) );
				FinalizeOutput( Out, Input.InstanceIndices.y, GH_WorldMatrix );
				// END MOD
				return Out;
			}
		]]
	}
	MainCode VS_mapobject
	{	
		Input = "VS_INPUT_PDXMESH_MAPOBJECT"
		Output = "VS_OUTPUT_TREE"
		Code
		[[			
			PDX_MAIN
			{				
				float4x4 WorldMatrix = UnpackAndGetMapObjectWorldMatrix( Input.InstanceIndex24_Opacity8 );
				VS_OUTPUT_TREE Out = ConvertOutput( PdxMeshVertexShader( PdxMeshConvertInput( Input ), Input.InstanceIndex24_Opacity8, WorldMatrix ) );
				// MOD(godherja)
				GH_RETRIEVE_AND_FILTER_TERRAIN_VARIANT(WorldMatrix);
				// END MOD
				FinalizeOutput( Out, Input.InstanceIndex24_Opacity8, WorldMatrix );
				return Out;
			}
		]]
	}
}

PixelShader = 
{
	
	Code
	[[
		float ApplyOpacity( in float Alpha, in float2 NoiseCoordinate, in uint InstanceIndex )
		{
			#ifdef JOMINI_MAP_OBJECT
				float Opacity = UnpackAndGetMapObjectOpacity( InstanceIndex );
			#else
				float Opacity = PdxMeshGetOpacity( InstanceIndex );
			#endif
			return PdxMeshApplyOpacity( Alpha, NoiseCoordinate, Opacity );
		}

		// MOD(godherja)
		//float3 CalculateLighting( in VS_OUTPUT_TREE Input, in float4 Diffuse, in float3 NormalSample, in float4 Properties, in float SnowHighlight )
		float3 CalculateLighting( in VS_OUTPUT_TREE Input, in float4 Diffuse, in float3 NormalSample, in float4 Properties, in float SnowHighlight, in int TerrainVariantIndex )
		// END MOD
		{
			float3 InNormal = normalize( Input.Normal );
			float3x3 TBN = Create3x3( normalize( Input.Tangent ), normalize( Input.Bitangent ), InNormal );
			float3 Normal = normalize( mul( NormalSample, TBN ) );
			
			float3 WorldSpacePos = Input.WorldSpacePos;
		
			float3 BorderColor;
			float BorderPreLightingBlend;
			float BorderPostLightingBlend;
			GetBorderColorAndBlendGame( WorldSpacePos.xz, Diffuse.rgb, BorderColor, BorderPreLightingBlend, BorderPostLightingBlend );
			Diffuse.rgb = lerp( Diffuse.rgb, BorderColor, BorderPreLightingBlend );
				
			ApplyHighlightColor( Diffuse.rgb, Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1 );
			CompensateWhiteHighlightColor( Diffuse.rgb, Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1, SnowHighlight );
			
			SMaterialProperties MaterialProps = GetMaterialProperties( Diffuse.rgb, Normal, Properties.a, Properties.g, Properties.b );
			SLightingProperties LightingProps = GetSunLightingProperties( WorldSpacePos, ShadowTexture );
	
			float3 Color = CalculateSunLighting( MaterialProps, LightingProps, EnvironmentMap );
			ApplyLegendDiffuse( Color, WorldSpacePos.xz * WorldSpaceToTerrain0To1 );
			ApplyDiseaseDiffuse( Color, WorldSpacePos.xz * WorldSpaceToTerrain0To1 );
			Color = ApplyFogOfWar( Color, WorldSpacePos, FogOfWarAlpha );
			Color = ApplyDistanceFog( Color, WorldSpacePos );
			
			Color.rgb = lerp( Color.rgb, BorderColor, BorderPostLightingBlend );

			DebugReturn( Color, MaterialProps, LightingProps, EnvironmentMap );
			return Color;
		}
	]]
	
	MainCode PS_leaf
	{
		Input = "VS_OUTPUT_TREE"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				float4 Diffuse = PdxTex2D( DiffuseMap, Input.UV0 );
				float3 NormalSample = UnpackRRxGNormal( PdxTex2D( NormalMap, Input.UV0 ) );
				float3x3 TBN = Create3x3( normalize( Input.Tangent ), normalize( Input.Bitangent ), normalize( Input.Normal ) );
				float3 Normal = normalize( mul( NormalSample, TBN ) );

				float4 Properties = PdxTex2D( PropertiesMap, Input.UV0 );
				
				//Opacity
				Diffuse.a = ApplyOpacity( Diffuse.a, Input.Position.xy, Input.InstanceIndex );
				clip( Diffuse.a - 0.4f );
				
				//Tint
				float3 Tint = PdxTex2DLod0( TintMap, float2( Input.Scale_Seed_Yaw.y, 0.5f ) ).rgb;
				Tint = GetOverlay( Diffuse.rgb, Tint, 1.0 );
				
				Diffuse.rgb = lerp( Diffuse.rgb, Tint, PdxTex2D( NormalMap, Input.UV0 ).b );

				
				
				//Colormap
				float SnowHighlight = 0.0f;
				float2 ColorMapCoords = Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1;
				// MOD(godherja)
				//Diffuse.rgb = ApplyDynamicMasksDiffuse( Diffuse.rgb, Normal, ColorMapCoords, SnowHighlight );
				Diffuse.rgb = ApplyDynamicMasksDiffuse( Diffuse.rgb, Normal, ColorMapCoords, SnowHighlight, Input.GH_TerrainVariantIndex );
				// END MOD
#if defined( PDX_OSX ) && defined( PDX_OPENGL )
				// The amount of texture samplers is limited on Mac, so we don't read the data for the ColorMap directly
				// from a texture. Instead we assign a default gray value here. This is also done for the terrain (on Mac)
				// to make sure we have the same color variation for both the terrain and the trees
				float3 ColorMap = float3( vec3( 0.5 ) );
#else
				float3 ColorMap = PdxTex2D( ColorTexture, float2( ColorMapCoords.x, 1.0 - ColorMapCoords.y ) ).rgb;
#endif
				Diffuse.rgb = GetOverlay( Diffuse.rgb, ColorMap, 1.0 );

				// MOD(godherja)
				//float3 Color = CalculateLighting( Input, Diffuse, NormalSample, Properties, SnowHighlight );
				float3 Color = CalculateLighting( Input, Diffuse, NormalSample, Properties, SnowHighlight, Input.GH_TerrainVariantIndex );
				// END MOD
				
				return float4( Color, Diffuse.a );								
			}
		]]
	}

	MainCode PS_shadow
	{
		Input = "VS_OUTPUT_TREE"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				float2 uv = Input.UV0;
				float4 Color = PdxTex2D( DiffuseMap, uv );

				Color.a = ApplyOpacity( Color.a, Input.Position.xy, Input.InstanceIndex );
				clip( Color.a - 0.5f );
				
				return vec4(1);
			}
		]]
	}
}

BlendState BlendState
{
	BlendEnable = no	
	alphatocoverage = yes 
}
BlendState BlendStateShadow
{
	BlendEnable = no	
	alphatocoverage = no 
}
BlendState BlendStateLod
{
	BlendEnable = no	
	alphatocoverage = no 
}

RasterizerState ShadowRasterizerState
{
	DepthBias = 40000
	SlopeScaleDepthBias = 2
}

#Uncomment this if you want trees to render on top of borders for example
#DepthStencilState DepthStencilState
#{
#	StencilEnable = yes
#	FrontStencilPassOp = replace
#	StencilRef = 1
#}






Effect tree
{
	VertexShader = VS_standard
	PixelShader = PS_leaf
	# MOD(godherja)
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_VANILLA_TREE" }
	# END MOD
}
Effect treeShadow
{
	VertexShader = VertexPdxMeshStandardShadow
	PixelShader = PixelPdxMeshAlphaBlendShadow
	BlendState = BlendStateShadow
	RasterizerState = ShadowRasterizerState
	# MOD(godherja)
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_VANILLA_TREE" }
	# END MOD
}

#Map object shaders
Effect tree_mapobject
{
	VertexShader = VS_mapobject
	PixelShader = PS_leaf
	# MOD(godherja)
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_VANILLA_TREE" }
	# END MOD
}

Effect treeShadow_mapobject
{
	VertexShader = VS_jomini_mapobject_shadow
	PixelShader = PS_jomini_mapobject_shadow_alphablend
	BlendState = BlendStateShadow
	RasterizerState = ShadowRasterizerState
	# MOD(godherja)
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_VANILLA_TREE" }
	# END MOD
}

Effect tree_lod
{
	VertexShader = VS_standard
	PixelShader = PS_leaf
	BlendState = BlendStateLod
	# MOD(godherja)
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_VANILLA_TREE" }
	# END MOD
}
Effect tree_lodShadow
{
	VertexShader = VertexPdxMeshStandardShadow
	PixelShader = PixelPdxMeshAlphaBlendShadow
	BlendState = BlendStateShadow
	RasterizerState = ShadowRasterizerState
	# MOD(godherja)
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_VANILLA_TREE" }
	# END MOD
}

#Map object shaders
Effect tree_lod_mapobject
{
	VertexShader = VS_mapobject
	PixelShader = PS_leaf
	BlendState = BlendStateLod
	# MOD(godherja)
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_VANILLA_TREE" }
	# END MOD
}

Effect tree_lodShadow_mapobject
{
	VertexShader = VS_jomini_mapobject_shadow
	PixelShader = PS_jomini_mapobject_shadow_alphablend
	BlendState = BlendStateShadow
	RasterizerState = ShadowRasterizerState
	# MOD(godherja)
	Defines = { "GH_ENABLE_DYNAMIC_TERRAIN" "GH_VANILLA_TREE" }
	# END MOD
}
