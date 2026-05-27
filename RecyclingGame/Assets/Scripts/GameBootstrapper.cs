using UnityEngine;
using UnityEngine.UI;

public class GameBootstrapper : MonoBehaviour
{
    static Font _cachedFont;
    void Start()
    {
        SetupCamera();
        SetupGameManager();
        SetupDeathZone();
        SetupBins();
        SetupSpawner();
        SetupUIManager();
        LinkReferences();
    }

    void SetupCamera()
    {
        Camera cam = Camera.main;
        if (cam == null)
        {
            GameObject camObj = new GameObject("Main Camera");
            cam = camObj.AddComponent<Camera>();
            camObj.tag = "MainCamera";
        }
        cam.orthographic = true;
        cam.orthographicSize = 5f;
        cam.backgroundColor = new Color(0.2f, 0.5f, 0.8f);
        cam.transform.position = new Vector3(0, 0, -10);
        cam.clearFlags = CameraClearFlags.SolidColor;
    }

    void SetupGameManager()
    {
        GameObject gmObj = GameObject.Find("GameManager");
        if (gmObj == null)
        {
            gmObj = new GameObject("GameManager");
            gmObj.AddComponent<GameManager>();
        }
    }

    void SetupDeathZone()
    {
        GameObject dz = GameObject.Find("DeathZone");
        if (dz == null)
        {
            dz = new GameObject("DeathZone");
        }

        dz.transform.position = new Vector3(0, -5.5f, 0);

        BoxCollider2D col = dz.GetComponent<BoxCollider2D>();
        if (col == null) col = dz.AddComponent<BoxCollider2D>();
        col.size = new Vector2(8f, 0.5f);
        col.isTrigger = true;

        Rigidbody2D rb = dz.GetComponent<Rigidbody2D>();
        if (rb == null) rb = dz.AddComponent<Rigidbody2D>();
        rb.bodyType = RigidbodyType2D.Static;
    }

    void SetupBins()
    {
        Color plasticColor = new Color(0.2f, 0.6f, 1.0f);
        Color glassColor = new Color(0.2f, 1.0f, 0.5f);
        Color canColor = new Color(1.0f, 0.3f, 0.2f);

        RecyclingBin plasticBin = CreateBin("PlasticBin", RecyclableType.Plastic, plasticColor, -2f);
        RecyclingBin glassBin = CreateBin("GlassBin", RecyclableType.Glass, glassColor, 0f);
        RecyclingBin canBin = CreateBin("CanBin", RecyclableType.Can, canColor, 2f);

        GameObject playerObj = new GameObject("PlayerController");
        PlayerController player = playerObj.AddComponent<PlayerController>();
        player.plasticBin = plasticBin;
        player.glassBin = glassBin;
        player.canBin = canBin;
    }

    RecyclingBin CreateBin(string name, RecyclableType type, Color color, float x)
    {
        GameObject obj = new GameObject(name, typeof(SpriteRenderer), typeof(BoxCollider2D));

        obj.transform.position = new Vector3(x, -4f, 0);

        SpriteRenderer sr = obj.GetComponent<SpriteRenderer>();
        sr.sprite = CreateSquareSprite(color);
        sr.color = color;
        sr.sortingOrder = 1;

        BoxCollider2D col = obj.GetComponent<BoxCollider2D>();
        col.size = new Vector2(0.8f, 0.8f);
        col.isTrigger = true;

        Rigidbody2D rb = obj.AddComponent<Rigidbody2D>();
        rb.bodyType = RigidbodyType2D.Static;

        RecyclingBin bin = obj.AddComponent<RecyclingBin>();
        bin.binType = type;
        bin.binColor = color;
        bin.binSprite = sr;
        bin.binCollider = col;

        GameObject labelObj = new GameObject("Label");
        labelObj.transform.SetParent(obj.transform, false);
        labelObj.transform.localPosition = new Vector3(0, 0.6f, 0);
        TextMesh tm = labelObj.AddComponent<TextMesh>();
        tm.text = LabelForType(type);
        tm.fontSize = 24;
        tm.anchor = TextAnchor.MiddleCenter;
        tm.color = Color.white;
        tm.font = GetFont();
        bin.label = tm;

        return bin;
    }

    string LabelForType(RecyclableType type)
    {
        switch (type)
        {
            case RecyclableType.Plastic: return "PLASTIC";
            case RecyclableType.Glass: return "GLASS";
            case RecyclableType.Can: return "CAN";
            default: return type.ToString();
        }
    }

