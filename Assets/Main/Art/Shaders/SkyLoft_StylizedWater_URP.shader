Shader "SkyLoft/URP/Stylized Water"
{
    Properties
    {
        [Header(Surface Inputs)]
        [Normal] _NormalTexture1 ("normal Texture1", 2D) = "bump" {}
        [Normal] _NormalTexture2 ("normal texture 2", 2D) = "bump" {}
        [NoScaleOffset] _FoamTexture ("foam Texture", 2D) = "white" {}
        [NoScaleOffset] _CausticsTexture ("caustics Texture", 2D) = "black" {}

        [Header(Main Toggles)]
        [Toggle] _Wave ("wave", Float) = 1
        [Toggle] _Foam ("foam", Float) = 1
        _Smoothness ("Smoothness", Range(0, 1)) = 0.9
        _Alpha ("Alpha", Range(0, 1)) = 0.72

        [Header(Color)]
        _NormalStrength ("normal strength", Range(0, 2)) = 0.6
        _Depth ("Depth", Range(0.01, 30)) = 7
        _ColorStrength ("strength", Range(0, 2)) = 1
        _DeepWaterColor ("deep_water_color", Color) = (0.02, 0.35, 0.42, 1)
        _ShallowWaterColor ("shallow_water_color", Color) = (0.05, 0.75, 0.78, 1)
        _CausticsAlpha ("caustics Alpha", Range(0, 2)) = 1.3
        _CausticsScale ("caustics scale", Float) = 0.4
        _CausticsStrength ("caustics Strenght", Range(0, 4)) = 1.98
        _CausticsSpeed ("caustics Speed", Float) = 1
        _RimColor ("Rim color", Color) = (1, 1, 1, 1)
        _RimStrength ("Rim strength", Range(0, 25)) = 3

        [Header(Texture)]
        _WaterMovementSpeed ("water_movement_speed", Float) = 10
        _TextureScale ("Texture_scale", Float) = 0.1

        [Header(Foam)]
        _FoamSpeed ("foam speed", Float) = 0.5
        _FoamScale ("foam scale", Float) = 0.02
        _FoamDepth ("Foam depth", Range(0.001, 5)) = 1.05
        _FoamCutoff ("foam cutoff", Range(0, 1)) = 0.58
        _FoamColor ("foam color", Color) = (1, 1, 1, 1)

        [Header(Waves)]
        _WaveSpeed ("WaveSpeed", Float) = 0.9
        _HighFrequency ("highFrequenvy", Float) = 0.62
        _WaveAmplitude ("Wave amplitude", Float) = 0.3

        [Header(Water Refraction)]
        _RefractionStrength ("refraction strenght", Range(0, 1)) = 0.12
        _RefractionScale ("refraction scale", Float) = 7.3
        _RefractionSpeed ("refraction Speed", Float) = 4.34
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
        }

        Pass
        {
            Name "ForwardWater"
            Tags { "LightMode" = "UniversalForward" }

            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Back

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex Vert
            #pragma fragment Frag
            #pragma multi_compile_fog
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareOpaqueTexture.hlsl"

            TEXTURE2D(_NormalTexture1);
            SAMPLER(sampler_NormalTexture1);
            TEXTURE2D(_NormalTexture2);
            SAMPLER(sampler_NormalTexture2);
            TEXTURE2D(_FoamTexture);
            SAMPLER(sampler_FoamTexture);
            TEXTURE2D(_CausticsTexture);
            SAMPLER(sampler_CausticsTexture);

            CBUFFER_START(UnityPerMaterial)
                float4 _NormalTexture1_ST;
                float4 _NormalTexture2_ST;
                float _Wave;
                float _Foam;
                float _Smoothness;
                float _Alpha;
                float _NormalStrength;
                float _Depth;
                float _ColorStrength;
                float4 _DeepWaterColor;
                float4 _ShallowWaterColor;
                float _CausticsAlpha;
                float _CausticsScale;
                float _CausticsStrength;
                float _CausticsSpeed;
                float4 _RimColor;
                float _RimStrength;
                float _WaterMovementSpeed;
                float _TextureScale;
                float _FoamSpeed;
                float _FoamScale;
                float _FoamDepth;
                float _FoamCutoff;
                float4 _FoamColor;
                float _WaveSpeed;
                float _HighFrequency;
                float _WaveAmplitude;
                float _RefractionStrength;
                float _RefractionScale;
                float _RefractionSpeed;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 uv : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 positionWS : TEXCOORD0;
                float3 normalWS : TEXCOORD1;
                float3 tangentWS : TEXCOORD2;
                float3 bitangentWS : TEXCOORD3;
                float2 uv : TEXCOORD4;
                float4 screenPos : TEXCOORD5;
                float fogCoord : TEXCOORD6;
            };

            float2 RotateUV(float2 uv, float angle)
            {
                float s;
                float c;
                sincos(angle, s, c);
                return float2(uv.x * c - uv.y * s, uv.x * s + uv.y * c);
            }

            Varyings Vert(Attributes input)
            {
                Varyings output;

                float3 positionOS = input.positionOS.xyz;
                if (_Wave > 0.5)
                {
                    float waveTime = _Time.y * _WaveSpeed;
                    float waveA = sin(positionOS.x * _HighFrequency + waveTime);
                    float waveB = cos(positionOS.z * (_HighFrequency * 0.83) + waveTime * 1.17);
                    positionOS.y += (waveA + waveB) * 0.5 * _WaveAmplitude;
                }

                VertexPositionInputs positionInputs = GetVertexPositionInputs(positionOS);
                VertexNormalInputs normalInputs = GetVertexNormalInputs(input.normalOS, input.tangentOS);

                output.positionCS = positionInputs.positionCS;
                output.positionWS = positionInputs.positionWS;
                output.normalWS = normalInputs.normalWS;
                output.tangentWS = normalInputs.tangentWS;
                output.bitangentWS = normalInputs.bitangentWS;
                output.uv = input.uv;
                output.screenPos = ComputeScreenPos(positionInputs.positionCS);
                output.fogCoord = ComputeFogFactor(positionInputs.positionCS.z);

                return output;
            }

            half4 Frag(Varyings input) : SV_Target
            {
                float2 screenUV = input.screenPos.xy / input.screenPos.w;
                float2 normalFlowA = float2(0.035, 0.02) * _Time.y * _WaterMovementSpeed;
                float2 normalFlowB = float2(-0.02, 0.03) * _Time.y * _WaterMovementSpeed;
                float2 normalUV1 = TRANSFORM_TEX(input.uv, _NormalTexture1) + normalFlowA;
                float2 normalUV2 = TRANSFORM_TEX(input.uv, _NormalTexture2) + normalFlowB;

                half3 normalTS1 = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalTexture1, sampler_NormalTexture1, normalUV1), _NormalStrength);
                half3 normalTS2 = UnpackNormalScale(SAMPLE_TEXTURE2D(_NormalTexture2, sampler_NormalTexture2, normalUV2), _NormalStrength * 0.65);
                half3 normalTS = normalize(half3(normalTS1.xy + normalTS2.xy, normalTS1.z * normalTS2.z));

                half3x3 tangentToWorld = half3x3(
                    normalize(input.tangentWS),
                    normalize(input.bitangentWS),
                    normalize(input.normalWS)
                );
                half3 normalWS = normalize(TransformTangentToWorld(normalTS, tangentToWorld));
                half3 viewDirWS = normalize(GetCameraPositionWS() - input.positionWS);

                float rawSceneDepth = SampleSceneDepth(screenUV);
                float sceneEyeDepth = LinearEyeDepth(rawSceneDepth, _ZBufferParams);
                float surfaceEyeDepth = max(input.positionCS.w, 0.0001);
                float waterDepth = max(sceneEyeDepth - surfaceEyeDepth, 0.0);
                float depthBlend = saturate(waterDepth / max(_Depth, 0.001));

                half3 waterColor = lerp(_ShallowWaterColor.rgb, _DeepWaterColor.rgb, depthBlend) * _ColorStrength;

                float scale = max(_TextureScale, 0.0001);
                float2 causticsUV = input.positionWS.xz * max(_CausticsScale, 0.0001) * scale;
                causticsUV += _Time.y * _CausticsSpeed * float2(0.04, -0.035);
                half causticsA = SAMPLE_TEXTURE2D(_CausticsTexture, sampler_CausticsTexture, causticsUV).r;
                half causticsB = SAMPLE_TEXTURE2D(_CausticsTexture, sampler_CausticsTexture, RotateUV(causticsUV * 1.23, 1.57)).g;
                half caustics = saturate((causticsA + causticsB) * 0.5) * (1.0 - depthBlend) * _CausticsAlpha;
                waterColor += caustics * _CausticsStrength;

                float2 refractionUV = input.positionWS.xz * max(_RefractionScale, 0.0001) * 0.01;
                refractionUV += _Time.y * _RefractionSpeed * float2(0.03, 0.02);
                half refractionNoise = SAMPLE_TEXTURE2D(_NormalTexture1, sampler_NormalTexture1, refractionUV).r - 0.5;
                float2 refractedScreenUV = screenUV + (normalWS.xz + refractionNoise) * (_RefractionStrength * 0.035);
                half3 sceneColor = SampleSceneColor(refractedScreenUV);
                waterColor = lerp(waterColor, sceneColor, saturate(_RefractionStrength) * saturate(1.0 - depthBlend * 0.5));

                Light mainLight = GetMainLight();
                half ndotl = saturate(dot(normalWS, mainLight.direction));
                half toonLight = 0.68 + smoothstep(0.2, 0.78, ndotl) * 0.32;
                half3 halfDir = normalize(mainLight.direction + viewDirWS);
                half specular = pow(saturate(dot(normalWS, halfDir)), lerp(16.0, 256.0, _Smoothness)) * _Smoothness;
                waterColor = waterColor * toonLight * mainLight.color + specular * 0.35;

                half rim = pow(1.0 - saturate(dot(viewDirWS, normalWS)), 2.0) * _RimStrength;
                waterColor += _RimColor.rgb * rim * _RimColor.a;

                float2 foamUV = input.positionWS.xz * max(_FoamScale, 0.0001) * scale;
                foamUV += _Time.y * _FoamSpeed * float2(-0.06, 0.05);
                half foamNoise = SAMPLE_TEXTURE2D(_FoamTexture, sampler_FoamTexture, foamUV).r;
                half edgeFoam = 1.0 - smoothstep(0.0, max(_FoamDepth, 0.001), waterDepth);
                half textureFoam = smoothstep(_FoamCutoff, 1.0, foamNoise);
                half foamMask = (_Foam > 0.5) ? saturate(edgeFoam * textureFoam) : 0.0;
                waterColor = lerp(waterColor, _FoamColor.rgb, foamMask * _FoamColor.a);

                half alpha = saturate(_Alpha + foamMask * 0.25 + rim * 0.02);
                waterColor = MixFog(waterColor, input.fogCoord);

                return half4(waterColor, alpha);
            }
            ENDHLSL
        }
    }

    CustomEditor "SkyLoft.Editor.StylizedWaterShaderGUI"
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
}
