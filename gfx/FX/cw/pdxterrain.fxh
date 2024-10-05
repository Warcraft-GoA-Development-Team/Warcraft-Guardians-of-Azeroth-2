Includes = {
	"cw/heightmap.fxh"
	"cw/utility.fxh"
	"cw/upscale_utils.fxh"
	# MOD(godherja)
	"gh_dynamic_terrain_textures.fxh"
	# END MOD
}

ConstantBuffer( PdxTerrainConstants )
{
	float3		NormalScale;
	float		QuadtreeLeafNodeScale;
	float2		NormalStepSize;
	
	float2		DetailTileFactor;
	float		DetailBlendRange;
	float		SkirtSize;
	
	float2		NormQuadtreeToWorld;
	float2		WorldSpaceToTerrain0To1;
	
	float2		WorldSpaceToDetail;
	float2		DetailTexelSize;
	float2		DetailTextureSize;
	float2		WorldExtents;
}


VertexStruct VS_INPUT_PDX_TERRAIN
{
	float2 UV					: TEXCOORD0;
	float2 LodDirection			: TEXCOORD1;
	uint4 NodeOffset_Scale_Lerp	: TEXCOORD2;
};

VertexStruct VS_INPUT_PDX_TERRAIN_SKIRT
{
	float2 UV					: TEXCOORD0;
	float2 LodDirection			: TEXCOORD1;
	uint4 NodeOffset_Scale_Lerp	: TEXCOORD2;
	uint VertexID				: PDX_VertexID;
};


PixelShader =
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
	# MOD(godherja)
	# TODO: Rename the following two to GH_TerrainVariantIndexTexture0 and GH_TerrainVariantMaskTexture0
	#       and move their definition to gh_dynamic_terrain_textures.fxh
	#       for parity with alternative terrain variant textures, which would potentially simplify
	#       the code of switchable terrain implementation a little bit.
	# END MOD
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
		SampleModeU = "Wrap"
		SampleModeV = "Clamp"
	}
}


