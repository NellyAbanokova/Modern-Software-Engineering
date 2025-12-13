CREATE TABLE IF NOT EXISTS predictions (
    id SERIAL PRIMARY KEY,
    features TEXT,
    prediction TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);