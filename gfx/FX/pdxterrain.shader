Includes = {
	"cw/pdxterrain.fxh"
	"cw/heightmap.fxh"
	"cw/shadow.fxh"
	"cw/utility.fxh"
	"cw/camera.fxh"
	# MOD(godherja)
	"jomini/jomini_lighting.fxh"
	"cw/pdxmesh_buffers.fxh"
	#"gh_jomini_lighting.fxh"
	# END MOD
	# MOD(godherja)
	"jomini/jomini_fog.fxh"
	#"gh_jomini_fog.fxh"
	"jomini/jomini_fog_of_war.fxh"
	# END MOD
	"jomini/jomini_water.fxh"
	"standardfuncsgfx.fxh"
	"bordercolor.fxh"
	# MOD(godherja)
	"lowspec.fxh"
	#"gh_lowspec.fxh"
	# END MOD
	"legend.fxh"
	"cw/lighting.fxh"
	"dynamic_masks.fxh"
	"disease.fxh"
	# MOD(godherja)
	"gh_dynamic_terrain.fxh"
	# END MOD
}

# MOD(godherja)
PixelShader =
{
	Code [[
		//
		// Constants
		//

		static const float GH_TERRAIN_COLOR_OVERLAY_BLEND_MULTIPLIER      = 1.0f;
		static const float GH_TERRAIN_COLOR_OVERLAY_SATURATION_MULTIPLIER = 1.0f;

		static const float GH_FLATMAP_COLOR_OVERLAY_BLEND_MULTIPLIER      = 1.0f;
		static const float GH_FLATMAP_COLOR_OVERLAY_SATURATION_MULTIPLIER = 1.0f;

		//
		// Service
		//

		float3 GH_ApplySaturationMultiplier(float3 ColorRGB, float SaturationMultiplier)
		{
			float3 ColorHSV = RGBtoHSV(ColorRGB);
			ColorHSV.y *= SaturationMultiplier;
			return HSVtoRGB(ColorHSV);
		}
	]]
}
# END MOD

VertexStruct VS_OUTPUT_PDX_TERRAIN
{
	float4 Position			: PDX_POSITION;
	float3 WorldSpacePos	: TEXCOORD1;
	float4 ShadowProj		: TEXCOORD2;
};

VertexStruct VS_OUTPUT_PDX_TERRAIN_LOW_SPEC
{
	float4 Position			: PDX_POSITION;
	float3 WorldSpacePos	: TEXCOORD1;
	float4 ShadowProj		: TEXCOORD2;
	float3 DetailDiffuse	: TEXCOORD3;
	float4 DetailMaterial	: TEXCOORD4;
	float3 ColorMap			: TEXCOORD5;		
	float3 FlatMap			: TEXCOORD6;
	float3 Normal			: TEXCOORD7;
};

# Limited JominiEnvironment data to get nicer transitions between the Flatmap lighting and Terrain lighting
# Only used in terrain shader while lerping between flatmap and terrain.
ConstantBuffer( FlatMapLerpEnvironment )
{
	float	FlatMapLerpCubemapIntensity;
	float3	FlatMapLerpSunDiffuse;
	float	FlatMapLerpSunIntensity;
	float4x4 FlatMapLerpCubemapYRotation;
};

