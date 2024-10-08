includes = {
	"cw/pdxmesh_buffers.fxh"
	"gh_portrait_constants.fxh"
	"gh_portrait_decals_shared.fxh"
}

PixelShader =
{
	TextureSampler tiMask
    {
        Index = 27
		MagFilter = "Point"
		MinFilter = "Point"
		MipFilter = "Point"
		SampleModeU = "Wrap"
		SampleModeV = "Border"
		Border_Color = { 0 0 0 0 }
        File = "gfx/map/surround_map/ti_mask.dds"
    }

    Code
    [[
		bool WC_GetTerraIncognitaEnabled( float2 UV )
		{
			bool isEnabled = false;
            float tiValue = PdxTex2D( tiMask, UV ).g;
            int tempp = int(tiValue*255);

            float pandariaValue = WC_GetPandariaHiddenValue();

            if (pandariaValue > 0.5)
            {
                if ( tempp == 85 )
                {
                    isEnabled = true;
                }
            }
            else if (pandariaValue > 0.1 && pandariaValue < 0.5)
            {
                if ( tempp != 85 ) {
                    isEnabled = true;
                }
            }

			return isEnabled;
		}

		float WC_GetTerraIncognitaAlpha( float2 UV, float4 OverlayColor )
		{
			float alpha = OverlayColor.a;

            if (WC_GetTerraIncognitaEnabled(UV))
            {
                alpha = 0;
            }

			return alpha;
		}
    ]]
}