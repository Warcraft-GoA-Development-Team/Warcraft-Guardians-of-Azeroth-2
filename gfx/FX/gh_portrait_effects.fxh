includes = {
	"cw/pdxgui.fxh"
	"gh_portrait_decal_data.fxh"
	"gh_markers.fxh"
}

PixelShader =
{
	Code [[

		//
		// Types
		//

		struct GH_SPortraitEffect
		{
			uint      Type;
			float4    Param;
			DecalData MarkerDecalData;
		};

		//
		// Interface
		//

		GH_SPortraitEffect GH_GetDefaultPortraitEffect()
		{
			DecalData MarkerDecalData;
			MarkerDecalData._DiffuseIndex        = 0;
			MarkerDecalData._NormalIndex         = 0;
			MarkerDecalData._PropertiesIndex     = 0;
			MarkerDecalData._BodyPartIndex       = 0;
			MarkerDecalData._DiffuseBlendMode    = 0;
			MarkerDecalData._NormalBlendMode     = 0;
			MarkerDecalData._PropertiesBlendMode = 0;
			MarkerDecalData._Weight              = 0.0f;
			MarkerDecalData._AtlasPos            = uint2(0, 0);
			MarkerDecalData._UVOffset            = float2(0.0f, 0.0f);
			MarkerDecalData._AtlasSize           = 0;

			GH_SPortraitEffect Effect;
			Effect.Type            = GH_PORTRAIT_EFFECT_TYPE_NONE;
			Effect.Param           = float4(0.0f, 0.0f, 0.0f, 0.0f);
			Effect.MarkerDecalData = MarkerDecalData;

			return Effect;
		}

		//
		// Interface
		//

		void GH_TryApplyStatueEffect(in GH_SPortraitEffect PortraitEffect, in float2 UV, inout float4 Diffuse, inout float3 Normal, inout float4 Properties)
		{
			if (PortraitEffect.Type != GH_PORTRAIT_EFFECT_TYPE_STATUE)
				return;

			if (GH_MarkerTexelEquals(PortraitEffect.Param, GH_MARKER_TOP_RIGHT_STATUE_GOLD))
			{
				Diffuse    = float4(1.0, 0.8, 0.2, 1.0);
				Properties = float4(0.0, 1.0, 1.0, 0.0);
			}
			else if (GH_MarkerTexelEquals(PortraitEffect.Param, GH_MARKER_TOP_RIGHT_STATUE_MARBLE))
			{
				Diffuse    = float4(0.5, 0.6, 0.4, 0.2);
				Properties = float4(0.0, 0.4, 0.25, 0.8);
			}
			else if (GH_MarkerTexelEquals(PortraitEffect.Param, GH_MARKER_TOP_RIGHT_STATUE_LIMESTONE))
			{
				Diffuse    = float4(0.9, 0.8, 0.7, 0.8);
				Properties = float4(0.0, 0.1, 0.0, 0.1);
			}
			else if (GH_MarkerTexelEquals(PortraitEffect.Param, GH_MARKER_TOP_RIGHT_STATUE_STONE))
			{
				Diffuse    = float4(0.495, 0.4, 0.279, 0.9);
				Properties = float4(0.0, 0.1, 0.0, 0.8);
			}
			else if (GH_MarkerTexelEquals(PortraitEffect.Param, GH_MARKER_TOP_RIGHT_STATUE_COPPER))
			{
				Diffuse    = float4(1.0, 0.3, 0.2, 1.0);
				Properties = float4(0.0, 1.0, 1.0, 0.0);
			}
			else if (GH_MarkerTexelEquals(PortraitEffect.Param, GH_MARKER_TOP_RIGHT_STATUE_COPPER_RUST))
			{
				Diffuse    = float4(0.2, 1.0, 0.7, 1.0);
				Properties = float4(0.0, 0.0, 0.0, 0.0);
			}
			else // Unrecognized material param
			{
				// Use some loud color like magenta to communicate the error
				Diffuse    = float4(1.0, 0.0, 1.0, 1.0);
				Properties = float4(1.0, 0.0, 0.0, 1.0);
			}
		}
	]]
}
