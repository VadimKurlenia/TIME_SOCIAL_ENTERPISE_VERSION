import sys
from contextlib import asynccontextmanager

import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.modules.users.router import router as users_router


@asynccontextmanager
async def lifespan(app: FastAPI):
    yield

app = FastAPI(
    title="TimeSocial API",
    description="бекенд TimeSocial",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(users_router, prefix="/api/v1")

@app.get("/health", tags=["Health Check"])
async def health_check():
    """Проверка работоспособности сервиса."""
    return {"status": "ok", "service": "SigmaTrack Core API"}

if __name__ == "__main__":
    loop_type = "asyncio" if sys.platform == "win32" else "auto"

    uvicorn.run(
        "app.main:app",
        host="127.0.0.1",
        port=8000,
        reload=True,
        loop=loop_type,
    )