Code
[[
	// MOD(godherja)
	float2 GH_WorldSpacePosXZToMapUV(float2 WorldSpacePosXZ)
	{
		float2 MapUV = WorldSpacePosXZ * WorldSpaceToDetail;
		MapUV.y = 1.0f - MapUV.y;

		return MapUV;
	}
	// END MOD

	float GetLerpedHeight( float2 WorldSpacePosXZ, float2 LodDirection )
	{
		float h1 = GetHeight( WorldSpacePosXZ - LodDirection );
		float h2 = GetHeight( WorldSpacePosXZ + LodDirection );

		//h1 = GetHeightMultisample( WorldSpacePosXZ - LodDirection, 0.25 );
		//h2 = GetHeightMultisample( WorldSpacePosXZ + LodDirection, 0.25 );
		
		return (h1 + h2) * 0.5;
	}
	
	float3 CalculateNormal( float2 WorldSpacePosXZ )
	{
	#ifdef TERRAIN_WRAP_X
		float TerrainSizeX = 1.0 / WorldSpaceToTerrain0To1.x;
	
		float HeightMinX = GetHeight01( float2( mod( WorldSpacePosXZ.x + TerrainSizeX - NormalStepSize.x, TerrainSizeX ), WorldSpacePosXZ.y ) );
		float HeightMaxX = GetHeight01( float2( mod( WorldSpacePosXZ.x + TerrainSizeX + NormalStepSize.x, TerrainSizeX ), WorldSpacePosXZ.y ) );
	#else
		float HeightMinX = GetHeight01( WorldSpacePosXZ + float2(-NormalStepSize.x, 0) );
		float HeightMaxX = GetHeight01( WorldSpacePosXZ + float2(NormalStepSize.x, 0) );
	#endif
		float HeightMinZ = GetHeight01( WorldSpacePosXZ + float2(0, -NormalStepSize.y) );
		float HeightMaxZ = GetHeight01( WorldSpacePosXZ + float2(0, NormalStepSize.y) );
		
		//float2 LookupCoordinates = GetLookupCoordinates( WorldSpacePosXZ );
		//float2 NormalStepSizeInLookup = NormalStepSize * WorldSpaceToLookup * IndirectionSize;
		//
		//float2 FracCoordinates = frac( LookupCoordinates * IndirectionSize );
		//float2 MinFracCoordinatesScaled = min( FracCoordinates, vec2(1.0) - FracCoordinates );
		//bool2 InBorder = lessThan( MinFracCoordinatesScaled, NormalStepSizeInLookup );
	    //
		//float HeightMinX = 0.0;
		//float HeightMaxX = 0.0;
		//float HeightMinZ = 0.0;
		//float HeightMaxZ = 0.0;
		//if ( any( InBorder ) )
		//{
		//	HeightMinX = GetHeight01( WorldSpacePosXZ + float2(-NormalStepSize.x, 0) );
		//	HeightMaxX = GetHeight01( WorldSpacePosXZ + float2(NormalStepSize.x, 0) );
		//	HeightMinZ = GetHeight01( WorldSpacePosXZ + float2(0, -NormalStepSize.y) );
		//	HeightMaxZ = GetHeight01( WorldSpacePosXZ + float2(0, NormalStepSize.y) );
		//}
		//else
		//{
		//	float4 IndirectionSample = SampleLookupTexture( LookupCoordinates );
		//	
		//	float4 CurrentTileToHeightMapScaleAndOffset = TileToHeightMapScaleAndOffset[int(IndirectionSample.w)];
		//	float CurrentTileScale;
		//	float2 TileUV = GetTileUV( LookupCoordinates, IndirectionSample, CurrentTileScale );
		//	
		//	float2 HeightMapCoord = TileUV * CurrentTileToHeightMapScaleAndOffset.xy + CurrentTileToHeightMapScaleAndOffset.zw; // 0 -> 1 in packed heightmap
		//	float2 NormalStepSizeInTile = NormalStepSizeInLookup * CurrentTileToHeightMapScaleAndOffset.xy * CurrentTileScale;
		//	
		//	HeightMinX = PdxTex2DLod0( PackedHeightTexture, HeightMapCoord + float2(-NormalStepSizeInTile.x, 0) );
		//	HeightMaxX = PdxTex2DLod0( PackedHeightTexture, HeightMapCoord + float2(NormalStepSizeInTile.x, 0) );
		//	HeightMinZ = PdxTex2DLod0( PackedHeightTexture, HeightMapCoord + float2(0, -NormalStepSizeInTile.y) );
		//	HeightMaxZ = PdxTex2DLod0( PackedHeightTexture, HeightMapCoord + float2(0, NormalStepSizeInTile.y) );
		//}
		
		float3 Normal = float3( HeightMinX - HeightMaxX, 2.0, HeightMinZ - HeightMaxZ ) * NormalScale;
		return normalize(Normal);
	}
	
	// Rotates normals to the heightmap terrain normal
	float3 SimpleRotateNormalToTerrain( float3 Normal, float2 WorldSpacePosXZ )
	{
		float3 TerrainNormal = CalculateNormal( WorldSpacePosXZ );
		float3 Up = float3( 0.0, 1.0, 0.0 );

		float3 Axis = cross( Up, TerrainNormal );
		float Angle = acos( dot( Up, TerrainNormal ) ) * abs( Normal.y );

		return lerp( dot( Axis, Normal ) * Axis, Normal, cos( Angle ) ) + cross( Axis, Normal ) * sin( Angle );
	}

	// For debugging
	float GetTextureBorder( float2 UV, float2 TextureSize, float BorderSize )
	{
		float2 FracScaledUV = frac( UV * TextureSize );
		if ( FracScaledUV.x < BorderSize || FracScaledUV.x > (1.0 - BorderSize) || FracScaledUV.y < BorderSize || FracScaledUV.y > (1.0 - BorderSize) )
		{
			return 1.0;
		}
		else
		{
			return 0.0;
		}
	}
	
	float GetModValue( float value, float vMod )
	{
		return mod(round(value), vMod) * (1.0 / (vMod - 1.0));
	}
	
	float GetModValueFloor( float value, float vMod )
	{
		return mod(floor(value), vMod) * (1.0 / (vMod - 1.0));
	}
	
	float GetMod2Value( float value )
	{
		if ( abs( mod( round(value), 2.0 ) - 1.0 ) < 0.01 )
		{
			return 1.0;
		}
		else
		{
			return 0.0;
		}
	}
]]


