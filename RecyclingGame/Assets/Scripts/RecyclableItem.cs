using UnityEngine;

public class RecyclableItem : MonoBehaviour
{
    public RecyclableType itemType;
    public int points = 10;
    public float fallSpeed = 2f;
    public SpriteRenderer spriteRenderer;
    public TrailRenderer trailRenderer;

    private Rigidbody2D rb;

    void Awake()
    {
        rb = GetComponent<Rigidbody2D>();
        if (rb == null)
            rb = gameObject.AddComponent<Rigidbody2D>();

        rb.gravityScale = 0;
        rb.constraints = RigidbodyConstraints2D.FreezePositionX;
    }

    void Start()
    {
        rb.velocity = Vector2.down * fallSpeed;
    }

    void OnTriggerEnter2D(Collider2D other)
    {
        if (other.gameObject.name == "DeathZone")
        {
            GameManager.Instance?.LoseLife();
            Destroy(gameObject);
            return;
        }

        RecyclingBin bin = other.GetComponent<RecyclingBin>();
        if (bin != null)
        {
            if (bin.binType == itemType)
            {
                GameManager.Instance?.AddScore(points);
            }
            else
            {
                GameManager.Instance?.LoseLife();
            }
            Destroy(gameObject);
        }
    }
}
