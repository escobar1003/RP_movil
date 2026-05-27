using UnityEngine;
using UnityEngine.UI;

public class UIManager : MonoBehaviour
{
    [Header("UI References")]
    public Text scoreText;
    public Text livesText;
    public Text timeText;
    public GameObject gameOverPanel;
    public Text finalScoreText;
    public Button restartButton;

    void Start()
    {
        if (gameOverPanel != null)
            gameOverPanel.SetActive(false);

        if (restartButton != null)
            restartButton.onClick.AddListener(() =>
            {
                GameManager.Instance?.RestartGame();
            });
    }

    void Update()
    {
        if (GameManager.Instance != null && !GameManager.Instance.isGameOver)
        {
            if (timeText != null)
            {
                int minutes = Mathf.FloorToInt(GameManager.Instance.gameTime / 60f);
                int seconds = Mathf.FloorToInt(GameManager.Instance.gameTime % 60f);
                timeText.text = string.Format("{0:00}:{1:00}", minutes, seconds);
            }
        }
    }

    public void UpdateScore(int score)
    {
        if (scoreText != null)
            scoreText.text = "Score: " + score.ToString();
    }

    public void UpdateLives(int lives)
    {
        if (livesText != null)
            livesText.text = "Lives: " + lives.ToString();
    }

    public void ShowGameOver(int finalScore)
    {
        if (gameOverPanel != null)
            gameOverPanel.SetActive(true);
        if (finalScoreText != null)
            finalScoreText.text = "Final Score: " + finalScore.ToString();
    }
}
