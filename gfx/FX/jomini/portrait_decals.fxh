includes = {
	"jomini/portrait_decal_utils.fxh"
	"jomini/portrait_user_data.fxh"
}

PixelShader =
{
	TextureSampler DecalDiffuseArray
	{
		Ref = JominiPortraitDecalDiffuseArray
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		type = "2darray"
	}

	TextureSampler DecalNormalArray
	{
		Ref = JominiPortraitDecalNormalArray
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		type = "2darray"
	}

	TextureSampler DecalPropertiesArray
	{
		Ref = JominiPortraitDecalPropertiesArray
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
		type = "2darray"
	}

	BufferTexture DecalDataBuffer
	{
		Ref = JominiPortraitDecalData
		type = uint
	}

	Code
	[[		
		// Should match SPortraitDecalTextureSet::BlendMode
		#define BLEND_MODE_OVERLAY 0
		#define BLEND_MODE_REPLACE 1
		#define BLEND_MODE_HARD_LIGHT 2
		#define BLEND_MODE_MULTIPLY 3
		// Special handling of normal Overlay blend mode (in shader only)
		#define BLEND_MODE_OVERLAY_NORMAL 4

		float OverlayDecal( float Target, float Blend )
		{
			return float( Target > 0.5f ) * ( 1.0f - ( 2.0f * ( 1.0f - Target ) * ( 1.0f - Blend ) ) ) +
				   float( Target <= 0.5f ) * ( 2.0f * Target * Blend );
		}

		float HardLightDecal( float Target, float Blend )
		{
			return float( Blend > 0.5f ) * ( 1.0f - ( 2.0f * ( 1.0f - Target ) * ( 1.0f - Blend ) ) ) +
				   float( Blend <= 0.5f ) * ( 2.0f * Target * Blend );
		}

		float4 BlendDecal( uint BlendMode, float4 Target, float4 Blend, float Weight, uint TextureType)
		{
			float4 Result = vec4( 0.0f );

			if ( BlendMode == BLEND_MODE_OVERLAY )
			{
				// Warcraft
				// If Red channel is white, and blue and green are black, then colour the decal to the Hair Colour palette. Else, apply overlay blending as usual.
				if( Blend.r == 1.0f && Blend.g == 0.0f && Blend.b == 0.0f && TextureType == 0 )
				{
					Result = float4( 
						OverlayDecal( Target.r, vPaletteColorHair.r ),
						OverlayDecal( Target.g, vPaletteColorHair.g ),
						OverlayDecal( Target.b, vPaletteColorHair.b ),
						OverlayDecal( Target.a, Blend.a ) 
					);
				}
				
				else
				{
					Result = float4( 
						OverlayDecal( Target.r, Blend.r ),
						OverlayDecal( Target.g, Blend.g ),
						OverlayDecal( Target.b, Blend.b ),
						OverlayDecal( Target.a, Blend.a ) 
					);
				}
			}
			else if ( BlendMode == BLEND_MODE_REPLACE )
			{
				// Warcraft
				// If Red channel is white, and blue and green are black, then colour the decal to the Hair Colour palette. Else, apply replace blending as usual.
				if( Blend.r == 1.0f && Blend.g == 0.0f && Blend.b == 0.0f && TextureType == 0 )
				{
					Result = float4(
						vPaletteColorHair.r,
						vPaletteColorHair.g,
						vPaletteColorHair.b,
						Target.a
					);
				}
				else
				{
					Result = Blend;
				}
			}
			else if ( BlendMode == BLEND_MODE_HARD_LIGHT )
			{
				// Warcraft
				// If Red channel is white, and blue and green are black, then colour the decal to the Hair Colour palette. Else, apply hard light blending as usual.
				if( Blend.r == 1.0f && Blend.g == 0.0f && Blend.b == 0.0f && TextureType == 0 )
				{
					Result = float4(
						HardLightDecal( Target.r, vPaletteColorHair.r ),
						HardLightDecal( Target.g, vPaletteColorHair.g ),
						HardLightDecal( Target.b, vPaletteColorHair.b ),
						HardLightDecal( Target.a, Blend.a )
					);
				}
				
				else
				{
					Result = float4(
						HardLightDecal( Target.r, Blend.r ),
						HardLightDecal( Target.g, Blend.g ),
						HardLightDecal( Target.b, Blend.b ),
						HardLightDecal( Target.a, Blend.a )
					);
				}
			}
			else if ( BlendMode == BLEND_MODE_MULTIPLY )
			{
				// Warcraft
				// If Red channel is white, and blue and green are black, then colour the decal to the Hair Colour palette. Else, apply multiply blending as usual.
				if(Blend.r == 1.0f && Blend.g == 0.0f && Blend.b == 0.0f)
				{
					Result = float4(
						( Target.r * vPaletteColorHair.r ),
						( Target.g * vPaletteColorHair.g ),
						( Target.b * vPaletteColorHair.b ),
						( Target.a * Blend.a )
					);
				}
				
				else
				{
					Result = Target * Blend;
				}
			}
			else if ( BlendMode == BLEND_MODE_OVERLAY_NORMAL )
			{
				Result = float4( OverlayNormal( Target.xyz, Blend.xyz ), Target.a );
			}

			return lerp( Target, Result, Weight );
		}

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

			uint _AtlasSize;
		};

		DecalData GetDecalData( int Index, uint MaxValue )
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
			Data._Weight = float( PdxReadBuffer( DecalDataBuffer, Index + 7 ) ) / MaxValue;

			Data._AtlasPos = uint2( PdxReadBuffer( DecalDataBuffer, Index + 8 ), PdxReadBuffer( DecalDataBuffer, Index + 9 ) );
			Data._UVOffset = float2( PdxReadBuffer( DecalDataBuffer, Index + 10 ), PdxReadBuffer( DecalDataBuffer, Index + 11 ) );
			Data._UVOffset /= MaxValue;

			Data._AtlasSize = PdxReadBuffer( DecalDataBuffer, Index + 12 );

			return Data;
		}

		void AddDecals( inout float3 Diffuse, inout float3 Normals, inout float4 Properties, float2 UV, uint InstanceIndex, int From, int To )
		{
			// Body part index is scripted on the mesh asset and should match ECharacterPortraitPart
			uint BodyPartIndex = GetBodyPartIndex( InstanceIndex );

			const int TEXEL_COUNT_PER_DECAL = 13;
			int FromDataTexel = From * TEXEL_COUNT_PER_DECAL;
			int ToDataTexel = To * TEXEL_COUNT_PER_DECAL;

			const uint MAX_VALUE = 65535;

			// Sorted after priority
			for ( int i = FromDataTexel; i <= ToDataTexel; i += TEXEL_COUNT_PER_DECAL )
			{
				DecalData Data = GetDecalData( i, MAX_VALUE );

				// Max index => unused
				if ( Data._BodyPartIndex == BodyPartIndex )
				{
					float Weight = Data._Weight;

					// Assumes that the cropped area size corresponds to the atlas factor
					float AtlasFactor = 1.0f / Data._AtlasSize;
					if ( ( ( UV.x >= Data._UVOffset.x ) && ( UV.x < ( Data._UVOffset.x + AtlasFactor ) ) ) &&
						 ( ( UV.y >= Data._UVOffset.y ) && ( UV.y < ( Data._UVOffset.y + AtlasFactor ) ) ) )
					{
						float2 DecalUV = ( UV - Data._UVOffset ) + ( Data._AtlasPos * AtlasFactor );

						if ( Data._DiffuseIndex < MAX_VALUE )
						{
							float4 DiffuseSample = PdxTex2D( DecalDiffuseArray, float3( DecalUV, Data._DiffuseIndex ) );
							Weight = DiffuseSample.a * Weight;
							Diffuse = BlendDecal( Data._DiffuseBlendMode, float4( Diffuse, 0.0f ), DiffuseSample, Weight, 0 ).rgb;
						}

						if ( Data._NormalIndex < MAX_VALUE )
						{
							float3 NormalSample = UnpackDecalNormal( PdxTex2D( DecalNormalArray, float3( DecalUV, Data._NormalIndex ) ), Weight );
							Normals = BlendDecal( Data._NormalBlendMode, float4( Normals, 0.0f ), float4( NormalSample, 0.0f ), Weight, 1 ).xyz;
						}

						if ( Data._PropertiesIndex < MAX_VALUE )
						{
							float4 PropertiesSample = PdxTex2D( DecalPropertiesArray, float3( DecalUV, Data._PropertiesIndex ) );
							Properties = BlendDecal( Data._PropertiesBlendMode, Properties, PropertiesSample, Weight, 2 );
						}
					}
				}
			}

			Normals = normalize( Normals );
		}
	]]
}
