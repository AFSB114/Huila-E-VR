using UnityEngine;

public class ReplaceGLTFMaterials : MonoBehaviour
{
    public Shader urpShader; // Por ejemplo: "Universal Render Pipeline/Lit"

    public void ReplaceMaterials(GameObject importedModel)
    {
        var renderers = importedModel.GetComponentsInChildren<Renderer>();
        foreach (var rend in renderers)
        {
            for (int i = 0; i < rend.materials.Length; i++)
            {
                Material newMat = new Material(urpShader);
                
                // Si quieres copiar la textura base del material glTF:
                if (rend.materials[i].HasProperty("_MainTex"))
                {
                    newMat.SetTexture("_BaseMap", rend.materials[i].GetTexture("_MainTex"));
                }

                rend.materials[i] = newMat;
            }
        }
    }
}
