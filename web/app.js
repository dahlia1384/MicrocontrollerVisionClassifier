const statusElement = document.getElementById("status");
const predictionLabel = document.getElementById("predictionLabel");
const predictionScore = document.getElementById("predictionScore");
const sampleNameElement = document.getElementById("sampleName");

const API_BASE = "http://localhost:5000";

function setStatus(message, ok = true) {
  statusElement.textContent = message;
  statusElement.style.color = ok ? "#027A48" : "#B42318";
}

async function checkBackend() {
  setStatus("Checking backend...", true);
  try {
    const response = await fetch(`${API_BASE}/api/health`);
    if (!response.ok) {
      throw new Error("Backend not healthy");
    }
    const data = await response.json();
    setStatus(`Backend status: ${data.status} @ ${data.timestamp}`, true);
  } catch (error) {
    setStatus("Backend status: offline", false);
  }
}

async function runInference() {
  setStatus("Sending sample frame...", true);
  try {
    const response = await fetch(`${API_BASE}/api/infer`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ sample: "demo-frame" }),
    });
    if (!response.ok) {
      throw new Error("Inference request failed");
    }
    const data = await response.json();
    predictionLabel.textContent = `Label ${data.prediction.label}`;
    predictionScore.textContent = `Score: ${data.prediction.score}`;
    sampleNameElement.textContent = `Sample: ${data.sample}`;
    setStatus("Inference complete", true);
  } catch (error) {
    setStatus("Inference failed - check backend", false);
  }
}

document.getElementById("healthButton").addEventListener("click", checkBackend);
document.getElementById("inferButton").addEventListener("click", runInference);

checkBackend();
