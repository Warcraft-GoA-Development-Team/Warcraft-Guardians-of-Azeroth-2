Includes = {
	"jomini/jomini_colormap.fxh"
	"jomini/jomini_colormap_constants.fxh"
	"jomini/gradient_border_constants.fxh"
	# MOD(WC)
	"WC_map.fxh"
	# END MOD
}

PixelShader = 
{
	TextureSampler ProvinceColorIndirectionTexture
	{
		Ref = JominiProvinceColorIndirection
		MagFilter = "Point"
		MinFilter = "Point"
		MipFilter = "Point"
		SampleModeU = "Wrap"
		SampleModeV = "Border"
		Border_Color = { 0 0 0 0 }
	}
	TextureSampler ProvinceColorTexture
	{
		Ref = JominiProvinceColor
		MagFilter = "Point"
		MinFilter = "Point"
		MipFilter = "Point"
		SampleModeU = "Clamp"
		SampleModeV = "Clamp"
	}
	TextureSampler BorderDistanceFieldTexture
	{
		Ref = JominiBorderDistance
		MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Wrap"
		SampleModeV = "Clamp"
	}

	Code
	[[
		/*
		 * This file contains default implementations of province overlays using the primary and secondary province colors.
		 * The third province colors currently have no default overlay implementation (perhaps a default highlight implementation should be included here?)
		 * More info: https://confluence.paradoxinteractive.com/display/PROG/Province+overlays
		 */


		//#define BORDER_DISTANCE_FIELD_SAMPLES_MEDIUM
		#define BORDER_DISTANCE_FIELD_SAMPLES_HIGH
		float CalcDistanceFieldValue( in float2 NormalizedCoordinate )
		{
			float Distance = PdxTex2D( BorderDistanceFieldTexture, NormalizedCoordinate ).r;

			#if defined( BORDER_DISTANCE_FIELD_SAMPLES_MEDIUM ) || defined( BORDER_DISTANCE_FIELD_SAMPLES_HIGH )
			float2 Offset = vec2( .75f ) * InvGradientTextureSize; // (at the time of writing) this equals 3 color map texels
			Distance += PdxTex2D( BorderDistanceFieldTexture, NormalizedCoordinate + ( Offset * float2( -1,-1 ) ) ).r;
			Distance += PdxTex2D( BorderDistanceFieldTexture, NormalizedCoordinate + ( Offset * float2( 1,-1 ) ) ).r;
			Distance += PdxTex2D( BorderDistanceFieldTexture, NormalizedCoordinate + ( Offset * float2( -1, 1 ) ) ).r;
			Distance += PdxTex2D( BorderDistanceFieldTexture, NormalizedCoordinate + ( Offset * float2( 1, 1 ) ) ).r;
			#endif

			#if defined( BORDER_DISTANCE_FIELD_SAMPLES_HIGH )
			Distance += PdxTex2D( BorderDistanceFieldTexture, NormalizedCoordinate + ( Offset * float2( -1, 0 ) ) ).r;
			Distance += PdxTex2D( BorderDistanceFieldTexture, NormalizedCoordinate + ( Offset * float2( 1, 0 ) ) ).r;
			Distance += PdxTex2D( BorderDistanceFieldTexture, NormalizedCoordinate + ( Offset * float2( 0, 1 ) ) ).r;
			Distance += PdxTex2D( BorderDistanceFieldTexture, NormalizedCoordinate + ( Offset * float2( 0,-1 ) ) ).r;
			#endif

			#if defined( BORDER_DISTANCE_FIELD_SAMPLES_HIGH )
				Distance /= 9.0f;
			#elif defined( BORDER_DISTANCE_FIELD_SAMPLES_MEDIUM )
				Distance /= 5.0f;
			#endif

			return Distance;
		}

		// This default implementation is using the secondary province colors to draw diagonal stripes over provinces (e.g. occupied provinces in titus)
		void ApplySecondaryProvinceOverlay( in float2 NormalizedCoordinate, in float DistanceFieldValue, inout float4 Color )
		{
			float4 SecondaryColor = BilinearColorSampleAtOffset( NormalizedCoordinate, IndirectionMapSize, InvIndirectionMapSize, ProvinceColorIndirectionTexture, ProvinceColorTexture, SecondaryProvinceColorsOffset );
			SecondaryColor.a *= smoothstep( GB_EdgeWidth, GB_EdgeWidth + 0.01f, DistanceFieldValue );
			ApplyDiagonalStripes( Color, SecondaryColor, 0.8, NormalizedCoordinate );
		}

		// This default implementation is using the alternate province colors to draw a solid color over provinces
		void ApplyAlternateProvinceOverlay( in float2 NormalizedCoordinate, inout float4 Color )
		{
			float4 AlternateColor = BilinearColorSampleAtOffset(
				NormalizedCoordinate,
				IndirectionMapSize,
				InvIndirectionMapSize,
				ProvinceColorIndirectionTexture,
				ProvinceColorTexture,
				AlternateProvinceColorsOffset );

			Color.rgb = lerp( Color.rgb, AlternateColor.rgb, AlternateColor.a );
			Color.a = Color.a * ( 1.0f - AlternateColor.a ) + AlternateColor.a;
		}

        // MOD(WC)
		void WC_TryDiscardOverlayColor(inout float4 OverlayColor, in float2 NormalizedCoordinate)
		{
            OverlayColor.a = WC_GetTerraIncognitaAlpha(float2( NormalizedCoordinate.x, 1.0 - NormalizedCoordinate.y ), OverlayColor);
		}
		// END MOD

		// This default implementation is using the primary province colors with the gradiant border system; it is highly customizeable through the GradientBorders constant buffer. 
		// Typically, this function is used to draw gradient borders and/or uniform "province colors"
		float4 CalcPrimaryProvinceOverlay( in float2 NormalizedCoordinate, in float DistanceFieldValue )
		{
			float4 PrimaryColor = BilinearColorSample( NormalizedCoordinate, IndirectionMapSize, InvIndirectionMapSize, ProvinceColorIndirectionTexture, ProvinceColorTexture );

			float GradientAlpha = lerp( GB_GradientAlphaInside, GB_GradientAlphaOutside, RemapClamped( DistanceFieldValue, GB_EdgeWidth + GB_GradientWidth, GB_EdgeWidth, 0.0f, 1.0f ) );
			float Edge = smoothstep( GB_EdgeWidth + max( 0.0001f, GB_EdgeSmoothness ), GB_EdgeWidth, DistanceFieldValue );

			float4 Color;
			Color.rgb = lerp( PrimaryColor.rgb * GB_GradientColorMul, PrimaryColor.rgb * GB_EdgeColorMul, Edge );
			Color.a = PrimaryColor.a * max( GradientAlpha * ( 1.0f - pow( Edge, 2 ) ), GB_EdgeAlpha * Edge );

			return Color;
		}

		void GetGradiantBorderBlendValues( in float4 ProvinceOverlayColor, out float PreLightingBlend, out float PostLightingBlend )
		{
			PreLightingBlend = GB_PreLightingBlend * ProvinceOverlayColor.a;
			PostLightingBlend = GB_PostLightingBlend * ProvinceOverlayColor.a;
		}

		// This is a high-level convencience function that can be used if no overlay shader customization is required
		void GetProvinceOverlayAndBlend( in float2 NormalizedCoordinate, out float3 ProvinceOverlayColor, out float PreLightingBlend, out float PostLightingBlend )
		{
			float DistanceFieldValue = CalcDistanceFieldValue( NormalizedCoordinate );
			float4 ProvinceOverlayColorWithAlpha = CalcPrimaryProvinceOverlay( NormalizedCoordinate, DistanceFieldValue );

			// MOD(WC)
			WC_TryDiscardOverlayColor(ProvinceOverlayColorWithAlpha, NormalizedCoordinate);
			bool tiEnabled = WC_GetTerraIncognitaEnabled(float2( NormalizedCoordinate.x, 1.0 - NormalizedCoordinate.y ));

			if(!tiEnabled)
			{
                ApplySecondaryProvinceOverlay( NormalizedCoordinate, DistanceFieldValue, ProvinceOverlayColorWithAlpha );
                ApplyAlternateProvinceOverlay( NormalizedCoordinate, ProvinceOverlayColorWithAlpha );
			}
			// END MOD

			GetGradiantBorderBlendValues( ProvinceOverlayColorWithAlpha, PreLightingBlend, PostLightingBlend );
			ProvinceOverlayColor = ProvinceOverlayColorWithAlpha.rgb;
		}
	]]
}
