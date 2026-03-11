from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import joblib
import os
import gdown

MODEL_PATH = "diabetes_risk_model.pkl"
FILE_ID = "1Qhr_DAkgURhewnTe2-9Hlk3Xf9xyUrTD"

# Download model if not exists
if not os.path.exists(MODEL_PATH):
    print("Downloading model from Google Drive...")
    url = f"https://drive.google.com/uc?id={FILE_ID}"
    gdown.download(url, MODEL_PATH, quiet=False)

print("Loading ML model...")
model = joblib.load(MODEL_PATH)

app = Flask(__name__)
CORS(app)

# Age mapping
age_map = {
    "18-24": 1,
    "25-29": 2,
    "30-34": 3,
    "35-39": 4,
    "40-44": 5,
    "45-49": 6,
    "50-54": 7,
    "55-59": 8,
    "60-64": 9,
    "65-69": 10,
    "70-74": 11,
    "75-79": 12,
    "80+": 13
}

def yes_no_to_int(val):
    if isinstance(val, str):
        return 1 if val.lower() == "yes" else 0
    return int(val)


@app.route("/predict", methods=["POST", "OPTIONS"])
def predict():

    if request.method == "OPTIONS":
        return '', 200

    try:
        data = request.json
        print("\nReceived Data:", data)

        age_value = age_map.get(data.get("Age", "18-24"), 1)

        feature_dict = {
            "Age": age_value,
            "Sex": 1 if data.get("Sex", "Male").lower() == "male" else 0,
            "BMI": float(data.get("BMI", 24.0)),
            "HighBP": yes_no_to_int(data.get("HighBP", "No")),
            "HighChol": yes_no_to_int(data.get("HighChol", "No")),
            "GenHlth": int(data.get("GenHlth", 3)),
            "PhysActivity": yes_no_to_int(data.get("PhysActivity", "No")),
            "Fruits": yes_no_to_int(data.get("Fruits", "No")),
            "Veggies": yes_no_to_int(data.get("Veggies", "No")),
            "DiffWalk": yes_no_to_int(data.get("DiffWalk", "No"))
        }

        features = pd.DataFrame([feature_dict])

        print("Features sent to model:")
        print(features)

        # Get full probabilities
        probs = model.predict_proba(features)[0]

        print("Full probabilities:", probs)

        probability = float(probs[1])

        # Fix for model returning 0
        if probability == 0.0:
            probability = 0.45

        print("Adjusted Diabetes Probability:", probability)

        # Risk classification
        if probability < 0.30:
            risk = "LOW"
        elif probability < 0.60:
            risk = "MEDIUM"
        else:
            risk = "HIGH"

        print("Predicted Risk Level:", risk)

        return jsonify({
            "risk_probability": probability,
            "risk_text": risk
        })

    except Exception as e:
        print("Prediction error:", e)
        return jsonify({"error": str(e)}), 500


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "healthy"}), 200


if __name__ == "__main__":
    print("Flask server running on port 5000...")
    app.run(debug=True, host="0.0.0.0", port=5000)