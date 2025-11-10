from fastapi import FastAPI
from redis import Redis
import os

app = FastAPI()

redis = Redis(host='redis', port=6379)

@app.get("/")
def read_root():
    count = redis.incr('hits')
    return {"message": f"This page has been seen {count} times"}
