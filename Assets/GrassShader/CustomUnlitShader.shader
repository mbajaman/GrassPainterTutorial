Shader "Custom/CustomUnlitShader"
{
    Properties
    {
		[Header(Shading)]
        _TopColor("Top Color", Color) = (0,0,0,0)
		_BottomColor("Bottom Color", Color) = (0,0,0,0)
		_TranslucentGain("Translucent Gain", Range(0,1)) = 0.5
    }

	CGINCLUDE
	#include "UnityCG.cginc"
	#include "Autolight.cginc"

	struct geometryOutput
	{
		float4 pos : SV_POSITION;
	};

	[maxvertexcount(3)]
	void geo(triangle float4 IN[3] : SV_POSITION, inout TriangleStream<geometryOutput> triStream)
	{
		geometryOutput o;
		float3 pos = IN[0];

		o.pos = UnityObjectToClipPos(pos + float4(0.5, 0, 0, 1));
		triStream.Append(o);

		o.pos = UnityObjectToClipPos(pos + float4(-0.5, 0, 0, 1));
		triStream.Append(o);

		o.pos = UnityObjectToClipPos(pos + float4(0, 1, 0, 1));
		triStream.Append(o);
	}

	float4 vert(float4 vertex : POSITION) : SV_POSITION
	{
		return vertex;
	}
	ENDCG

    SubShader
    {
		Cull Off

        Pass
        {
			Tags
			{
				"RenderType" = "Opaque"
				"LightMode" = "ForwardBase"
			}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			#pragma geometry geo
			#pragma target 4.6

			#include "Lighting.cginc"

			float4 _TopColor;
			float4 _BottomColor;
			float _TranslucentGain;

			float4 frag (float4 vertex : SV_POSITION, fixed facing : VFACE) : SV_Target
            {	
				return float4(1, 1, 1, 1);
            }
            ENDCG
        }
    }
}