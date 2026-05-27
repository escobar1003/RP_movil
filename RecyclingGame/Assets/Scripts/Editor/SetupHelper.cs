using UnityEditor;
using UnityEngine;

public class SetupHelper : EditorWindow
{
    [MenuItem("Tools/Setup Recycling Game")]
    static void SetupScene()
    {
        GameObject bootstrapper = GameObject.Find("Bootstrapper");
        if (bootstrapper == null)
        {
            bootstrapper = new GameObject("Bootstrapper");
            bootstrapper.AddComponent<GameBootstrapper>();
            Debug.Log("Bootstrapper created. Press Play to auto-setup the game.");
        }
        else
        {
            Debug.Log("Bootstrapper already exists.");
        }

        Selection.activeGameObject = bootstrapper;
    }

    [MenuItem("Tools/Clear Bootstrapper")]
    static void ClearSetup()
    {
        GameObject bootstrapper = GameObject.Find("Bootstrapper");
        if (bootstrapper != null)
        {
            DestroyImmediate(bootstrapper);
            Debug.Log("Bootstrapper removed.");
        }
    }
}