    void SetupSpawner()
    {
        GameObject spObj = new GameObject("Spawner");
        Spawner spawner = spObj.AddComponent<Spawner>();

        spawner.itemPrefabs = new GameObject[3];
        spawner.itemPrefabs[0] = CreateItemPrefab("PlasticBottle", RecyclableType.Plastic,
            new Color(0.2f, 0.6f, 1.0f));
        spawner.itemPrefabs[1] = CreateItemPrefab("GlassBottle", RecyclableType.Glass,
            new Color(0.2f, 1.0f, 0.5f));
        spawner.itemPrefabs[2] = CreateItemPrefab("Can", RecyclableType.Can,
            new Color(1.0f, 0.3f, 0.2f));
    }

    GameObject CreateItemPrefab(string name, RecyclableType type, Color color)
    {
        GameObject obj = new GameObject(name, typeof(SpriteRenderer), typeof(CircleCollider2D));

        SpriteRenderer sr = obj.GetComponent<SpriteRenderer>();
        sr.sprite = CreateCircleSprite(color);
        sr.color = color;
        sr.sortingOrder = 2;

        CircleCollider2D col = obj.GetComponent<CircleCollider2D>();
        col.radius = 0.4f;
        col.isTrigger = true;

        Rigidbody2D rb = obj.AddComponent<Rigidbody2D>();
        rb.gravityScale = 0;

        RecyclableItem item = obj.AddComponent<RecyclableItem>();
        item.itemType = type;
        item.points = 10;
        item.fallSpeed = 2f;
        item.spriteRenderer = sr;

        return obj;
    }

    void SetupUIManager()
    {
        GameObject canvasObj = new GameObject("Canvas");
        Canvas canvas = canvasObj.AddComponent<Canvas>();
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;
        canvasObj.AddComponent<CanvasScaler>();
        canvasObj.AddComponent<GraphicRaycaster>();

        UIManager ui = canvasObj.AddComponent<UIManager>();

        Font font = GetFont();

        ui.scoreText = CreateUIText("ScoreText", canvas.transform, "Score: 0",
            font, 28, Color.white, new Vector2(20, -20), TextAnchor.UpperLeft);
        ui.livesText = CreateUIText("LivesText", canvas.transform, "Lives: 3",
            font, 28, Color.white, new Vector2(-20, -20), TextAnchor.UpperRight);
        ui.timeText = CreateUIText("TimeText", canvas.transform, "00:00",
            font, 24, Color.white, new Vector2(0, -20), TextAnchor.UpperCenter);

        ui.gameOverPanel = CreateGameOverPanel(canvas.transform, font);

        GameManager.Instance.uiManager = ui;
    }

    Text CreateUIText(string name, Transform parent, string content,
        Font font, int size, Color color, Vector2 pos, TextAnchor anchor)
    {
        GameObject obj = new GameObject(name, typeof(RectTransform));
        obj.transform.SetParent(parent, false);

        Text text = obj.AddComponent<Text>();
        text.text = content;
        text.font = font;
        text.fontSize = size;
        text.color = color;
        text.alignment = anchor;
        text.horizontalOverflow = HorizontalWrapMode.Overflow;

        RectTransform rt = obj.GetComponent<RectTransform>();
        rt.pivot = GetPivot(anchor);
        rt.anchorMin = GetAnchorMin(anchor);
        rt.anchorMax = GetAnchorMax(anchor);
        rt.anchoredPosition = pos;
        rt.sizeDelta = new Vector2(300, 60);

        return text;
    }

    Vector2 GetPivot(TextAnchor a)
    {
        if (a == TextAnchor.UpperLeft) return new Vector2(0, 1);
        if (a == TextAnchor.UpperCenter) return new Vector2(0.5f, 1);
        if (a == TextAnchor.UpperRight) return new Vector2(1, 1);
        if (a == TextAnchor.MiddleCenter) return new Vector2(0.5f, 0.5f);
        return new Vector2(0.5f, 0.5f);
    }

    Vector2 GetAnchorMin(TextAnchor a)
    {
        if (a == TextAnchor.UpperLeft) return new Vector2(0, 1);
        if (a == TextAnchor.UpperCenter) return new Vector2(0.5f, 1);
        if (a == TextAnchor.UpperRight) return new Vector2(1, 1);
        if (a == TextAnchor.MiddleCenter) return new Vector2(0.5f, 0.5f);
        return new Vector2(0.5f, 0.5f);
    }

    Vector2 GetAnchorMax(TextAnchor a)
    {
        return GetAnchorMin(a);
    }

