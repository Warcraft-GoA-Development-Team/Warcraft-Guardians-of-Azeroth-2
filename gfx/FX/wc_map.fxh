includes = {
	"cw/pdxmesh_buffers.fxh"
	"gh_portrait_constants.fxh"
	"gh_portrait_decals_shared.fxh"
}

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

TextureSampler tiProximity
{
    Index = 28
    MagFilter = "Point"
    MinFilter = "Point"
    MipFilter = "Point"
    SampleModeU = "Wrap"
    SampleModeV = "Border"
    Border_Color = { 0 0 0 0 }
    File = "gfx/map/surround_map/ti_proximity.dds"
}

Code
[[
    bool WC_GetTerraIncognitaEnabled( float2 UV )
    {
        bool isEnabled = false;
        float tiValue;
        #ifdef PIXEL_SHADER
            tiValue = PdxTex2D( tiMask, UV ).g;
        #else
            tiValue = PdxTex2DLod0( tiMask, UV ).g;
        #endif
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
            if ( tempp != 85 )
            {
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

    float WC_GetTIProximityToAdjacentRegion(float2 UV)
    {
        float tiAlpha;
        #ifdef PIXEL_SHADER
            tiAlpha = 1.0 - PdxTex2D(tiProximity, UV).a;
        #else
            tiAlpha = 1.0 - PdxTex2DLod0(tiProximity, UV).a;
        #endif

        if (WC_GetPandariaHiddenValue() < 0.1)
        {
            return 1.0;
        }

        bool tiEnabled = WC_GetTerraIncognitaEnabled(UV);
        if (tiEnabled && tiAlpha > 0)
        {
            return tiAlpha;
        }

        return 1.0;
    }
]]