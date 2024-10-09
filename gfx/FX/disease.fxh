Includes = {
	"cw/utility.fxh"
	"standardfuncsgfx.fxh"   
	"jomini/jomini_province_overlays.fxh"
	"jomini/jomini_water.fxh"
}

ConstantBuffer(DiseaseConstants)
{
	float DiseaseMaskFactor;
	float FogSpeedFactor;
	float FogStrengthFactor;
	uint NumEpidemicTypes;
	bool IsEnabled;
}

TextureSampler DiseaseTexture
{
	Index = 10	
	MagFilter = "Linear"
	MinFilter = "Linear"
	MipFilter = "Linear" 
	SampleModeU = "Wrap"
	SampleModeV = "Wrap"
	File = "gfx/map/disease/disease.dds"
}

TextureSampler DiseaseTexture2
{
	Index = 11
	MagFilter = "Linear"
	MinFilter = "Linear"
	MipFilter = "Linear" 
	SampleModeU = "Wrap"
	SampleModeV = "Wrap"
	File = "gfx/map/disease/disease2.dds"
}

BufferTexture DiseaseMaskBuffer
{
	Ref = DiseaseMaskBuffer
	type = float
}

BufferTexture EpidemicTypesBuffer
{
	Ref = EpidemicTypesBuffer
	type = uint
}

