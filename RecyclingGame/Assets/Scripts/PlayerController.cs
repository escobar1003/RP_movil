using UnityEngine;

public class PlayerController : MonoBehaviour
{
    [Header("Movement")]
    public float moveSpeed = 8f;
    public float leftLimit = -2.5f;
    public float rightLimit = 2.5f;

    [Header("Bins")]
    public RecyclingBin plasticBin;
    public RecyclingBin glassBin;
    public RecyclingBin canBin;

    [Header("Bin Layout")]
    public float binSpacing = 2f;
    public float binYPosition = -4f;

    private Vector3 touchStartWorld;
    private float groupCenterOnTouch;
    private bool isDragging = false;

    void Start()
    {
        Input.gyro.enabled = true;
        PositionBins();
    }

    void PositionBins()
    {
        if (plasticBin != null)
            plasticBin.transform.position = new Vector3(-binSpacing, binYPosition, 0);
        if (glassBin != null)
            glassBin.transform.position = new Vector3(0, binYPosition, 0);
        if (canBin != null)
            canBin.transform.position = new Vector3(binSpacing, binYPosition, 0);
    }

    float GetGroupCenter()
    {
        if (glassBin != null) return glassBin.transform.position.x;
        if (plasticBin != null) return plasticBin.transform.position.x + binSpacing;
        return 0;
    }

    void Update()
    {
        if (GameManager.Instance != null && GameManager.Instance.isGameOver)
            return;

        HandleTouchInput();
        HandleGyroInput();
    }

    void HandleTouchInput()
    {
        if (Input.touchCount > 0)
        {
            Touch touch = Input.GetTouch(0);
            ProcessDrag(touch.position, touch.phase);
        }
        else if (Input.GetMouseButton(0))
        {
            Vector3 pos = Input.mousePosition;
            if (Input.GetMouseButtonDown(0))
                ProcessDrag(pos, TouchPhase.Began);
            else if (Input.GetMouseButtonUp(0))
                ProcessDrag(pos, TouchPhase.Ended);
            else
                ProcessDrag(pos, TouchPhase.Moved);
        }
    }

    void ProcessDrag(Vector3 screenPos, TouchPhase phase)
    {
        switch (phase)
        {
            case TouchPhase.Began:
                touchStartWorld = Camera.main.ScreenToWorldPoint(screenPos);
                groupCenterOnTouch = GetGroupCenter();
                isDragging = true;
                break;

            case TouchPhase.Moved:
            case TouchPhase.Stationary:
                if (isDragging)
                {
                    Vector3 currentWorld = Camera.main.ScreenToWorldPoint(screenPos);
                    float deltaX = currentWorld.x - touchStartWorld.x;
                    float newCenter = Mathf.Clamp(groupCenterOnTouch + deltaX, leftLimit, rightLimit);
                    MoveBinsToX(newCenter);
                }
                break;

            case TouchPhase.Ended:
            case TouchPhase.Canceled:
                isDragging = false;
                break;
        }
    }

    void HandleGyroInput()
    {
        if (isDragging) return;

        float tilt = Input.acceleration.x;
        if (Mathf.Abs(tilt) < 0.05f) return;

        float move = tilt * moveSpeed * Time.deltaTime;
        float center = GetGroupCenter();
        float newCenter = Mathf.Clamp(center + move, leftLimit, rightLimit);
        MoveBinsToX(newCenter);
    }

    void MoveBinsToX(float centerX)
    {
        if (plasticBin != null)
        {
            Vector3 p = plasticBin.transform.position;
            plasticBin.transform.position = new Vector3(centerX - binSpacing, p.y, p.z);
        }
        if (glassBin != null)
        {
            Vector3 p = glassBin.transform.position;
            glassBin.transform.position = new Vector3(centerX, p.y, p.z);
        }
        if (canBin != null)
        {
            Vector3 p = canBin.transform.position;
            canBin.transform.position = new Vector3(centerX + binSpacing, p.y, p.z);
        }
    }
}
