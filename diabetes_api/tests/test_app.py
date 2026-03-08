import sys
import os
import warnings
warnings.filterwarnings("ignore", category=UserWarning)
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
import pytest
from app import app, age_map  # Assuming app.py is in the same dir
import json

@pytest.fixture
def client():
    app.testing = True
    return app.test_client()

def test_health_endpoint(client):
    response = client.get('/health')
    assert response.status_code == 200
    assert json.loads(response.data) == {"status": "healthy"}

def test_predict_valid_input(client):
    data = {
        "Age": "30-34",
        "Sex": "Male",
        "BMI": 25.0,
        "HighBP": "No",
        "HighChol": "No",
        "GenHlth": 3,
        "PhysActivity": "Yes",
        "Fruits": "Yes",
        "Veggies": "Yes",
        "DiffWalk": "No"
    }
    response = client.post('/predict', json=data)
    assert response.status_code == 200
    result = json.loads(response.data)
    assert "risk_level" in result
    assert "risk_text" in result
    assert result["risk_text"] in ["LOW", "MEDIUM", "HIGH"]

def test_predict_invalid_input(client):
    data = {"Age": "Invalid"}  # Bad age
    response = client.post('/predict', json=data)
    assert response.status_code == 200  # Falls back to default, but check for valid output
    result = json.loads(response.data)
    assert "risk_level" in result  # Ensure it doesn't crash

def test_age_mapping():
    assert age_map["18-24"] == 1
    assert age_map["80+"] == 13
    assert age_map.get("Invalid", 1) == 1  # Default

# Run with: pytest test_app.py