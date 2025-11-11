from fastapi import FastAPI
from redis import Redis
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI()

redis = Redis(host='redis', port=6379)

Instrumentator().instrument(app).expose(app)

@app.get("/")
def read_root():
    visits = redis.incr('hits')
    return {"message": f"This page has been seen {visits} times"}
