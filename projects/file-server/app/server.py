import os
import uvicorn
from .config import settings

def run_server():
    """Run the FastAPI server using uvicorn"""
    uvicorn.run(
        "app.main:app",
        host=settings.HOST,
        port=settings.PORT,
        reload=os.getenv("ENVIRONMENT", "production") == "development",
        log_level="info",
        workers=int(os.getenv("WORKERS", "4")),
    )

if __name__ == "__main__":
    run_server()
