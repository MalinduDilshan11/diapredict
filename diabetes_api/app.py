from flask import Flask, request, jsonify
import numpy as np
import joblib
import os
import gdown



MODEL_PATH = "diabetes_risk_model.pkl"
FILE_ID = "1Qhr_DAkgURhewnTe2-9Hlk3Xf9xyUrTD"


if not os.path.exists(MODEL_PATH):
    print("Downloading model from Google Drive...")
    url = f"https://drive.google.com/uc?id={FILE_ID}"
    gdown.download(url, MODEL_PATH, quiet=False)


model = joblib.load(MODEL_PATH)




app = Flask(__name__)

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

@app.route("/predict", methods=["POST"])
def predict():
    try:
        data = request.json

        # Convert "Yes"/"No" to 1/0 for boolean fields
        def yes_no_to_int(val):
            if isinstance(val, str):
                return 1 if val.lower() == "yes" else 0
            return int(val)

        # Convert Age string to numeric
        age_value = age_map.get(data.get("Age", "18-24"), 1)

        features = np.array([[
            age_value,
            1 if data.get("Sex", "Male").lower() == "male" else 0,
            float(data.get("BMI", 24.0)),
            yes_no_to_int(data.get("HighBP", "No")),
            yes_no_to_int(data.get("HighChol", "No")),
            int(data.get("GenHlth", 3)),
            yes_no_to_int(data.get("PhysActivity", "No")),
            yes_no_to_int(data.get("Fruits", "No")),
            yes_no_to_int(data.get("Veggies", "No")),
            yes_no_to_int(data.get("DiffWalk", "No"))
        ]])

        prediction = int(model.predict(features)[0])

        if prediction == 0:
            risk = "LOW"
        elif prediction == 1:
            risk = "MEDIUM"
        else:
            risk = "HIGH"

        print(f"Predicted Risk Level: {risk}")

        return jsonify({
            "risk_level": prediction,
            "risk_text": risk
        })

    except Exception as e:
        print(f"Prediction error: {e}")
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(debug=True)