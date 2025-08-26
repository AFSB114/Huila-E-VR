// Shader optimizado para pantallas de video en VR
Shader "Custom/VRVideoScreen"
{
    Properties {
        _MainTex ("Video Texture", 2D) = "black" {}
        _Brightness ("Brightness", Range(0.1, 3.0)) = 1.0
        _Contrast ("Contrast", Range(0.5, 2.0)) = 1.0
        _Saturation ("Saturation", Range(0.0, 2.0)) = 1.0
        _EmissionStrength ("Emission Strength", Range(0, 2)) = 0.5
        [Toggle] _FlipX ("Flip Horizontal", Float) = 0
        [Toggle] _FlipY ("Flip Vertical", Float) = 0
    }
    SubShader {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 200
        
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma multi_compile __ UNITY_SINGLE_PASS_STEREO INSTANCING_ON
            #include "UnityCG.cginc"
            
            struct appdata {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Brightness;
            float _Contrast;
            float _Saturation;
            float _EmissionStrength;
            float _FlipX;
            float _FlipY;

            v2f vert (appdata v) {
                v2f o;
                
                // Setup VR
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                
                // Aplicar transformaciones de UV y flips
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                
                if (_FlipX > 0.5) {
                    o.uv.x = 1.0 - o.uv.x;
                }
                if (_FlipY > 0.5) {
                    o.uv.y = 1.0 - o.uv.y;
                }
                
                // Para efectos de iluminación opcional
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.viewDir = normalize(_WorldSpaceCameraPos - worldPos);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                
                // Samplear el video
                fixed4 col = tex2D(_MainTex, i.uv);
                
                // Ajustes de imagen
                col.rgb *= _Brightness;
                col.rgb = pow(abs(col.rgb), _Contrast);
                
                // Ajuste de saturación
                float gray = dot(col.rgb, float3(0.299, 0.587, 0.114));
                col.rgb = lerp(gray, col.rgb, _Saturation);
                
                // Efecto de emisión para que se vea como pantalla real
                col.rgb += col.rgb * _EmissionStrength;
                
                // Efecto sutil de viewing angle (opcional)
                float viewAngle = abs(dot(normalize(i.worldNormal), normalize(i.viewDir)));
                col.rgb *= lerp(0.7, 1.0, viewAngle);
                
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}