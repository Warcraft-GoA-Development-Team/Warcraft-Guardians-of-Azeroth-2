
PixelShader =
{
	TextureSampler tiMask
    {
        Index = 12
        MagFilter = "Linear"
		MinFilter = "Linear"
		MipFilter = "Linear"
		SampleModeU = "Clamp"
		SampleModeV = "Wrap"
		Border_Color = { 1 1 1 1 }
        File = "gfx/map/surround_map/ti_mask.dds"

    }

    Code
    [[
		float WC_GetTerraIncognitaAlpha( float2 UV, float4 OverlayColor )
		{
			float alpha = OverlayColor.a;
            float tiValue = PdxTex2D( tiMask, UV ).g;
            int tempp = int(tiValue*255);

            if ( tempp == 85 ) {
                #ifdef ti_pandaria
                    alpha = 0;
                #endif
            }

			return alpha;
		}
    ]]
}