VertexShader
{
	Code
	[[
		struct STerrainVertex
		{
			float3 WorldSpacePos;
		};
		
		STerrainVertex CalcTerrainVertex( float2 WithinNodePos, float2 NodeOffset, float NodeScale, float2 LodDirection, float LodLerpFactor )
		{
			STerrainVertex Out;
			
			NodeScale = 1.0 / NodeScale;
			NodeOffset = NodeOffset * NodeScale;
	
			float2 QuadtreePosition = WithinNodePos * NodeScale + NodeOffset;
			
			float2 WorldSpacePosXZ = QuadtreePosition * NormQuadtreeToWorld;

			// The world will always have an overshoot of half a terrain quadtree cell's worth of vertices. Everything works fine if we just clamp those vertices to world extents here.
			WorldSpacePosXZ = clamp(WorldSpacePosXZ, float2(0.f, 0.f), WorldExtents);
			
			#ifdef PDX_TERRAIN_HEIGHT_MULTISAMPLE
				float Height = GetHeightMultisample( WorldSpacePosXZ, 0.25 );
			#else
				float Height = GetHeight( WorldSpacePosXZ );
			#endif
			
			float2 ScaledLodDirection = ( LodDirection * NodeScale / QuadtreeLeafNodeScale ) * OriginalHeightmapToWorldSpace;
			float LerpedHeight = GetLerpedHeight( WorldSpacePosXZ, ScaledLodDirection );
			Height = lerp( Height, LerpedHeight, LodLerpFactor / UINT16_MAX );
			
			Out.WorldSpacePos = float3( WorldSpacePosXZ.x, Height, WorldSpacePosXZ.y );

			return Out;
		}
		
		float3 FixPositionForSkirt( float3 WorldSpacePosition, uint nVertexID )
		{
			// MOD(godherja)
			//WorldSpacePosition.y += SkirtSize * ((nVertexID + 1) % 2);

			// Vanilla terrain skirt is visible through see-through chasms, which ruins the effect.
			// We can't completely remove it, otherwise subpixel "seams" between terrain node meshes appear.
			// So instead we shorten the skirt. This constant can be used to control the trade-off between
			// the visibility of terrain seams and the visibility of skirt inside chasms.
			const float GH_SKIRT_SIZE_MULTIPLIER = 0.1f;

			WorldSpacePosition.y += SkirtSize * GH_SKIRT_SIZE_MULTIPLIER * ((nVertexID + 1) % 2);
			// END MOD
			return WorldSpacePosition;
		}
	]]
}


