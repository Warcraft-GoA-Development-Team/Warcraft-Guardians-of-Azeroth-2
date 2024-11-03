includes = {
	"jomini/texture_decals_base.fxh"
	"jomini/portrait_user_data.fxh"
	# MOD(godherja)
	"GH_portrait_effects.fxh"
	# END MOD
}

PixelShader =
{
	TextureSampler DecalDiffuseArray
	{
		Ref = JominiPortraitDecalDiffuseArray
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		type = "2darray"
	}

	TextureSampler DecalNormalArray
	{
		Ref = JominiPortraitDecalNormalArray
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		type = "2darray"
	}

	TextureSampler DecalPropertiesArray
	{
		Ref = JominiPortraitDecalPropertiesArray
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Wrap"
		type = "2darray"
	}

	BufferTexture DecalDataBuffer
	{
		Ref = JominiPortraitDecalData
		type = uint
	}

	Code
	[[		
		struct DecalData
		{
			uint _DiffuseIndex;
			uint _NormalIndex;
			uint _PropertiesIndex;
			uint _BodyPartIndex;

			uint _DiffuseBlendMode;
			uint _NormalBlendMode;
			uint _PropertiesBlendMode;
			float _Weight;

			uint2 _AtlasPos;
			float2 _UVOffset;
uint2 _UVTiling;

			uint _AtlasSize;
		};

		DecalData GetDecalData( int Index )
		{
			// Data for each decal is stored in multiple texels as specified by DecalData

			DecalData Data;

			Data._DiffuseIndex = PdxReadBuffer( DecalDataBuffer, Index );
			Data._NormalIndex = PdxReadBuffer( DecalDataBuffer, Index + 1 );
			Data._PropertiesIndex = PdxReadBuffer( DecalDataBuffer, Index + 2 );
			Data._BodyPartIndex = PdxReadBuffer( DecalDataBuffer, Index + 3 );

			Data._DiffuseBlendMode = PdxReadBuffer( DecalDataBuffer, Index + 4 );
			Data._NormalBlendMode = PdxReadBuffer( DecalDataBuffer, Index + 5 );
			if ( Data._NormalBlendMode == BLEND_MODE_OVERLAY )
			{
				Data._NormalBlendMode = BLEND_MODE_OVERLAY_NORMAL;
			}
			Data._PropertiesBlendMode = PdxReadBuffer( DecalDataBuffer, Index + 6 );
			Data._Weight = Unpack16BitUnorm( PdxReadBuffer( DecalDataBuffer, Index + 7 ) );

			Data._AtlasPos = uint2( PdxReadBuffer( DecalDataBuffer, Index + 8 ), PdxReadBuffer( DecalDataBuffer, Index + 9 ) );
			Data._UVOffset = float2( Unpack16BitUnorm( PdxReadBuffer( DecalDataBuffer, Index + 10 ) ), Unpack16BitUnorm( PdxReadBuffer( DecalDataBuffer, Index + 11 ) ) );
			Data._UVTiling = uint2( PdxReadBuffer( DecalDataBuffer, Index + 12 ), PdxReadBuffer( DecalDataBuffer, Index + 13 ) );

			Data._AtlasSize = PdxReadBuffer( DecalDataBuffer, Index + 14 );

			return Data;
		}
		
		// MOD(godherja)

		//
		// Macros
		//

		#ifndef PDX_OPENGL
			#define GH_PdxTex2DArrayLoad(samp,uvi,lod) (samp)._Texture.Load( int4((uvi), (lod)) )
		#else
			#define GH_PdxTex2DArrayLoad texelFetch
		#endif

		//
		// Service
		//

		float GH_MipLevelToLod(float MipLevel)
		{
			// This function (originally GetMIP6Level()) was graciously provided by Buck (EK2).

			#ifndef PDX_OPENGL
				// If running on DX, use the below to get decal texture size.
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

			// #ifndef PIXEL_SHADER
			// 	MarkerTexels.BottomRightTexel = GH_PdxTex2DArrayLoad(DecalDiffuseArray, int3(BOTTOM_RIGHT_UV, DiffuseIndex), MarkerLod);
			// 	MarkerTexels.BottomLeftTexel  = GH_PdxTex2DArrayLoad(DecalDiffuseArray, int3(BOTTOM_LEFT_UV, DiffuseIndex), MarkerLod);
			// #else
			// 	// The other two corners are not currently used by pixel shaders, so no use sampling them from there.
			// 	MarkerTexels.BottomRightTexel = float4(0.0f, 0.0f, 0.0f, 0.0f);
			// 	MarkerTexels.BottomLeftTexel  = float4(0.0f, 0.0f, 0.0f, 0.0f);
			// #endif // !PIXEL_SHADER

			return MarkerTexels;
		}

		//
		// Interface
		//

		GH_SPortraitEffect GH_ScanMarkerDecals(int DecalsCount)
		{
			int From = 0;
			int To   = DecalsCount;

			// NOTE: The following is based on AddDecals() and needs
			//       to be kept in sync with it on vanilla updates.
			const int TEXEL_COUNT_PER_DECAL = 15;
			int FromDataTexel = From * TEXEL_COUNT_PER_DECAL;
			int ToDataTexel   = To * TEXEL_COUNT_PER_DECAL;

			const uint MAX_VALUE = 65535;
			// END NOTE

			GH_SPortraitEffect Effect;
			Effect.Type  = GH_PORTRAIT_EFFECT_TYPE_NONE;
			Effect.Param = float4(0.0f, 0.0f, 0.0f, 0.0f);

			for (int i = FromDataTexel; i <= ToDataTexel; i += TEXEL_COUNT_PER_DECAL)
			{
				DecalData Data = GetDecalData(i);

				// TODO: Filter by bodypart index for an early continue?

				if (Data._DiffuseIndex >= MAX_VALUE || Data._Weight <= 0.001f)
					continue;

				GH_SMarkerTexels MarkerTexels = GH_ExtractMarkerTexels(Data._DiffuseIndex);

				//if (GH_MarkerTexelEquals(MarkerTexels.TopLeftTexel, GH_MARKER_TOP_LEFT_FLAT))
					//Effect.Type = GH_PORTRAIT_EFFECT_TYPE_FLAT;

				if (GH_MarkerTexelEquals(MarkerTexels.TopLeftTexel, GH_MARKER_TOP_LEFT_STATUE))
					Effect.Type = GH_PORTRAIT_EFFECT_TYPE_STATUE;

				if (Effect.Type != GH_PORTRAIT_EFFECT_TYPE_NONE)
				{
					Effect.Param = MarkerTexels.TopRightTexel;
					break;
				}
			}

			return Effect;
		}
		// END MOD

		void AddDecals( inout float3 Diffuse, inout float3 Normals, inout float4 Properties, float2 UV, uint InstanceIndex, int From, int To )
		{
			// Body part index is scripted on the mesh asset and should match ECharacterPortraitPart
			uint BodyPartIndex = GetBodyPartIndex( InstanceIndex );

			const int TEXEL_COUNT_PER_DECAL = 15;
			int FromDataTexel = From * TEXEL_COUNT_PER_DECAL;
			int ToDataTexel = To * TEXEL_COUNT_PER_DECAL;

			static const uint MAX_VALUE = 65535;

			// Sorted after priority
			for ( int i = FromDataTexel; i <= ToDataTexel; i += TEXEL_COUNT_PER_DECAL )
			{
				DecalData Data = GetDecalData( i );

				// Max index => unused
				if ( Data._BodyPartIndex == BodyPartIndex )
				{
					float Weight = Data._Weight;

					// Assumes that the cropped area size corresponds to the atlas factor
					float AtlasFactor = 1.0f / Data._AtlasSize;
					if ( ( ( UV.x >= Data._UVOffset.x ) && ( UV.x < ( Data._UVOffset.x + AtlasFactor ) ) ) &&
						 ( ( UV.y >= Data._UVOffset.y ) && ( UV.y < ( Data._UVOffset.y + AtlasFactor ) ) ) )
					{
						float2 DecalUV;
						float TilingMaskSample = 1;
						//UVTiling is incompatible with Decal Atlases, so we only use one of them. 
						//If a tiling value is provided, the tiling feature will be used.
						if ( Data._UVTiling.x == 1 && Data._UVTiling.y == 1 )
						{
							DecalUV = ( UV - Data._UVOffset ) + ( Data._AtlasPos * AtlasFactor );
} 
						else
						{
							DecalUV = UV * Data._UVTiling;
							float2 TilingMaskUV = ( UV - Data._UVOffset ) + ( Data._AtlasPos * AtlasFactor );
							TilingMaskSample = PdxTex2D( DecalPropertiesArray, float3( TilingMaskUV, Data._PropertiesIndex ) ).r;
						}

						if ( Data._DiffuseIndex < MAX_VALUE )
						{
							float4 DiffuseSample = PdxTex2D( DecalDiffuseArray, float3( DecalUV, Data._DiffuseIndex ) );
							Weight = DiffuseSample.a * Weight * TilingMaskSample;
							Diffuse = BlendDecal( Data._DiffuseBlendMode, float4( Diffuse, 0.0f ), DiffuseSample, Weight ).rgb;
						}

						if ( Data._NormalIndex < MAX_VALUE )
						{
							float3 NormalSample = UnpackDecalNormal( PdxTex2D( DecalNormalArray, float3( DecalUV, Data._NormalIndex ) ), Weight );
							Normals = BlendDecal( Data._NormalBlendMode, float4( Normals, 0.0f ), float4( NormalSample, 0.0f ), Weight ).xyz;
						}

						if ( Data._PropertiesIndex < MAX_VALUE )
						{
							float4 PropertiesSample = PdxTex2D( DecalPropertiesArray, float3( DecalUV, Data._PropertiesIndex ) );
							Properties = BlendDecal( Data._PropertiesBlendMode, Properties, PropertiesSample, Weight );
						}
					}
				}
			}

			Normals = normalize( Normals );
		}
	]]
}
