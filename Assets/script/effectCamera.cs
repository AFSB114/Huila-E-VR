using UnityEngine;
using UnityEngine.Playables;

public class CambiarCamaraPorTiempo : MonoBehaviour
{
    public GameObject xrRig;
    public GameObject Camera;
    public PlayableDirector VirtualCamera;

    void Start()
    {
        VirtualCamera.stopped += OnTimelineFinished;
    }

    void OnTimelineFinished(PlayableDirector obj)
    {
        xrRig.SetActive(true);
        Camera.SetActive(false);
    }
}
