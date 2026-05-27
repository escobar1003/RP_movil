using UnityEngine;

public class RecyclingBin : MonoBehaviour
{
    public RecyclableType binType;
    public Color binColor = Color.white;
    public SpriteRenderer binSprite;
    public BoxCollider2D binCollider;

    [Header("Labels")]
    public TextMesh label;

    void Awake()
    {
        if (binSprite == null)
            binSprite = GetComponent<SpriteRenderer>();
        if (binCollider == null)
            binCollider = GetComponent<BoxCollider2D>();

        if (binSprite != null)
            binSprite.color = binColor;
    }

    void Start()
    {
        if (label != null)
            label.text = binType.ToString();
    }
}
