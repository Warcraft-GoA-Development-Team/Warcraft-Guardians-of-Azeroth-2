# This file contains the portrait constant buffer definition from vanilla's jomini/portrait.shader .
# Any changes to said buffer must be applied to this file.

ConstantBuffer( 5 )
{
	float4 		vPaletteColorSkin;
	float4 		vPaletteColorEyes;
	float4 		vPaletteColorHair;
	float4		vSkinPropertyMult;
	float4		vEyesPropertyMult;
	float4		vHairPropertyMult;
	
	float4 		Light_Color_Falloff[3];
	float4 		Light_Position_Radius[3]
	float4 		Light_Direction_Type[3];
	float4 		Light_InnerCone_OuterCone_AffectedByShadows[3];
	
	int			DecalCount;
	int         PreSkinColorDecalCount
	int			TotalDecalCount;
	int 		_; // Alignment

	float4 		PatternColorOverrides[16];
	float4		CoaColor1;
	float4		CoaColor2;
	float4		CoaColor3;
	float4		CoaOffsetAndScale;

	float		HasDiffuseMapOverride;
	float		HasNormalMapOverride;
	float		HasPropertiesMapOverride;
};
