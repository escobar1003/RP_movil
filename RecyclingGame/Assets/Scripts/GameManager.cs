using UnityEngine;
using UnityEngine.SceneManagement;

public enum RecyclableType
{
    Plastic,
    Glass,
    Can
}

public class GameManager : MonoBehaviour
{
    public static GameManager Instance { get; private set; }

    [Header("Game Settings")]
    public int score = 0;
    public int lives = 3;
    public int maxLives = 5;
    public float gameTime = 0f;
    public bool isGameOver = false;

    [Header("Spawning")]
    public Spawner spawner;

    [Header("UI")]
    public UIManager uiManager;

    [Header("Effects")]
    public ParticleSystem correctParticle;
    public ParticleSystem wrongParticle;
    public AudioSource audioSource;
    public AudioClip correctSound;
    public AudioClip wrongSound;
    public AudioClip gameOverSound;

    void Awake()
    {
        if (Instance == null)
            Instance = this;
        else
            Destroy(gameObject);

        Application.targetFrameRate = 60;
    }

    void Start()
    {
        UpdateUI();
        if (spawner != null)
            spawner.enabled = true;
    }

    void Update()
    {
        if (isGameOver) return;

        gameTime += Time.deltaTime;
    }

    public void AddScore(int points)
    {
        if (isGameOver) return;
        score += points;
        UpdateUI();

        if (correctParticle != null)
            correctParticle.Play();
        if (audioSource != null && correctSound != null)
            audioSource.PlayOneShot(correctSound);
    }

    public void LoseLife()
    {
        if (isGameOver) return;
        lives--;
        UpdateUI();

        if (wrongParticle != null)
            wrongParticle.Play();
        if (audioSource != null && wrongSound != null)
            audioSource.PlayOneShot(wrongSound);

        if (lives <= 0)
            GameOver();
    }

    void GameOver()
    {
        isGameOver = true;
        if (spawner != null)
            spawner.enabled = false;

        if (audioSource != null && gameOverSound != null)
            audioSource.PlayOneShot(gameOverSound);

        if (uiManager != null)
            uiManager.ShowGameOver(score);
    }

    void UpdateUI()
    {
        if (uiManager != null)
            uiManager.UpdateScore(score);
        if (uiManager != null)
            uiManager.UpdateLives(lives);
    }

    public void RestartGame()
    {
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
    }
}