PixelShader =
{
	Code
	[[
		static const float2 SamplingOffest[16] =
		{
			float2( 0.002441f, 0.000000f ),
			float2( -0.002441f, 0.000000f ),
			float2( 0.000000f, 0.004883f ),
			float2( 0.000000f, -0.004883f ),
			float2( -0.001726f, 0.003453f ),
			float2( -0.001726f, -0.003453f ),
			float2( 0.001726f, 0.003453f ),
			float2( 0.001726f, -0.003453f ),

			float2( 0.001221f, 0.000000f ),
			float2( -0.001221f, 0.000000f ),
			float2( 0.000000f, 0.002441f ),
			float2( 0.000000f, -0.002441f ),
			float2( -0.000863f, 0.001726f ),
			float2( -0.000863f, -0.001726f ),
			float2( 0.000863f, 0.001726f ),
			float2( 0.000863f, -0.001726f ),
		};

		struct EpidemicSettings
		{
			float _Strength;
			float _EdgeFade;
			float _TileMultiplier;
			uint _TextureIndex;
			uint _TextureChannel;
		};

		float4 GetDiseaseTextureValue( in float2 Coordinate )
		{
			return PdxTex2D( DiseaseTexture, Coordinate / WorldSpaceToTerrain0To1 );
		}

		EpidemicSettings GetEpidemicSettings( in uint EpidemicIndex )
		{
			const uint Index = EpidemicIndex * 4;
			EpidemicSettings Data;

			Data._Strength = Unpack16BitUnorm( PdxReadBuffer( EpidemicTypesBuffer, Index ) );
			Data._EdgeFade = Unpack16BitUnorm( PdxReadBuffer( EpidemicTypesBuffer, Index + 1 ) );
			Data._TileMultiplier = Unpack16BitUnorm( PdxReadBuffer( EpidemicTypesBuffer, Index + 2 ) );

			const uint2 TextureData = Unpack16BitToBytes( PdxReadBuffer( EpidemicTypesBuffer, Index + 3 ) );
			Data._TextureIndex = TextureData.x;
			Data._TextureChannel = TextureData.y;

			return Data;
		}

		float GetDiseaseIntensityAt( in int ProvinceId, in uint EpidemicIndex )
		{
			const int ProvinceDataOffset = ProvinceId * NumEpidemicTypes;
			return PdxReadBuffer( DiseaseMaskBuffer, ProvinceDataOffset + EpidemicIndex );
		}

		float4 GetDiseaseDataOffset( in float2 UV, PdxTextureSampler2D MaskTexture, in float2 Offset )
		{
			const float2 ColorIndex = PdxTex2DLod0( ProvinceColorIndirectionTexture, UV ).rg;
			return PdxTex2DLoad0( MaskTexture, int2( ColorIndex * 255.0f + Offset ) ).rgba;
		}

		//I want to keep it temporarily, this is the original calculation used to calculate the SamplingOffest
		float4 BlurOriginal( in float2 UV, PdxTextureSampler2D MaskTexture, in float2 Offset )
		{
			float Pi = 6.28318530718f; // Pi*2
			float Directions = 8.0f; // BLUR DIRECTIONS (Default 16.0 - More is better but slower)
			float Quality = 3; // BLUR QUALITY (Default 4.0 - More is better but slower)
			float Size = 30.0f; // BLUR SIZE (Radius)
			float2 Resolution = float2( 8192.0f,4096.0f );
			float2 Radius = Size / Resolution.xy;
			float DSkip = Pi / Directions;
			float ISkip = 1.0f / Quality;
			float4 Color = GetDiseaseDataOffset( UV, MaskTexture, Offset );
			int BlackCount = 0;
			int Threshold = 16;
		   
			for( float d = 0.0f; d < Pi; d += DSkip )
			{
				for( float i = ISkip; i <= 1.0f; i += ISkip )
				{
					Color += GetDiseaseDataOffset( UV + float2( cos( d ), sin( d ) ) * Radius * i, MaskTexture, Offset );
					if ( all ( Color == float4( 0.0f, 0.0f, 0.0f, 0.0f ) ) )
					{
						BlackCount++;
						if ( BlackCount >= Threshold )
						{
							return float4( 0.0f, 0.0f, 0.0f, 0.0f );
						}
					}
				}
			}
			Color /= Quality * Directions;
			return Color;
		}

		float BlurDiseaseIntensity( in float2 Coordinate, in int ProvinceId, in uint EpidemicIndex, PdxBufferFloat MaskBuffer )
		{
			float Intensity = GetDiseaseIntensityAt( ProvinceId, EpidemicIndex );

			for ( int i = 0; i < 16; ++i )
			{
				if ( i > 7 && Intensity == 0.0f )
				{
					return 0.0f;
				}

				// Clamp so we do not check for diseases on the other end of the world
				const float2 OffsetCoordinate = saturate( Coordinate + SamplingOffest[ i ] );
				const int OffsetProvinceId = SampleProvinceId( OffsetCoordinate, ProvinceColorIndirectionTexture );

				Intensity += GetDiseaseIntensityAt( OffsetProvinceId, EpidemicIndex );
			}

			Intensity /= 24;
			return Intensity;
		}
		
		void AddFog( in float2 Coordinate, inout float DiseaseMask )
		{
			static const float2 FogTiling = float2( 12.70f, 6.35f );
			const float2 FogUV = Coordinate * FogTiling;
			const float NoiseSpeed = GlobalTime * FogSpeedFactor;
			const float SinNoiseSpeed = sin( NoiseSpeed );
			const float CosNoiseSpeed = cos( NoiseSpeed );
			const float2 NoiseCoordinate1 = float2( FogUV.x + SinNoiseSpeed * 0.033f , FogUV.y + SinNoiseSpeed * 0.01f ) * 12;
			const float2 NoiseCoordinate2 = float2( FogUV.x * 0.5f + CosNoiseSpeed * -0.026f + SinNoiseSpeed * 0.03f, FogUV.y * 0.5f + CosNoiseSpeed * 0.03f ) * 12;
			
			const float NoiseTextureValue = PdxTex2D( DiseaseTexture, NoiseCoordinate1 ).r;
			const float NoiseTextureValue2 = PdxTex2D( DiseaseTexture, NoiseCoordinate2 ).r;
			DiseaseMask += NoiseTextureValue * NoiseTextureValue2 * DiseaseMask * FogStrengthFactor;
		}

		float GetDiseaseNoiseTextureValue( in float2 Coordinate, in EpidemicSettings TypeSettings )
		{
			const float2 TiledCoordinate = Coordinate / WorldSpaceToTerrain0To1 * TypeSettings._TileMultiplier;

			float4 PackedValue;

			if ( TypeSettings._TextureIndex == 0 )
			{
				PackedValue = PdxTex2D( DiseaseTexture, TiledCoordinate );
			}
			else if ( TypeSettings._TextureIndex == 1 )
			{
				PackedValue = PdxTex2D( DiseaseTexture2, TiledCoordinate );
			}
			else
			{
				return 0;
			}

			return PackedValue[ TypeSettings._TextureChannel ] * TypeSettings._Strength;
		}

		void ApplyDiseaseColor( inout float3 TerrainColor, in float2 Coordinate, in uint EpidemicIndex, in float DiseaseMask, in float ZoomBlendOut )
		{
			static const float OrganicTileFactor = 0.5f;
			const EpidemicSettings TypeSettings = GetEpidemicSettings( EpidemicIndex );
			const float DiseaseTextureValue = GetDiseaseNoiseTextureValue( Coordinate, TypeSettings );

			//Add Disease Organic Texture
			const float OrganicTextureValue = GetDiseaseTextureValue( Coordinate * TypeSettings._TileMultiplier * OrganicTileFactor ).r;
			DiseaseMask += pow( OrganicTextureValue, 3 ) * DiseaseMask;
			
			//Add Fog
			AddFog(Coordinate, DiseaseMask);

			//Add Disease Texture
			DiseaseMask += DiseaseTextureValue;
		
			DiseaseMask *= ( TypeSettings._EdgeFade + abs( sin( GlobalTime * 0.5f ) ) * 0.1f ) * DiseaseMask;
		
			const float3 DiseaseColor = GetOverlay( TerrainColor, float3( 0.3f - DiseaseMask * 0.4f, 0.0f, 0.0f ), DiseaseMask * DiseaseMaskFactor );
			TerrainColor = lerp( TerrainColor, clamp( DiseaseColor, 0, 1 ), ( 1.0f - ZoomBlendOut ) );
		}

		float4 DiseaseBilinearColorSample( in float2 Coordinate, in uint EpidemicIndex )
		{
			float2 Pixel = ( Coordinate * IndirectionMapSize );
			float2 FracCoord = frac( Pixel );
			Pixel = floor(Pixel) / IndirectionMapSize - InvIndirectionMapSize / 2.0f;
		
			int ProvinceId11 = SampleProvinceId( Pixel, ProvinceColorIndirectionTexture );
			float4 C11 = GetDiseaseIntensityAt( ProvinceId11, EpidemicIndex );
			int ProvinceId21 = SampleProvinceId( Pixel + float2( InvIndirectionMapSize.x, 0.0f ), ProvinceColorIndirectionTexture );
			float4 C21 = GetDiseaseIntensityAt( ProvinceId21, EpidemicIndex );
			int ProvinceId12 = SampleProvinceId( Pixel + float2( 0.0f, InvIndirectionMapSize.y ), ProvinceColorIndirectionTexture );
			float4 C12 = GetDiseaseIntensityAt( ProvinceId12, EpidemicIndex );
			int ProvinceId22 = SampleProvinceId( Pixel + InvIndirectionMapSize, ProvinceColorIndirectionTexture );
			float4 C22 = GetDiseaseIntensityAt( ProvinceId22, EpidemicIndex );
		
			float4 X1 = lerp(C11, C21, FracCoord.x);
			float4 X2 = lerp(C12, C22, FracCoord.x);
			return lerp(X1, X2, FracCoord.y);
		}

		void ApplyDiseaseDiffuse( inout float3 TerrainColor, in float2 Coordinate )
		{
#ifndef LOW_SPEC_SHADERS
            //MOD(WC)
			bool tiEnabled = WC_GetTerraIncognitaEnabled(float2( Coordinate.x, 1.0 - Coordinate.y ));

			if ( !IsEnabled || tiEnabled )
			//END MOD
			{
				return;
			}

			static const float DesaturatedFactor = 0.2f;
			static const float GrayScale = 0.2f;
			const int ProvinceId = SampleProvinceId( Coordinate, ProvinceColorIndirectionTexture );
			const float ZoomBlendOut = clamp( ( 1.0f - _WaterZoomedInZoomedOutFactor * 3.1f ) * 5.0f, 0.0f, 1.0f );
			if( ZoomBlendOut > 0.0f )
			{
				const float Gray = ( TerrainColor.r + TerrainColor.g + TerrainColor.b );
				const float3 AdjustedColor = lerp( float3( Gray, Gray, Gray ) * GrayScale, TerrainColor, DesaturatedFactor );

                GH_LOOP
				for( uint EpidemicIndex = 0; EpidemicIndex < NumEpidemicTypes; ++EpidemicIndex )
				{
					const float DiseaseIntensity = DiseaseBilinearColorSample( Coordinate, EpidemicIndex ).r;
					TerrainColor = lerp( TerrainColor, AdjustedColor, saturate( DiseaseIntensity ) );
				}
			}
			else
			{
				GH_LOOP
				for( uint EpidemicIndex = 0; EpidemicIndex < NumEpidemicTypes; ++EpidemicIndex )
				{
					const float DiseaseIntensity = BlurDiseaseIntensity( Coordinate, ProvinceId, EpidemicIndex, DiseaseMaskBuffer );
					if(DiseaseIntensity > 0.01f)
					{
						ApplyDiseaseColor( TerrainColor, Coordinate, EpidemicIndex, DiseaseIntensity, ZoomBlendOut );
					}
				}
			}
#endif
		}
	]]
}
