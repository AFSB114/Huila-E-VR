using UnityEngine;
using UnityEngine.XR;
using UnityEngine.XR.Interaction.Toolkit;
using Unity.XR.CoreUtils;

public class ContinousMovement : MonoBehaviour
{
    public XRNode inputSource = XRNode.LeftHand;
    public float speed = 3.0f;

    // --- Variables de gravedad manual eliminadas ---
    
    private XROrigin rig;
    private Vector2 inputAxis;
    private Rigidbody characterRigidbody;
    private CapsuleCollider characterCollider;

    void Start()
    {
        characterRigidbody = GetComponent<Rigidbody>();
        characterCollider = GetComponent<CapsuleCollider>();
        rig = GetComponent<XROrigin>();
    }

    void Update()
    {
        // Leemos el input del joystick
        InputDevice device = InputDevices.GetDeviceAtXRNode(inputSource);
        device.TryGetFeatureValue(CommonUsages.primary2DAxis, out inputAxis);
    }

    void FixedUpdate()
    {
        // Aún necesitamos que el collider siga al casco
        CapsuleFollowHeadset();

        // Calculamos la dirección del movimiento horizontal
        Quaternion headYaw = Quaternion.Euler(0, rig.Camera.transform.eulerAngles.y, 0);
        Vector3 direction = headYaw * new Vector3(inputAxis.x, 0, inputAxis.y);

        // --- Lógica de movimiento principal ---
        // Obtenemos la velocidad horizontal deseada
        Vector3 horizontalVelocity = direction * speed;

        // Combinamos nuestra velocidad horizontal con la velocidad vertical actual del Rigidbody (la que aplica la gravedad de Unity)
        characterRigidbody.velocity = new Vector3(horizontalVelocity.x, characterRigidbody.velocity.y, horizontalVelocity.z);
    }

    // Esta función sigue siendo necesaria para que el collider se ajuste al jugador
    void CapsuleFollowHeadset()
    {
        characterCollider.height = rig.CameraInOriginSpaceHeight + 0.1f;
        Vector3 capsuleCenter = transform.InverseTransformPoint(rig.Camera.transform.position);
        characterCollider.center = new Vector3(capsuleCenter.x, characterCollider.height / 2, capsuleCenter.z);
    }
}