VertexShader =
{
	TextureSampler DetailTextures
	{
		Ref = PdxTerrainTextures0
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		type = "2darray"
	}
	TextureSampler NormalTextures
	{
		Ref = PdxTerrainTextures1
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		type = "2darray"
	}
	TextureSampler MaterialTextures
	{
		Ref = PdxTerrainTextures2
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		type = "2darray"
	}
	TextureSampler DetailIndexTexture
	{
		Ref = PdxTerrainTextures3
		MagFilter = "Point"
		MinFilter = "Point"
		MipFilter = "Point"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
	}
	TextureSampler DetailMaskTexture
	{
		Ref = PdxTerrainTextures4
		MagFilter = "Point"
		MinFilter = "Point"
		MipFilter = "Point"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
	}
	TextureSampler ColorTexture
	{
		Ref = PdxTerrainColorMap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
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
	
	Code
	[[
		VS_OUTPUT_PDX_TERRAIN TerrainVertex( float2 WithinNodePos, float2 NodeOffset, float NodeScale, float2 LodDirection, float LodLerpFactor )
		{
			STerrainVertex Vertex = CalcTerrainVertex( WithinNodePos, NodeOffset, NodeScale, LodDirection, LodLerpFactor );

			#ifdef TERRAIN_FLAT_MAP_LERP
				Vertex.WorldSpacePos.y = lerp( Vertex.WorldSpacePos.y, FlatMapHeight, FlatMapLerp );
			#endif
			#ifdef TERRAIN_FLAT_MAP
				Vertex.WorldSpacePos.y = FlatMapHeight;
			#endif

			VS_OUTPUT_PDX_TERRAIN Out;
			Out.WorldSpacePos = Vertex.WorldSpacePos;

			Out.Position = FixProjectionAndMul( ViewProjectionMatrix, float4( Vertex.WorldSpacePos, 1.0 ) );
			Out.ShadowProj = mul( ShadowMapTextureMatrix, float4( Vertex.WorldSpacePos, 1.0 ) );

			return Out;
		}
		
		// Copies of the pixels shader CalcHeightBlendFactors and CalcDetailUV functions
		float4 CalcHeightBlendFactors( float4 MaterialHeights, float4 MaterialFactors, float BlendRange )
		{
			float4 Mat = MaterialHeights + MaterialFactors;
			float BlendStart = max( max( Mat.x, Mat.y ), max( Mat.z, Mat.w ) ) - BlendRange;
			
			float4 MatBlend = max( Mat - vec4( BlendStart ), vec4( 0.0 ) );
			
			float Epsilon = 0.00001;
			return float4( MatBlend ) / ( dot( MatBlend, vec4( 1.0 ) ) + Epsilon );
		}
		
		float2 CalcDetailUV( float2 WorldSpacePosXZ )
		{
			return WorldSpacePosXZ * DetailTileFactor;
		}
		
		// A low spec vertex buffer version of CalculateDetails
		void CalculateDetailsLowSpec( float2 WorldSpacePosXZ, out float3 DetailDiffuse, out float4 DetailMaterial )
		{
			float2 DetailCoordinates = WorldSpacePosXZ * WorldSpaceToDetail;
			float2 DetailCoordinatesScaled = DetailCoordinates * DetailTextureSize;
			float2 DetailCoordinatesScaledFloored = floor( DetailCoordinatesScaled );
			float2 DetailCoordinatesFrac = DetailCoordinatesScaled - DetailCoordinatesScaledFloored;
			DetailCoordinates = DetailCoordinatesScaledFloored * DetailTexelSize + DetailTexelSize * 0.5;
			
			float4 Factors = float4(
				(1.0 - DetailCoordinatesFrac.x) * (1.0 - DetailCoordinatesFrac.y),
				DetailCoordinatesFrac.x * (1.0 - DetailCoordinatesFrac.y),
				(1.0 - DetailCoordinatesFrac.x) * DetailCoordinatesFrac.y,
				DetailCoordinatesFrac.x * DetailCoordinatesFrac.y
			);
			
			float4 DetailIndex = PdxTex2DLod0( DetailIndexTexture, DetailCoordinates ) * 255.0;
			float4 DetailMask = PdxTex2DLod0( DetailMaskTexture, DetailCoordinates ) * Factors[0];
			
			float2 Offsets[3];
			Offsets[0] = float2( DetailTexelSize.x, 0.0 );
			Offsets[1] = float2( 0.0, DetailTexelSize.y );
			Offsets[2] = float2( DetailTexelSize.x, DetailTexelSize.y );
			
			for ( int k = 0; k < 3; ++k )
			{
				float2 DetailCoordinates2 = DetailCoordinates + Offsets[k];
				
				float4 DetailIndices = PdxTex2DLod0( DetailIndexTexture, DetailCoordinates2 ) * 255.0;
				float4 DetailMasks = PdxTex2DLod0( DetailMaskTexture, DetailCoordinates2 ) * Factors[k+1];
				
				for ( int i = 0; i < 4; ++i )
				{
					for ( int j = 0; j < 4; ++j )
					{
						if ( DetailIndex[j] == DetailIndices[i] )
						{
							DetailMask[j] += DetailMasks[i];
						}
					}
				}
			}

			float2 DetailUV = CalcDetailUV( WorldSpacePosXZ );
			
			float4 DiffuseTexture0 = PdxTex2DLod0( DetailTextures, float3( DetailUV, DetailIndex[0] ) ) * smoothstep( 0.0, 0.1, DetailMask[0] );
			float4 DiffuseTexture1 = PdxTex2DLod0( DetailTextures, float3( DetailUV, DetailIndex[1] ) ) * smoothstep( 0.0, 0.1, DetailMask[1] );
			float4 DiffuseTexture2 = PdxTex2DLod0( DetailTextures, float3( DetailUV, DetailIndex[2] ) ) * smoothstep( 0.0, 0.1, DetailMask[2] );
			float4 DiffuseTexture3 = PdxTex2DLod0( DetailTextures, float3( DetailUV, DetailIndex[3] ) ) * smoothstep( 0.0, 0.1, DetailMask[3] );
			
			float4 BlendFactors = CalcHeightBlendFactors( float4( DiffuseTexture0.a, DiffuseTexture1.a, DiffuseTexture2.a, DiffuseTexture3.a ), DetailMask, DetailBlendRange );
			//BlendFactors = DetailMask;
			
			DetailDiffuse = DiffuseTexture0.rgb * BlendFactors.x + 
							DiffuseTexture1.rgb * BlendFactors.y + 
							DiffuseTexture2.rgb * BlendFactors.z + 
							DiffuseTexture3.rgb * BlendFactors.w;
			
			DetailMaterial = vec4( 0.0 );
			
			for ( int i = 0; i < 4; ++i )
			{
				float BlendFactor = BlendFactors[i];
				if ( BlendFactor > 0.0 )
				{
					float3 ArrayUV = float3( DetailUV, DetailIndex[i] );
					float4 NormalTexture = PdxTex2DLod0( NormalTextures, ArrayUV );
					float4 MaterialTexture = PdxTex2DLod0( MaterialTextures, ArrayUV );

					DetailMaterial += MaterialTexture * BlendFactor;
				}
			}
		}
	
		VS_OUTPUT_PDX_TERRAIN_LOW_SPEC TerrainVertexLowSpec( float2 WithinNodePos, float2 NodeOffset, float NodeScale, float2 LodDirection, float LodLerpFactor )
		{
			STerrainVertex Vertex = CalcTerrainVertex( WithinNodePos, NodeOffset, NodeScale, LodDirection, LodLerpFactor );

			#ifdef TERRAIN_FLAT_MAP_LERP
				Vertex.WorldSpacePos.y = lerp( Vertex.WorldSpacePos.y, FlatMapHeight, FlatMapLerp );
			#endif
			#ifdef TERRAIN_FLAT_MAP
				Vertex.WorldSpacePos.y = FlatMapHeight;
			#endif

			VS_OUTPUT_PDX_TERRAIN_LOW_SPEC Out;
			Out.WorldSpacePos = Vertex.WorldSpacePos;

			Out.Position = FixProjectionAndMul( ViewProjectionMatrix, float4( Vertex.WorldSpacePos, 1.0 ) );
			Out.ShadowProj = mul( ShadowMapTextureMatrix, float4( Vertex.WorldSpacePos, 1.0 ) );
			
			CalculateDetailsLowSpec( Vertex.WorldSpacePos.xz, Out.DetailDiffuse, Out.DetailMaterial );
			
			float2 ColorMapCoords = Vertex.WorldSpacePos.xz * WorldSpaceToTerrain0To1;

#if defined( PDX_OSX ) && defined( PDX_OPENGL )
			// We're limited to the amount of samplers we can bind at any given time on Mac, so instead
			// we disable the usage of ColorTexture (since its effects are very subtle) and assign a
			// default value here instead.
			Out.ColorMap = float3( vec3( 0.5 ) );
#else
			Out.ColorMap = PdxTex2DLod0( ColorTexture, float2( ColorMapCoords.x, 1.0 - ColorMapCoords.y ) ).rgb;
#endif

			Out.FlatMap = float3( vec3( 0.5f ) ); // neutral overlay
			#ifdef TERRAIN_FLAT_MAP_LERP
				Out.FlatMap = lerp( Out.FlatMap, PdxTex2DLod0( FlatMapTexture, float2( ColorMapCoords.x, 1.0 - ColorMapCoords.y ) ).rgb, FlatMapLerp );
			#endif

			Out.Normal = CalculateNormal( Vertex.WorldSpacePos.xz );

			return Out;
		}
	]]
	
	MainCode VertexShader
	{
		Input = "VS_INPUT_PDX_TERRAIN"
		Output = "VS_OUTPUT_PDX_TERRAIN"
		Code
		[[
			PDX_MAIN
			{
				return TerrainVertex( Input.UV, Input.NodeOffset_Scale_Lerp.xy, Input.NodeOffset_Scale_Lerp.z, Input.LodDirection, Input.NodeOffset_Scale_Lerp.w );
			}
		]]
	}

	MainCode VertexShaderSkirt
	{
		Input = "VS_INPUT_PDX_TERRAIN_SKIRT"
		Output = "VS_OUTPUT_PDX_TERRAIN"
		Code
		[[
			PDX_MAIN
			{
				VS_OUTPUT_PDX_TERRAIN Out = TerrainVertex( Input.UV, Input.NodeOffset_Scale_Lerp.xy, Input.NodeOffset_Scale_Lerp.z, Input.LodDirection, Input.NodeOffset_Scale_Lerp.w );

				float3 Position = FixPositionForSkirt( Out.WorldSpacePos, Input.VertexID );
				Out.Position = FixProjectionAndMul( ViewProjectionMatrix, float4( Position, 1.0 ) );

				return Out;
			}
		]]
	}
	
	MainCode VertexShaderLowSpec
	{
		Input = "VS_INPUT_PDX_TERRAIN"
		Output = "VS_OUTPUT_PDX_TERRAIN_LOW_SPEC"
		Code
		[[
			PDX_MAIN
			{
				return TerrainVertexLowSpec( Input.UV, Input.NodeOffset_Scale_Lerp.xy, Input.NodeOffset_Scale_Lerp.z, Input.LodDirection, Input.NodeOffset_Scale_Lerp.w );
			}
		]]
	}

	MainCode VertexShaderLowSpecSkirt
	{
		Input = "VS_INPUT_PDX_TERRAIN_SKIRT"
		Output = "VS_OUTPUT_PDX_TERRAIN_LOW_SPEC"
		Code
		[[
			PDX_MAIN
			{
				VS_OUTPUT_PDX_TERRAIN_LOW_SPEC Out = TerrainVertexLowSpec( Input.UV, Input.NodeOffset_Scale_Lerp.xy, Input.NodeOffset_Scale_Lerp.z, Input.LodDirection, Input.NodeOffset_Scale_Lerp.w );

				float3 Position = FixPositionForSkirt( Out.WorldSpacePos, Input.VertexID );
				Out.Position = FixProjectionAndMul( ViewProjectionMatrix, float4( Position, 1.0 ) );

				return Out;
			}
		]]
	}
}


PixelShader =
{
	# PdxTerrain uses texture index 0 - 6

	# Jomini specific
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

	# Game specific
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
	TextureSampler FlatMapEnvironmentMap
	{
		Ref = FlatMapEnvironmentMap
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		Type = "Cube"
	}
	TextureSampler SurroundFlatMapMask
	{
		Ref = SurroundFlatMapMask
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Border"
		SampleModeV = "Border"
		Border_Color = { 1 1 1 1 }
		File = "gfx/map/surround_map/surround_mask.dds"
	}

	Code
	[[
		SLightingProperties GetFlatMapLerpSunLightingProperties( float3 WorldSpacePos, float ShadowTerm )
		{
			SLightingProperties LightingProps;
			LightingProps._ToCameraDir = normalize( CameraPosition - WorldSpacePos );
			LightingProps._ToLightDir = ToSunDir;
			LightingProps._LightIntensity = FlatMapLerpSunDiffuse * 5;
			LightingProps._ShadowTerm = ShadowTerm;
			LightingProps._CubemapIntensity = FlatMapLerpCubemapIntensity;
			LightingProps._CubemapYRotation = FlatMapLerpCubemapYRotation;

			return LightingProps;
		}
	]]

	MainCode PixelShader
	{
		Input = "VS_OUTPUT_PDX_TERRAIN"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				clip( vec2(1.0) - Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1 );

				// MOD(godherja)
				#if defined(GH_ENABLE_DYNAMIC_TERRAIN) && !defined(GH_FORCE_DISABLE_DYNAMIC_TERRAIN)
					int TerrainVariantIndex = GH_GetTerrainVariantIndex(Input.WorldSpacePos.xz);

					int AdjacentTerrainVariantIndex = TerrainVariantIndex;

					#ifndef GH_DISABLE_SMOOTH_DYNAMIC_TERRAIN_BORDERS
						if (CameraPosition.y < GH_DYNAMIC_TERRAIN_MAX_SMOOTH_BORDERS_CAMERA_Y)
						{
							int AdjacentRegionIndex = GH_GetNearestAdjacentDynamicTerrainRegionIndex(Input.WorldSpacePos.xz);

							AdjacentTerrainVariantIndex = GH_GetTerrainVariantIndexByRegion(AdjacentRegionIndex);
						}
					#endif // !GH_DISABLE_SMOOTH_DYNAMIC_TERRAIN_BORDERS
				#else
					int TerrainVariantIndex         = 0;
					int AdjacentTerrainVariantIndex = 0;
				#endif // GH_ENABLE_DYNAMIC_TERRAIN && !GH_FORCE_DISABLE_DYNAMIC_TERRAIN

				#ifdef GH_DEBUG_DYNAMIC_TERRAIN_MASK
					// Define GH_DEBUG_DYNAMIC_TERRAIN_MASK to color in regions based on
					// the terrain variant index provided for them by the dynamic terrain mask.
					return float4(
						((TerrainVariantIndex >> 0) & 1 != 0) ? 1.0f : 0.0f,
						((TerrainVariantIndex >> 1) & 1 != 0) ? 1.0f : 0.0f,
						((TerrainVariantIndex >> 2) & 1 != 0) ? 1.0f : 0.0f,
						1.0f
					);
				#endif // GH_DEBUG_DYNAMIC_TERRAIN_MASK
				// END MOD

				float4 DetailDiffuse;
				float3 DetailNormal;
				float4 DetailMaterial;
				CalculateDetails( Input.WorldSpacePos.xz, TerrainVariantIndex, DetailDiffuse, DetailNormal, DetailMaterial );

				// MOD(godherja)
				float AdjacentBlendAmount = 0.0f;

				if (TerrainVariantIndex != AdjacentTerrainVariantIndex)
				{
					AdjacentBlendAmount = GH_GetAdjacentRegionBlendAmount(Input.WorldSpacePos.xz, GH_ADJACENT_TERRAIN_BLEND_PROXIMITY_RANGE);
					if (AdjacentBlendAmount > 0.01f)
					{
						float4 AdjacentDetailDiffuse;
						float3 AdjacentDetailNormal;
						float4 AdjacentDetailMaterial;
						CalculateDetails( Input.WorldSpacePos.xz, AdjacentTerrainVariantIndex, AdjacentDetailDiffuse, AdjacentDetailNormal, AdjacentDetailMaterial );

						DetailDiffuse  = lerp(DetailDiffuse,  AdjacentDetailDiffuse,  AdjacentBlendAmount);
						DetailNormal   = lerp(DetailNormal,   AdjacentDetailNormal,   AdjacentBlendAmount);
						DetailMaterial = lerp(DetailMaterial, AdjacentDetailMaterial, AdjacentBlendAmount);
					}
				}
				// END MOD

				float2 ColorMapCoords = Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1;
#if defined( PDX_OSX ) && defined( PDX_OPENGL )
				// We're limited to the amount of samplers we can bind at any given time on Mac, so instead
				// we disable the usage of ColorTexture (since its effects are very subtle) and assign a
				// default value here instead.
				float3 ColorMap = float3( vec3( 0.5 ) );
#else
				float3 ColorMap = PdxTex2D( ColorTexture, float2( ColorMapCoords.x, 1.0 - ColorMapCoords.y ) ).rgb;
#endif
				
				float3 FlatMap = float3( vec3( 0.5f ) ); // neutral overlay
				#ifdef TERRAIN_FLAT_MAP_LERP
					FlatMap = lerp( FlatMap, PdxTex2D( FlatMapTexture, float2( ColorMapCoords.x, 1.0 - ColorMapCoords.y ) ).rgb, FlatMapLerp );
				#endif

				float3 Normal = CalculateNormal( Input.WorldSpacePos.xz );

                float3 ReorientedNormal = ReorientNormal( Normal, DetailNormal );

				float SnowHighlight = 0.0f;
				#ifndef UNDERWATER
					// MOD(godherja)
					//DetailDiffuse.rgb = ApplyDynamicMasksDiffuse( DetailDiffuse.rgb, ReorientedNormal, ColorMapCoords );
					DetailDiffuse.rgb = ApplyDynamicMasksDiffuse( DetailDiffuse.rgb, ReorientedNormal, ColorMapCoords, TerrainVariantIndex, AdjacentTerrainVariantIndex, AdjacentBlendAmount );
					// END MOD
				#endif

				float3 Diffuse = GetOverlay( DetailDiffuse.rgb, ColorMap, ( 1 - DetailMaterial.r ) * COLORMAP_OVERLAY_STRENGTH );


				#ifdef TERRAIN_COLOR_OVERLAY
					float3 BorderColor;
					float BorderPreLightingBlend;
					float BorderPostLightingBlend;
					GetBorderColorAndBlendGame( Input.WorldSpacePos.xz, FlatMap, BorderColor, BorderPreLightingBlend, BorderPostLightingBlend );

					// MOD(godherja)
					//Diffuse = lerp( Diffuse, BorderColor, BorderPreLightingBlend );
					Diffuse = lerp(
						Diffuse,
						GH_ApplySaturationMultiplier(BorderColor, GH_TERRAIN_COLOR_OVERLAY_SATURATION_MULTIPLIER),
						GH_TERRAIN_COLOR_OVERLAY_BLEND_MULTIPLIER*BorderPreLightingBlend
					);
					// END MOD

					#ifdef TERRAIN_FLAT_MAP_LERP
						float3 FlatColor;
						GetBorderColorAndBlendGameLerp( Input.WorldSpacePos.xz, FlatMap, FlatColor, BorderPreLightingBlend, BorderPostLightingBlend, FlatMapLerp );

						// MOD(godherja)
						//FlatMap = lerp( FlatMap, FlatColor, saturate( BorderPreLightingBlend + BorderPostLightingBlend ) );
						FlatMap = lerp(
							FlatMap,
							GH_ApplySaturationMultiplier(FlatColor, GH_FLATMAP_COLOR_OVERLAY_SATURATION_MULTIPLIER),
							GH_FLATMAP_COLOR_OVERLAY_BLEND_MULTIPLIER*saturate( BorderPreLightingBlend + BorderPostLightingBlend )
						);
						// END MOD
					#endif
				#endif

				#ifdef TERRAIN_COLOR_OVERLAY
					ApplyHighlightColor( Diffuse, ColorMapCoords );
					CompensateWhiteHighlightColor( Diffuse, ColorMapCoords, SnowHighlight );
				#endif

				float ShadowTerm = CalculateShadow( Input.ShadowProj, ShadowMap );

				#ifdef TERRAIN_FLAT_MAP_LERP
				if ( HasFlatMapLightingEnabled == 1 )
				{
 					SMaterialProperties FlatMapMaterialProps = GetMaterialProperties( FlatMap, float3( 0.0, 1.0, 0.0 ), 1.0, 0.0, 0.0 );
 					SLightingProperties FlatMapLightingProps = GetFlatMapLerpSunLightingProperties( Input.WorldSpacePos, ShadowTerm );
 					FlatMap = CalculateSunLighting( FlatMapMaterialProps, FlatMapLightingProps, FlatMapEnvironmentMap );
				}
				#endif

				SMaterialProperties MaterialProps = GetMaterialProperties( Diffuse, ReorientedNormal, DetailMaterial.a, DetailMaterial.g, DetailMaterial.b );
				SLightingProperties LightingProps = GetSunLightingProperties( Input.WorldSpacePos, ShadowTerm );

				float3 FinalColor = CalculateSunLighting( MaterialProps, LightingProps, EnvironmentMap );

				#ifdef TERRAIN_COLOR_OVERLAY
					// MOD(godherja)
					//FinalColor.rgb = lerp( FinalColor.rgb, BorderColor, BorderPostLightingBlend );
					FinalColor.rgb = lerp(
						FinalColor.rgb,
						GH_ApplySaturationMultiplier(BorderColor, GH_TERRAIN_COLOR_OVERLAY_SATURATION_MULTIPLIER),
						GH_TERRAIN_COLOR_OVERLAY_BLEND_MULTIPLIER*BorderPostLightingBlend
					);
					// END MOD
				#endif

				#ifdef TERRAIN_COLOR_OVERLAY
					ApplyHighlightColor( FinalColor.rgb, ColorMapCoords, 0.25 );
				#endif

				#ifdef TERRAIN_COLOR_OVERLAY
					ApplyDiseaseDiffuse( FinalColor, ColorMapCoords );
					ApplyLegendDiffuse( FinalColor, ColorMapCoords );
				#endif

				// MOD(godherja)
				#ifndef UNDERWATER
					FinalColor = ApplyFogOfWar( FinalColor, Input.WorldSpacePos, FogOfWarAlpha );
					FinalColor = ApplyDistanceFog( FinalColor, Input.WorldSpacePos );
				#endif
				// END MOD

				#ifdef TERRAIN_FLAT_MAP_LERP
					FinalColor = lerp( FinalColor, FlatMap, FlatMapLerp );
				#endif

				float Alpha = 1.0;
				#ifdef UNDERWATER
					Alpha = CompressWorldSpace( Input.WorldSpacePos );
				#endif

				#ifdef TERRAIN_DEBUG
					TerrainDebug( FinalColor, Input.WorldSpacePos );
				#endif

				DebugReturn( FinalColor, MaterialProps, LightingProps, EnvironmentMap );
				return float4( FinalColor, Alpha );
			}
		]]
	}

	MainCode PixelShaderLowSpec
	{
		Input = "VS_OUTPUT_PDX_TERRAIN_LOW_SPEC"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				clip( vec2(1.0) - Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1 );

				float3 DetailDiffuse = Input.DetailDiffuse;
				float4 DetailMaterial = Input.DetailMaterial;

				float2 ColorMapCoords = Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1;

				float3 ColorMap = Input.ColorMap;
				float3 FlatMap = Input.FlatMap;

				float3 Normal = Input.Normal;

				float SnowHighlight = 0.0f;
				#ifndef UNDERWATER
					// MOD(godherja)
					//DetailDiffuse = ApplyDynamicMasksDiffuse( DetailDiffuse, Normal, ColorMapCoords );
					DetailDiffuse = ApplyDynamicMasksDiffuse( DetailDiffuse, Normal, ColorMapCoords, 0, 0, 0.0f );
					// END MOD
				#endif

				float3 Diffuse = GetOverlay( DetailDiffuse.rgb, ColorMap, ( 1 - DetailMaterial.r ) * COLORMAP_OVERLAY_STRENGTH );
				float3 ReorientedNormal = Normal;

				#ifdef TERRAIN_COLOR_OVERLAY
					float3 BorderColor;
					float BorderPreLightingBlend;
					float BorderPostLightingBlend;
					GetBorderColorAndBlendGame( Input.WorldSpacePos.xz, FlatMap, BorderColor, BorderPreLightingBlend, BorderPostLightingBlend );

					// MOD(godherja)
					//Diffuse = lerp( Diffuse, BorderColor, BorderPreLightingBlend );
					Diffuse = lerp(
						Diffuse,
						GH_ApplySaturationMultiplier(BorderColor, GH_TERRAIN_COLOR_OVERLAY_SATURATION_MULTIPLIER),
						GH_TERRAIN_COLOR_OVERLAY_BLEND_MULTIPLIER*BorderPreLightingBlend
					);
					// END MOD

					#ifdef TERRAIN_FLAT_MAP_LERP
						float3 FlatColor;
						GetBorderColorAndBlendGameLerp( Input.WorldSpacePos.xz, FlatMap, FlatColor, BorderPreLightingBlend, BorderPostLightingBlend, FlatMapLerp );

						// MOD(godherja)
						//FlatMap = lerp( FlatMap, FlatColor, saturate( BorderPreLightingBlend + BorderPostLightingBlend ) );
						FlatMap = lerp(
							FlatMap,
							GH_ApplySaturationMultiplier(FlatColor, GH_FLATMAP_COLOR_OVERLAY_SATURATION_MULTIPLIER),
							GH_FLATMAP_COLOR_OVERLAY_BLEND_MULTIPLIER*saturate( BorderPreLightingBlend + BorderPostLightingBlend )
						);
						// END MOD
					#endif 
				#endif

				//float ShadowTerm = CalculateShadow( Input.ShadowProj, ShadowMap );
				float ShadowTerm = 1.0;

				SMaterialProperties MaterialProps = GetMaterialProperties( Diffuse, ReorientedNormal, DetailMaterial.a, DetailMaterial.g, DetailMaterial.b );
				SLightingProperties LightingProps = GetSunLightingProperties( Input.WorldSpacePos, ShadowTerm );

				float3 FinalColor = CalculateSunLightingLowSpec( MaterialProps, LightingProps );

				// MOD(godherja)
				// See comment in high-spec shader above
				// #ifndef UNDERWATER
				// 	FinalColor = ApplyFogOfWar( FinalColor, Input.WorldSpacePos, FogOfWarAlpha );
				// 	FinalColor = ApplyDistanceFog( FinalColor, Input.WorldSpacePos );
				// #endif
				// END MOD

				#ifdef TERRAIN_COLOR_OVERLAY
					// MOD(godherja)
					//FinalColor.rgb = lerp( FinalColor.rgb, BorderColor, BorderPostLightingBlend );
					FinalColor.rgb = lerp(
						FinalColor.rgb,
						GH_ApplySaturationMultiplier(BorderColor, GH_TERRAIN_COLOR_OVERLAY_SATURATION_MULTIPLIER),
						GH_TERRAIN_COLOR_OVERLAY_BLEND_MULTIPLIER*BorderPostLightingBlend
					);
					// END MOD
				#endif

				#ifdef TERRAIN_COLOR_OVERLAY
					ApplyHighlightColor( FinalColor.rgb, ColorMapCoords );
					CompensateWhiteHighlightColor( FinalColor.rgb, ColorMapCoords, SnowHighlight );
				#endif

				#ifndef UNDERWATER
					FinalColor = ApplyFogOfWar( FinalColor, Input.WorldSpacePos, FogOfWarAlpha );
					FinalColor = ApplyDistanceFog( FinalColor, Input.WorldSpacePos );
				#endif

				#ifdef TERRAIN_FLAT_MAP_LERP
					FinalColor = lerp( FinalColor, FlatMap, FlatMapLerp );
				#endif

				float Alpha = 1.0;
				#ifdef UNDERWATER
					Alpha = CompressWorldSpace( Input.WorldSpacePos );
				#endif

				#ifdef TERRAIN_DEBUG
					TerrainDebug( FinalColor, Input.WorldSpacePos );
				#endif

				DebugReturn( FinalColor, MaterialProps, LightingProps, EnvironmentMap );
				return float4( FinalColor, Alpha );
			}
		]]
	}

	MainCode PixelShaderFlatMap
	{
		Input = "VS_OUTPUT_PDX_TERRAIN"
		Output = "PDX_COLOR"
		Code
		[[
			PDX_MAIN
			{
				#ifdef TERRAIN_SKIRT
					return float4( 0, 0, 0, 0 );
				#endif

				clip( vec2(1.0) - Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1 );

				float2 ColorMapCoords = Input.WorldSpacePos.xz * WorldSpaceToTerrain0To1;
				float3 FlatMap = PdxTex2D( FlatMapTexture, float2( ColorMapCoords.x, 1.0 - ColorMapCoords.y ) ).rgb;

				#ifdef TERRAIN_COLOR_OVERLAY
					float3 BorderColor;
					float BorderPreLightingBlend;
					float BorderPostLightingBlend;
					
					GetBorderColorAndBlendGameLerp( Input.WorldSpacePos.xz, FlatMap, BorderColor, BorderPreLightingBlend, BorderPostLightingBlend, 1.0f );

					// MOD(godherja)
					//FlatMap = lerp( FlatMap, BorderColor, saturate( BorderPreLightingBlend + BorderPostLightingBlend ) );
					FlatMap = lerp(
						FlatMap,
						GH_ApplySaturationMultiplier(BorderColor, GH_FLATMAP_COLOR_OVERLAY_SATURATION_MULTIPLIER),
						GH_FLATMAP_COLOR_OVERLAY_BLEND_MULTIPLIER*saturate(BorderPreLightingBlend + BorderPostLightingBlend)
					);
					// END MOD
				#endif

				float3 FinalColor = FlatMap;
				#ifdef TERRAIN_FLATMAP_LIGHTING
					if ( HasFlatMapLightingEnabled == 1 )
					{
						float ShadowTerm = CalculateShadow( Input.ShadowProj, ShadowMap );
						SMaterialProperties FlatMapMaterialProps = GetMaterialProperties( FlatMap, float3( 0.0, 1.0, 0.0 ), 1.0, 0.0, 0.0 );
						SLightingProperties FlatMapLightingProps = GetSunLightingProperties( Input.WorldSpacePos, ShadowTerm );
						FinalColor = CalculateSunLighting( FlatMapMaterialProps, FlatMapLightingProps, EnvironmentMap );
					}
				#endif

				#ifdef TERRAIN_COLOR_OVERLAY
					ApplyHighlightColor( FinalColor, ColorMapCoords, 0.5 );
				#endif

				#ifdef TERRAIN_DEBUG
					TerrainDebug( FinalColor, Input.WorldSpacePos );
				#endif

				// Make flatmap transparent based on the SurroundFlatMapMask
				float SurroundMapAlpha = 1 - PdxTex2D( SurroundFlatMapMask, float2( ColorMapCoords.x, 1.0 - ColorMapCoords.y ) ).b;
				SurroundMapAlpha *= FlatMapLerp;

				return float4( FinalColor, SurroundMapAlpha );
			}
		]]
	}
}