    GameObject CreateGameOverPanel(Transform canvas, Font font)
    {
        GameObject panel = new GameObject("GameOverPanel", typeof(RectTransform), typeof(Image));
        panel.transform.SetParent(canvas, false);
        panel.SetActive(false);

        RectTransform rt = panel.GetComponent<RectTransform>();
        rt.anchorMin = Vector2.zero;
        rt.anchorMax = Vector2.one;
        rt.sizeDelta = Vector2.zero;

        Image img = panel.GetComponent<Image>();
        img.color = new Color(0, 0, 0, 0.75f);

        Text title = CreateUIText("Title", panel.transform, "GAME OVER",
            font, 52, Color.white, new Vector2(0, -120), TextAnchor.MiddleCenter);
        title.GetComponent<RectTransform>().sizeDelta = new Vector2(400, 80);

        GameObject panelGO = panel;

        UIManager ui = FindObjectOfType<UIManager>();
        if (ui != null)
        {
            ui.finalScoreText = CreateUIText("FinalScore", panel.transform, "Score: 0",
                font, 36, Color.white, new Vector2(0, -200), TextAnchor.MiddleCenter);
            ui.finalScoreText.GetComponent<RectTransform>().sizeDelta = new Vector2(400, 60);
        }

        GameObject btnObj = new GameObject("RestartBtn", typeof(RectTransform), typeof(Image), typeof(Button));
        btnObj.transform.SetParent(panel.transform, false);
        RectTransform btnRt = btnObj.GetComponent<RectTransform>();
        btnRt.sizeDelta = new Vector2(220, 60);
        btnRt.anchoredPosition = new Vector2(0, -300);
        btnRt.anchorMin = new Vector2(0.5f, 0.5f);
        btnRt.anchorMax = new Vector2(0.5f, 0.5f);
        btnRt.pivot = new Vector2(0.5f, 0.5f);

        Image btnImg = btnObj.GetComponent<Image>();
        btnImg.color = new Color(0.2f, 0.8f, 0.2f);

        Text btnText = CreateUIText("BtnText", btnObj.transform, "RESTART",
            font, 28, Color.white, new Vector2(0, 0), TextAnchor.MiddleCenter);
        btnText.GetComponent<RectTransform>().sizeDelta = new Vector2(200, 50);
        btnText.GetComponent<RectTransform>().anchoredPosition = Vector2.zero;
        btnText.GetComponent<RectTransform>().anchorMin = new Vector2(0.5f, 0.5f);
        btnText.GetComponent<RectTransform>().anchorMax = new Vector2(0.5f, 0.5f);
        btnText.GetComponent<RectTransform>().pivot = new Vector2(0.5f, 0.5f);

        Button btn = btnObj.GetComponent<Button>();
        btn.onClick.AddListener(() => GameManager.Instance?.RestartGame());

        return panel;
    }

    Sprite CreateSquareSprite(Color color)
    {
        int w = 64, h = 64;
        Texture2D tex = new Texture2D(w, h);
        for (int y = 0; y < h; y++)
            for (int x = 0; x < w; x++)
            {
                bool edge = x < 2 || x >= w - 2 || y < 2 || y >= h - 2;
                tex.SetPixel(x, y, edge ? Color.white : color);
            }
        tex.Apply();
        return Sprite.Create(tex, new Rect(0, 0, w, h), new Vector2(0.5f, 0.5f));
    }

    Sprite CreateCircleSprite(Color color)
    {
        int w = 32, h = 32;
        Texture2D tex = new Texture2D(w, h);
        float cx = w / 2f, cy = h / 2f, r = w / 2f - 2;
        for (int y = 0; y < h; y++)
            for (int x = 0; x < w; x++)
            {
                float dx = x - cx, dy = y - cy;
                float dist = Mathf.Sqrt(dx * dx + dy * dy);
                bool inside = dist <= r;
                bool edge = inside && dist > r - 2;
                tex.SetPixel(x, y, !inside ? Color.clear : (edge ? Color.white : color));
            }
        tex.Apply();
        return Sprite.Create(tex, new Rect(0, 0, w, h), new Vector2(0.5f, 0.5f));
    }

    void LinkReferences()
    {
        GameManager gm = GameManager.Instance;
        if (gm == null) return;

        Spawner sp = FindObjectOfType<Spawner>();
        if (sp != null) gm.spawner = sp;
    }

    static Font GetFont()
    {
        if (_cachedFont != null) return _cachedFont;

        Font font = Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");
        if (font == null)
            font = Resources.GetBuiltinResource<Font>("Arial.ttf");
        if (font == null)
            font = Font.CreateDynamicFontFromOSFont("Arial", 28);

        _cachedFont = font;
        return font;
    }
}
