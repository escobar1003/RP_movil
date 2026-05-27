using UnityEngine;

public class Spawner : MonoBehaviour
{
    [Header("Spawn Settings")]
    public GameObject[] itemPrefabs;
    public float spawnInterval = 1.5f;
    public float spawnXMin = -2.8f;
    public float spawnXMax = 2.8f;
    public float spawnY = 6f;

    [Header("Difficulty")]
    public float minInterval = 0.5f;
    public float difficultyRampTime = 60f;

    private float timer = 0f;
    private float gameStartTime = 0f;

    void OnEnable()
    {
        timer = 0f;
        gameStartTime = Time.time;
    }

    void Update()
    {
        if (GameManager.Instance != null && GameManager.Instance.isGameOver)
            return;

        timer += Time.deltaTime;

        float elapsed = Time.time - gameStartTime;
        float t = Mathf.Clamp01(elapsed / difficultyRampTime);
        float currentInterval = Mathf.Lerp(spawnInterval, minInterval, t);

        if (timer >= currentInterval)
        {
            SpawnItem();
            timer = 0f;
        }
    }

    void SpawnItem()
    {
        if (itemPrefabs == null || itemPrefabs.Length == 0) return;

        int index = Random.Range(0, itemPrefabs.Length);
        GameObject prefab = itemPrefabs[index];

        float x = Random.Range(spawnXMin, spawnXMax);
        Vector3 spawnPos = new Vector3(x, spawnY, 0);

        Instantiate(prefab, spawnPos, Quaternion.identity);
    }
}
