
// SHADER 1: Para ver la imagen 360 desde ADENTRO
Shader "Custom/VR360PhotoInside"
{
    Properties {
        _Cube ("Cubemap", CUBE) = "" {}
        _RotationY ("Rotation Y (Degrees)", Range(0,360)) = 0
    }
    SubShader {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        Cull Front  // Solo renderiza caras internas
        Lighting Off
        ZWrite On
        ZTest LEqual
        
        Pass {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_instancing
            #pragma multi_compile __ UNITY_SINGLE_PASS_STEREO INSTANCING_ON
            #include "UnityCG.cginc"
            
            struct appdata {
                float4 vertex : POSITION;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float3 worldDir : TEXCOORD0;
                UNITY_VERTEX_OUTPUT_STEREO
            };

            samplerCUBE _Cube;
            float _RotationY;

            float3 RotateY(float3 dir, float angleDeg) {
                float angle = radians(angleDeg);
                float s = sin(angle);
                float c = cos(angle);
                float3x3 rotY = float3x3(c, 0, -s, 0, 1, 0, s, 0, c);
                return mul(rotY, dir);
            }

            v2f vert (appdata v) {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.worldDir = worldPos.xyz - _WorldSpaceCameraPos;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                float3 rotatedDir = RotateY(normalize(i.worldDir), _RotationY);
                return texCUBE(_Cube, rotatedDir);
            }
            ENDCG
        }
    }
}