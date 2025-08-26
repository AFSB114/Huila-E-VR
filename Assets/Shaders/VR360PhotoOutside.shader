// SHADER 2: Para ver color sólido desde AFUERA
Shader "Custom/VR360PhotoOutside"
{
    Properties {
        _Color ("Outside Color", Color) = (0.5, 0.5, 0.5, 1)
        _Metallic ("Metallic", Range(0,1)) = 0
        _Smoothness ("Smoothness", Range(0,1)) = 0.5
    }
    SubShader {
        Tags { "RenderType"="Opaque" "Queue"="Geometry+1" }
        Cull Back  // Solo renderiza caras externas
        Lighting On
        ZWrite On
        ZTest LEqual
        
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma multi_compile __ UNITY_SINGLE_PASS_STEREO INSTANCING_ON
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            
            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            fixed4 _Color;
            float _Metallic;
            float _Smoothness;

            v2f vert (appdata v) {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                
                // Iluminación básica
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float NdotL = max(0, dot(normalize(i.worldNormal), lightDir));
                
                fixed4 col = _Color;
                col.rgb *= NdotL * 0.5 + 0.5; // Sombreado suave
                
                return col;
            }
            ENDCG
        }
    }
}