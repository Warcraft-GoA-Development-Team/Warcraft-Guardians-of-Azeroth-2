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
        float tiValue = PdxTex2D( tiMask, UV ).g;
        float tiAlpha = PdxTex2D( tiMask, UV ).a;
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
            if ( tempp != 85 || (tempp == 85 && tiAlpha != 1.0 ) ) {
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

    float WC_GetTIProximityToAdjacentRegion(float2 WorldSpacePosXZ)
    {
        float2 MapUV = WorldSpacePosXZ * WorldSpaceToTerrain0To1;
        MapUV.y = 1.0f - MapUV.y;
        float tiValue = PdxTex2D( tiMask, MapUV ).g;
        float tiAlpha = PdxTex2D( tiProximity, MapUV ).a;
        int tempp = int(tiValue*255);

        float pandariaValue = WC_GetPandariaHiddenValue();

        if (pandariaValue > 0.5)
        {
            //if ( tempp == 85 )
            //{
            #ifdef PIXEL_SHADER
                return PdxTex2D(tiMask, MapUV).a;
            #else
                return PdxTex2DLod0(tiMask, MapUV).a;
            #endif
            //}
        }
        else if (pandariaValue > 0.1 && pandariaValue < 0.5)
        {
            if ( tempp != 85 || (tempp == 85 && tiAlpha != 1.0 ) )
            {
            #ifdef PIXEL_SHADER
                return 1.0 - PdxTex2D(tiMask, MapUV).a;
            #else
                return 1.0 - PdxTex2DLod0(tiMask, MapUV).a;
            #endif
            }
        }

        return 1.0;
    }

	float WC_GetTIAdjacentRegionBlendAmount(float2 WorldSpacePosXZ, float ProximityRange)
	{
		float Proximity         = WC_GetTIProximityToAdjacentRegion(WorldSpacePosXZ);
		float AdjustedProximity = saturate((Proximity - (1.0f - ProximityRange))/ProximityRange);

		return 0.5f*AdjustedProximity;
	}
]]