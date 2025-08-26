using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR;

public class HandPresence : MonoBehaviour
{
    public GameObject handModelPrefab;
    public XRNode inputSource;

    private InputDevice device;
    private GameObject spawnedHandModel;
    private Animator handAnimator;
    
    // Start is called before the first frame update
    void Start()
    {
        tryInitialize();
    }

    void tryInitialize()
    {
        // Si el dispositivo ya está instanciado, no lo creamos de nuevo
        if (spawnedHandModel != null)
        {
            return;
        }

        // Obtener el dispositivo del nodo específico
        device = InputDevices.GetDeviceAtXRNode(inputSource);

        // Verificar si el dispositivo es válido
        //if (!device.isValid)
        //{
        //    Debug.LogError("Dispositivo no válido para el nodo: " + inputSource);
        //    return; // Si no es válido, salimos
        //}

        // Instanciamos el modelo de la mano solo si no existe ya uno
        spawnedHandModel = Instantiate(handModelPrefab, transform);
        handAnimator = spawnedHandModel.GetComponent<Animator>();
        spawnedHandModel.SetActive(true);
        updateHandAnimation();
    }

    void updateHandAnimation()
    {
        // Leer los valores de trigger y grip del dispositivo y actualizar la animación
        if (device.TryGetFeatureValue(CommonUsages.trigger, out float triggerValue))
        {
            handAnimator.SetFloat("Trigger", triggerValue);
        }
        else
        {
            handAnimator.SetFloat("Trigger", 0);
        }

        if (device.TryGetFeatureValue(CommonUsages.grip, out float gripValue))
        {
            handAnimator.SetFloat("Grip", gripValue);
        }
        else
        {
            handAnimator.SetFloat("Grip", 0);
        }
    }

    // Update is called once per frame
    void Update()
    {
        // Verificar si el dispositivo sigue siendo válido
        if (!device.isValid)
        {
            // Si el dispositivo ya no es válido, destruir el modelo anterior y reiniciar la creación
            Destroy(spawnedHandModel);
            spawnedHandModel = null;  // Limpiar la referencia para forzar una nueva instancia
            tryInitialize();  // Volver a intentar inicializar el dispositivo
        }
        else
        {
            updateHandAnimation();  // Actualizar la animación si el dispositivo sigue siendo válido
        }
    }
}
