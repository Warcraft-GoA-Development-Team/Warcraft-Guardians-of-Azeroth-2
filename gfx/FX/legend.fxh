Includes = {
	"cw/utility.fxh"
	"standardfuncsgfx.fxh"   
	"jomini/jomini_province_overlays.fxh"
	"jomini/jomini_water.fxh"
}

BufferTexture LegendMaskBuffer
{
	Ref = LegendMaskBuffer
	type = uint
}

PixelShader =
{
	Code
	[[
		bool HasLegendIn( in int ProvinceId )
		{
			const uint DataIndex = ProvinceId / BITS_IN_BYTE;
			const uint Data = PdxReadBuffer( LegendMaskBuffer, DataIndex );
			const uint BitIndex = ProvinceId % BITS_IN_BYTE;
			return UnpackBitAt( Data, BitIndex );
		}

		float LegendBilinearColorSample( in float2 Coordinate )
		{			
			float2 Pixel = Coordinate * IndirectionMapSize;
			const float2 FracCoord = frac( Pixel );

			Pixel = floor(Pixel) / IndirectionMapSize - InvIndirectionMapSize / 2.0f;
		
			const int ProvinceId11 = SampleProvinceId( Pixel, ProvinceColorIndirectionTexture );
			const float C11 = float( HasLegendIn( ProvinceId11 ) );
			
			const int ProvinceId21 = SampleProvinceId( Pixel + float2( InvIndirectionMapSize.x, 0.0f ), ProvinceColorIndirectionTexture );
			const float C21 = float( HasLegendIn( ProvinceId21 ) );
			
			const int ProvinceId12 = SampleProvinceId( Pixel + float2( 0.0f, InvIndirectionMapSize.y ), ProvinceColorIndirectionTexture );
			const float C12 = float( HasLegendIn( ProvinceId12 ) );
			
			const int ProvinceId22 = SampleProvinceId( Pixel + InvIndirectionMapSize, ProvinceColorIndirectionTexture );
			const float C22 = float( HasLegendIn( ProvinceId22 ) );
		
			const float X1 = lerp(C11, C21, FracCoord.x);
			const float X2 = lerp(C12, C22, FracCoord.x);
			return lerp( X1, X2, FracCoord.y );
		}
		
		void ApplyLegendDiffuse( inout float3 DiffuseColor, in float2 Coordinate)
		{
		    //MOD(WC)
		    bool tiEnabled = WC_GetTerraIncognitaEnabled(float2( Coordinate.x, 1.0 - Coordinate.y ));

		    if ( tiEnabled )
            {
                return;
            }
            //END MOD

			const float LegendIntensity = LegendBilinearColorSample( Coordinate );
			const float ZoomBlendOut = clamp( 1.0f - _WaterZoomedInZoomedOutFactor * 2.5f, 0.0f, 1.0f );
			DiffuseColor = lerp( DiffuseColor, DiffuseColor * 1.8f, LegendIntensity * ZoomBlendOut);
		}
	]]
}
