using UnityEditor;
using UnityEngine;

namespace SkyLoft.Editor
{
    public sealed class StylizedWaterShaderGUI : ShaderGUI
    {
        private static bool surfaceInputs = true;
        private static bool mainToggles = true;
        private static bool color = true;
        private static bool texture = true;
        private static bool foam = true;
        private static bool waves = true;
        private static bool refraction = true;

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            EditorGUI.BeginChangeCheck();

            DrawSurfaceInputs(materialEditor, properties);
            DrawMainToggles(materialEditor, properties);
            DrawColor(materialEditor, properties);
            DrawTexture(materialEditor, properties);
            DrawFoam(materialEditor, properties);
            DrawWaves(materialEditor, properties);
            DrawRefraction(materialEditor, properties);

            EditorGUILayout.Space(6);
            materialEditor.RenderQueueField();
            materialEditor.EnableInstancingField();

            if (EditorGUI.EndChangeCheck())
            {
                foreach (Object target in materialEditor.targets)
                {
                    if (target is Material material)
                    {
                        material.SetShaderPassEnabled("DepthOnly", false);
                    }
                }
            }
        }

        private static void DrawSurfaceInputs(MaterialEditor editor, MaterialProperty[] properties)
        {
            if (!Foldout("Surface Inputs", ref surfaceInputs))
            {
                return;
            }

            DrawTextureWithScaleOffset(editor, Find("_NormalTexture1", properties), "normal Texture1");
            DrawTextureWithScaleOffset(editor, Find("_NormalTexture2", properties), "normal texture 2");
            DrawTexture(editor, Find("_FoamTexture", properties), "foam Texture");
            DrawTexture(editor, Find("_CausticsTexture", properties), "caustics Texture");
        }

        private static void DrawMainToggles(MaterialEditor editor, MaterialProperty[] properties)
        {
            if (!Foldout("Main", ref mainToggles))
            {
                return;
            }

            DrawProperty(editor, Find("_Wave", properties), "wave");
            DrawProperty(editor, Find("_Foam", properties), "foam");
            DrawProperty(editor, Find("_Smoothness", properties), "Smoothness");
            DrawProperty(editor, Find("_Alpha", properties), "Alpha");
        }

        private static void DrawColor(MaterialEditor editor, MaterialProperty[] properties)
        {
            if (!Foldout("color", ref color))
            {
                return;
            }

            DrawProperty(editor, Find("_NormalStrength", properties), "normal strength");
            DrawProperty(editor, Find("_Depth", properties), "Depth");
            DrawProperty(editor, Find("_ColorStrength", properties), "strength");
            DrawProperty(editor, Find("_DeepWaterColor", properties), "deep_water_color");
            DrawProperty(editor, Find("_ShallowWaterColor", properties), "shallow_water_color");
            DrawProperty(editor, Find("_CausticsAlpha", properties), "caustics Alpha");
            DrawProperty(editor, Find("_CausticsScale", properties), "caustics scale");
            DrawProperty(editor, Find("_CausticsStrength", properties), "caustics Strenght");
            DrawProperty(editor, Find("_CausticsSpeed", properties), "caustics Speed");
            DrawProperty(editor, Find("_RimColor", properties), "Rim color");
            DrawProperty(editor, Find("_RimStrength", properties), "Rim strength");
        }

        private static void DrawTexture(MaterialEditor editor, MaterialProperty[] properties)
        {
            if (!Foldout("Texture", ref texture))
            {
                return;
            }

            DrawProperty(editor, Find("_WaterMovementSpeed", properties), "water_movement_speed");
            DrawProperty(editor, Find("_TextureScale", properties), "Texture_scale");
        }

        private static void DrawFoam(MaterialEditor editor, MaterialProperty[] properties)
        {
            if (!Foldout("foam", ref foam))
            {
                return;
            }

            DrawProperty(editor, Find("_FoamSpeed", properties), "foam speed");
            DrawProperty(editor, Find("_FoamScale", properties), "foam scale");
            DrawProperty(editor, Find("_FoamDepth", properties), "Foam depth");
            DrawProperty(editor, Find("_FoamCutoff", properties), "foam cutoff");
            DrawProperty(editor, Find("_FoamColor", properties), "foam color");
        }

        private static void DrawWaves(MaterialEditor editor, MaterialProperty[] properties)
        {
            if (!Foldout("waves", ref waves))
            {
                return;
            }

            DrawProperty(editor, Find("_WaveSpeed", properties), "WaveSpeed");
            DrawProperty(editor, Find("_HighFrequency", properties), "highFrequenvy");
            DrawProperty(editor, Find("_WaveAmplitude", properties), "Wave amplitude");
        }

        private static void DrawRefraction(MaterialEditor editor, MaterialProperty[] properties)
        {
            if (!Foldout("Water refraction", ref refraction))
            {
                return;
            }

            DrawProperty(editor, Find("_RefractionStrength", properties), "refraction strenght");
            DrawProperty(editor, Find("_RefractionScale", properties), "refraction scale");
            DrawProperty(editor, Find("_RefractionSpeed", properties), "refraction Speed");
        }

        private static bool Foldout(string label, ref bool state)
        {
            EditorGUILayout.Space(4);
            state = EditorGUILayout.Foldout(state, label, true, EditorStyles.foldoutHeader);
            return state;
        }

        private static MaterialProperty Find(string name, MaterialProperty[] properties)
        {
            return FindProperty(name, properties, false);
        }

        private static void DrawTextureWithScaleOffset(MaterialEditor editor, MaterialProperty property, string label)
        {
            if (property == null)
            {
                return;
            }

            editor.TexturePropertySingleLine(new GUIContent(label), property);
            editor.TextureScaleOffsetProperty(property);
        }

        private static void DrawTexture(MaterialEditor editor, MaterialProperty property, string label)
        {
            if (property == null)
            {
                return;
            }

            editor.TexturePropertySingleLine(new GUIContent(label), property);
        }

        private static void DrawProperty(MaterialEditor editor, MaterialProperty property, string label)
        {
            if (property == null)
            {
                return;
            }

            editor.ShaderProperty(property, new GUIContent(label));
        }
    }
}
