Shader "Roystan/Toon"
{
	Properties
	{
		_Color("Color", Color) = (0.5, 0.65, 1, 1)
		_MainTex("Main Texture", 2D) = "white" {}	

		[HDR]
		_AmbientColor("Ambient Color", Color) = (0.4, 0.4, 0.4, 1)

		[HDR]
		_SpecularColor("Specular Color", Color) = (0.9, 0.9, 0.9, 1)
		_Glossiness("Glossiness", Float) = 32

		[HDR]
		_RimColor("Rim Color", Color) = (1, 1, 1, 1)
		_RimAmount("Rim Amount", Range(0,1)) = 0.716
		_RimThreshold("Rim Threshold", Range(0, 1)) = 0.1

	}
	SubShader
	{
		Pass
		{
			Tags
			{
				"LightMode" = "UniversalForward"
				"PassFlags" = "OnlyDirectional"
				"RenderPipeline" = "UniversalPipeline"
			}

			HLSLPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_fwdbase
			
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"

			struct Attributes
			{
				float4 vertex : POSITION;				
				float4 uv : TEXCOORD0;
				float3 normal : NORMAL;
			};

			struct Varyings
			{
				float4 pos : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 worldNormal : NORMAL;
				float3 viewDir : TEXCOORD1;
				float4 shadowCoord : TEXCOORD2;
			};

			TEXTURE2D(_MainTex);
			SAMPLER(sampler_MainTex);

			CBUFFER_START(UnityPerMaterial)
			float4 _MainTex_ST;
			CBUFFER_END
			
			Varyings vert (Attributes IN)
			{
				Varyings OUT;
				OUT.pos = TransformObjectToHClip(IN.vertex.xyz);
				OUT.uv = TRANSFORM_TEX(IN.uv, _MainTex);
				OUT.worldNormal = TransformObjectToWorldNormal(IN.normal);
				OUT.viewDir = WorldSpaceViewDir(IN.vertex);
				OUT.shadowCoord = GetShadowCoord(IN.)
				TRANSFER_SHADOW(OUT);
				return OUT;
			}

			CBUFFER_START(UnityPerMaterial)
			float4 _Color;
			float4 _AmbientColor;
			float4 _SpecularColor;
			float _Glossiness;
			float4 _RimColor;
			float _RimAmount;
			float _RimThreshold; 
			CBUFFER_END

			float4 frag (Varyings IN) : SV_Target
			{
				float3 normal = normalize(IN.worldNormal);
				float4 NdotL = dot(_WorldSpaceLightPos0, normal);
				// float lightIntensity = NdotL > 0 ? 1 : 0;
				float shadow = SHADOW_ATTENUATION(IN);
				float lightIntensity = smoothstep(0, 0.01, NdotL * shadow);
				float4 light = lightIntensity * _LightColor0;

				float3 viewDir = normalize(IN.viewDir);
				float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
				float NdotH = dot(normal, halfVector);
				float specularIntensity = pow(NdotH * lightIntensity, _Glossiness * _Glossiness);
				float specularIntensitySmooth = smoothstep(0.005, 0.01, specularIntensity);
				float4 specular = specularIntensitySmooth * _SpecularColor;

				// Rim Lighting
				float4 rimDot = 1 - dot(viewDir, normal);
				float4 rimIntensity = rimDot * pow(NdotL, _RimThreshold);
				rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimIntensity);
				float4 rim = rimIntensity * _RimColor;

				float4 sample = tex2D(_MainTex, IN.uv);

				return _Color * sample * (_AmbientColor + light + specular + rim);
			}
			ENDHLSL
		}

		UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
	}
}