PixelShader
{
	Code
	[[
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

		// MOD(godherja)
		//void CalculateDetails( float2 WorldSpacePosXZ, out float4 DetailDiffuseHeight, out float3 DetailNormal, out float4 DetailMaterial )
		void CalculateDetails( float2 WorldSpacePosXZ, int TerrainVariantIndex, out float4 DetailDiffuseHeight, out float3 DetailNormal, out float4 DetailMaterial )
		// END MOD
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

			// MOD(godherja)
			// NOTE: Starting from this point in this function's body vanilla texture sampling macros
			//       have been replaced with the Godherja dynamic terrain aware functions from gh_dynamic_terrain_textures.fxh
			//       of the same name plus GH_TerrainVariantIndex or GH_TerrainVariantMask prefix,
			//       e.g. GH_TerrainVariantIndexPdxTex2D().
			//
			//       And I couldn't simply select the samplers dynamically, because of the dreaded HLSL error X3538,
			//       "Sampler parameter must come from a literal expression." *sigh* ...shaders (aliens-guy.jpg)
			// END MOD

			float4 DetailIndex = GH_TerrainVariantIndexPdxTex2D( TerrainVariantIndex, DetailIndexTexture, DetailCoordinates ) * 255.0;
			float4 DetailMask = GH_TerrainVariantMaskPdxTex2D( TerrainVariantIndex, DetailMaskTexture, DetailCoordinates ) * Factors[0];
			
			float2 Offsets[3];
			Offsets[0] = float2( DetailTexelSize.x, 0.0 );
			Offsets[1] = float2( 0.0, DetailTexelSize.y );
			Offsets[2] = float2( DetailTexelSize.x, DetailTexelSize.y );
			
			for ( int k = 0; k < 3; ++k )
			{
				float2 DetailCoordinates2 = DetailCoordinates + Offsets[k];
				
				float4 DetailIndices = GH_TerrainVariantIndexPdxTex2DLod0( TerrainVariantIndex, DetailIndexTexture, DetailCoordinates2 ) * 255.0;
				float4 DetailMasks = GH_TerrainVariantMaskPdxTex2DLod0( TerrainVariantIndex, DetailMaskTexture, DetailCoordinates2 ) * Factors[k+1];
				
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
			
			float2 DDX = ApplyUpscaleLodBiasMultiplier( ddx(DetailUV) );
			float2 DDY = ApplyUpscaleLodBiasMultiplier( ddy(DetailUV) );
			
			float4 DetailTexture0 = PdxTex2DGrad( DetailTextures, float3( DetailUV, DetailIndex[0] ), DDX, DDY ) * smoothstep( 0.0, 0.1, DetailMask[0] );
			float4 DetailTexture1 = PdxTex2DGrad( DetailTextures, float3( DetailUV, DetailIndex[1] ), DDX, DDY ) * smoothstep( 0.0, 0.1, DetailMask[1] );
			float4 DetailTexture2 = PdxTex2DGrad( DetailTextures, float3( DetailUV, DetailIndex[2] ), DDX, DDY ) * smoothstep( 0.0, 0.1, DetailMask[2] );
			float4 DetailTexture3 = PdxTex2DGrad( DetailTextures, float3( DetailUV, DetailIndex[3] ), DDX, DDY ) * smoothstep( 0.0, 0.1, DetailMask[3] );
			
			float4 BlendFactors = CalcHeightBlendFactors( float4( DetailTexture0.a, DetailTexture1.a, DetailTexture2.a, DetailTexture3.a ), DetailMask, DetailBlendRange );
			//BlendFactors = DetailMask;
			
			DetailDiffuseHeight = DetailTexture0 * BlendFactors.x + 
							DetailTexture1 * BlendFactors.y + 
							DetailTexture2 * BlendFactors.z + 
							DetailTexture3 * BlendFactors.w;
			
			DetailMaterial = vec4( 0.0 );
			float4 DetailNormalSample = vec4( 0.0 );
			
			for ( int i = 0; i < 4; ++i )
			{
				float BlendFactor = BlendFactors[i];
				if ( BlendFactor > 0.0 )
				{
					float3 ArrayUV = float3( DetailUV, DetailIndex[i] );
					float4 NormalTexture = PdxTex2DGrad( NormalTextures, ArrayUV, DDX, DDY );
					float4 MaterialTexture = PdxTex2DGrad( MaterialTextures, ArrayUV, DDX, DDY );

					DetailNormalSample += NormalTexture * BlendFactor;
					DetailMaterial += MaterialTexture * BlendFactor;
				}
			}
			
			DetailNormal = UnpackRRxGNormal( DetailNormalSample ).xyz;
		}
		
		//-------------------------------
		// Debugging --------------------
		//-------------------------------
		float3 GetNumMaterials( float4 Index )
		{
			int nNumMaterials = 0;
			for ( int i = 0; i < 4; ++i )
			{
				if ( Index[i] < 1.0 )
				{
					nNumMaterials++;
				}
			}
			
			if ( nNumMaterials == 1 )
				return float3( 1, 0, 0 );
			else if ( nNumMaterials == 2 )
				return float3( 0, 1, 0 );
			else if ( nNumMaterials == 3 )
				return float3( 0, 0, 1 );
			else if ( nNumMaterials == 4 )
				return float3( 1, 1, 0 );
				
			return float3( 0, 0, 0 );
		}
		
		
		//#define TERRAIN_DEBUG
		//#define TERRAIN_DEBUG_WIREFRAME
		//#define TERRAIN_DEBUG_HEIGHT
		//#define TERRAIN_DEBUG_LOOKUP_BORDER
		//#define TERRAIN_DEBUG_HEIGHTMAP_BORDER
		//#define TERRAIN_DEBUG_NORMAL
		//#define TERRAIN_DEBUG_NUM_MATERIALS
		//#define TERRAIN_DEBUG_DETAIL_BORDER
		//#define TERRAIN_DEBUG_DETAIL_MASK
		//#define TERRAIN_DEBUG_DETAIL_INDEX
		void TerrainDebug( inout float3 Color, float3 WorldSpacePos )
		{
		#ifdef TERRAIN_DEBUG			
			float3 Result = float3(0,0,0);
			
			float2 LookupCoordinates = GetLookupCoordinates( WorldSpacePos.xz );
		#ifdef TERRAIN_DEBUG_WIREFRAME
			float3 Wireframe = vec3( GetTextureBorder( LookupCoordinates, IndirectionSize * (BaseTileSize - 1), 0.02 ) );
			Result += Wireframe;
		#endif
		
		#ifdef TERRAIN_DEBUG_HEIGHT
			Result += float3( GetHeight01( WorldSpacePos.xz ), 0, 0 );			
		#endif

		#ifdef TERRAIN_DEBUG_LOOKUP_BORDER
			float3 LookupBorder = float3( 0.0, 0.0, GetTextureBorder( LookupCoordinates, IndirectionSize, 0.0006 ) );
			Result += LookupBorder;
		#endif
		#ifdef TERRAIN_DEBUG_HEIGHTMAP_BORDER
			float2 HeightMapCoord = GetHeightMapCoordinates( WorldSpacePos.xz );
			float3 HeightMapBorder = float3( GetTextureBorder( HeightMapCoord, PackedHeightMapSize, 0.02 ), 0.0, 0.0 );
			Result += HeightMapBorder;
		#endif
		
		#ifdef TERRAIN_DEBUG_NORMAL
			Result = saturate( CalculateNormal( WorldSpacePos.xz ) );
		#endif
		
			float2 DetailCoordinates = WorldSpacePos.xz * WorldSpaceToDetail + DetailTexelSize * 0.5;		
			float4 DetailMask = PdxTex2D( DetailMaskTexture, DetailCoordinates );		
			float4 DetailIndex = PdxTex2D( DetailIndexTexture, DetailCoordinates );
		#ifdef TERRAIN_DEBUG_NUM_MATERIALS
			Result = GetNumMaterials( DetailIndex );
		#endif
		#ifdef TERRAIN_DEBUG_DETAIL_BORDER
			float3 IndexBorder = float3( 0.0, 0.0, GetTextureBorder( DetailCoordinates, DetailTextureSize, 0.05 ) );
			Result += IndexBorder; // * GetModValueFloor( DetailCoordinates.y * (DetailTextureSize.y), 4 );
		#endif
		#ifdef TERRAIN_DEBUG_DETAIL_MASK
			DetailMask /= dot( DetailMask, vec4( 1.0 ) );
			Result += DetailMask.rgb;
		#endif
		
		#ifdef TERRAIN_DEBUG_DETAIL_INDEX
			Result += DetailIndex.rgb;
		#endif
		
			Color = Result;
		#endif
		}
	]]
}