includes = {
	"cw/pdxmesh_buffers.fxh"
	"gh_portrait_constants.fxh"
	"gh_portrait_decals_shared.fxh"
}

PixelShader =
{
	TextureSampler tiMask
    {
        Index = 28
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

            float pandariaValue = GH_GetPandariaHiddenValue();

            if (pandariaValue > 0.5) {
                if ( tempp == 85 ) {
                    alpha = 0;
                }
            }
            else if (pandariaValue > 0.1 && pandariaValue < 0.5)
            {
                if ( tempp != 85 ) {
                    alpha = 0;
                }
            }

			return alpha;
		}
    ]]
}