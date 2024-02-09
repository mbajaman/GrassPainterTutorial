Shader "Custom/CustomUnlitShader"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1) 
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
            };

            float4 _BaseColor;

            v2f vert (appdata v)
            {
                v2f o; 
                if(v.vertexID < 3)
                {
                    o.vertex = UnityObjectToClipPos(v.vertex);
                    return o;
                }
                else 
                {
                    o.vertex = float4(0, 0, 0, 0);
                    return o;
                }
                
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _BaseColor;
            }
            ENDCG
        }
    }
}
