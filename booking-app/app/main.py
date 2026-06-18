import json
import os
import uuid
from pathlib import Path

import psycopg2
import redis
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="Vehicle Booking API")

DATABASE_URL = os.environ["DATABASE_URL"]
REDIS_HOST = os.environ.get("REDIS_HOST", "localhost")
REDIS_PORT = int(os.environ.get("REDIS_PORT", "6379"))
RECEIPTS_DIR = Path("/data/receipts")


def get_db():
    return psycopg2.connect(DATABASE_URL)


def get_redis():
    return redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)


@app.on_event("startup")
def init_db():
    RECEIPTS_DIR.mkdir(parents=True, exist_ok=True)
    conn = get_db()
    with conn.cursor() as cur:
        cur.execute("""
            CREATE TABLE IF NOT EXISTS bookings (
                id          SERIAL PRIMARY KEY,
                vehicle_id  VARCHAR(50)  NOT NULL,
                customer    VARCHAR(100) NOT NULL,
                start_date  DATE         NOT NULL,
                end_date    DATE         NOT NULL,
                created_at  TIMESTAMP    DEFAULT NOW()
            )
        """)
        conn.commit()
    conn.close()


class BookingRequest(BaseModel):
    vehicle_id: str
    customer: str
    start_date: str
    end_date: str


@app.get("/health")
def health():
    return {"status": "ok", "pod": os.environ.get("HOSTNAME", "unknown")}


@app.post("/bookings", status_code=201)
def create_booking(req: BookingRequest):
    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(
            "INSERT INTO bookings (vehicle_id, customer, start_date, end_date) "
            "VALUES (%s, %s, %s, %s) RETURNING id, created_at",
            (req.vehicle_id, req.customer, req.start_date, req.end_date),
        )
        row = cur.fetchone()
        conn.commit()
    conn.close()

    booking = {
        "id": row[0],
        "vehicle_id": req.vehicle_id,
        "customer": req.customer,
        "start_date": req.start_date,
        "end_date": req.end_date,
        "created_at": str(row[1]),
    }

    # cache in Redis for 1 hour
    get_redis().setex(f"booking:{booking['id']}", 3600, json.dumps(booking))

    # write receipt to PVC
    (RECEIPTS_DIR / f"{booking['id']}.json").write_text(json.dumps(booking, indent=2))

    return booking


@app.get("/bookings/{booking_id}")
def get_booking(booking_id: int):
    r = get_redis()
    cached = r.get(f"booking:{booking_id}")
    if cached:
        return {**json.loads(cached), "source": "cache"}

    conn = get_db()
    with conn.cursor() as cur:
        cur.execute(
            "SELECT id, vehicle_id, customer, start_date, end_date, created_at "
            "FROM bookings WHERE id = %s",
            (booking_id,),
        )
        row = cur.fetchone()
    conn.close()

    if not row:
        raise HTTPException(status_code=404, detail="Booking not found")

    booking = {
        "id": row[0],
        "vehicle_id": row[1],
        "customer": row[2],
        "start_date": str(row[3]),
        "end_date": str(row[4]),
        "created_at": str(row[5]),
    }

    r.setex(f"booking:{booking_id}", 3600, json.dumps(booking))
    return {**booking, "source": "database"}
