from fastapi import FastAPI
from pydantic import BaseModel
import psycopg2
import json
from model import clf, target_names
import os

app = FastAPI()

class Features(BaseModel):
    features: list

conn = psycopg2.connect(
    host=os.getenv("DB_HOST"),
    database=os.getenv("DB_NAME"),
    user=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD")
)

@app.post("/predict")
def predict(data: Features):
    pred_index = clf.predict([data.features])[0]
    pred_name = target_names[pred_index]

    cur = conn.cursor()
    cur.execute("INSERT INTO predictions (features, prediction) VALUES (%s, %s)",
                (json.dumps(data.features), pred_name))
    conn.commit()
    cur.close()

    return {"prediction": pred_name}