Effect PdxTerrain
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShader"

	# MOD(godherja)
	#Defines = { "TERRAIN_FLAT_MAP_LERP" }
	Defines = { "TERRAIN_FLAT_MAP_LERP" "GH_ENABLE_DYNAMIC_TERRAIN" }
	# END MOD
}

Effect PdxTerrainLowSpec
{
	VertexShader = "VertexShaderLowSpec"
	PixelShader = "PixelShaderLowSpec"
	# MOD(wok-chasm)
	Defines = { "GH_TERRAIN_LOW_SPEC" }
	# END MOD
}

Effect PdxTerrainSkirt
{
	VertexShader = "VertexShaderSkirt"
	PixelShader = "PixelShader"
}

Effect PdxTerrainLowSpecSkirt
{
	VertexShader = "VertexShaderLowSpecSkirt"
	PixelShader = "PixelShaderLowSpec"
	# MOD(wok-chasm)
	Defines = { "GH_TERRAIN_LOW_SPEC" }
	# END MOD
}

### FlatMap Effects
BlendState BlendStateAlpha
{
	BlendEnable = yes
	SourceBlend = "SRC_ALPHA"
	DestBlend = "INV_SRC_ALPHA"
}

Effect PdxTerrainFlat
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderFlatMap"
	BlendState = BlendStateAlpha

	Defines = { "TERRAIN_FLAT_MAP" "TERRAIN_FLATMAP_LIGHTING" }
}

Effect PdxTerrainFlatSkirt
{
	VertexShader = "VertexShaderSkirt"
	PixelShader = "PixelShaderFlatMap"
	BlendState = BlendStateAlpha

	Defines = { "TERRAIN_FLAT_MAP" "TERRAIN_SKIRT" }
}

# Low Spec flat map the same as regular effect
Effect PdxTerrainFlatLowSpec
{
	VertexShader = "VertexShader"
	PixelShader = "PixelShaderFlatMap"
	BlendState = BlendStateAlpha

	Defines = { "TERRAIN_FLAT_MAP" }
}

Effect PdxTerrainFlatLowSpecSkirt
{
	VertexShader = "VertexShaderSkirt"
	PixelShader = "PixelShaderFlatMap"
	BlendState = BlendStateAlpha

	Defines = { "TERRAIN_FLAT_MAP" "TERRAIN_SKIRT" }
}
