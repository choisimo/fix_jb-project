import os
from pydantic import BaseSettings
from typing import List, Set, Optional


class Settings(BaseSettings):
    # Server Configuration
    PORT: int = 12020
    HOST: str = "0.0.0.0"
    SERVER_URL: str = os.getenv("SERVER_URL", "http://localhost:12020")
    
    # Storage Configuration
    BASE_DIR: str = os.getenv("BASE_DIR", os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "data"))
    UPLOAD_DIR: str = os.path.join(BASE_DIR, "uploads")
    THUMBNAIL_DIR: str = os.path.join(BASE_DIR, "thumbnails")
    TEMP_DIR: str = os.path.join(BASE_DIR, "temp")
    LOG_DIR: str = os.path.join(BASE_DIR, "logs")
    
    # Security Configuration
    API_KEY: str = os.getenv("API_KEY", "")  # Set this in production!
    ENABLE_AUTH: bool = os.getenv("ENABLE_AUTH", "false").lower() == "true"
    
    # File Configuration
    MAX_FILE_SIZE: int = int(os.getenv("MAX_FILE_SIZE", 100 * 1024 * 1024))  # 100MB
    CHUNK_SIZE: int = 1024 * 1024  # 1MB chunks for file reading
    ALLOWED_EXTENSIONS: Set[str] = {".jpg", ".jpeg", ".png", ".gif", ".pdf", ".doc", ".docx", ".xls", ".xlsx", ".txt", ".csv", ".zip", ".mp4", ".mov", ".mp3", ".wav"}
    IMAGE_EXTENSIONS: Set[str] = {".jpg", ".jpeg", ".png", ".gif", ".webp"}
    ANALYZABLE_EXTENSIONS: Set[str] = {".jpg", ".jpeg", ".png", ".pdf", ".doc", ".docx", ".txt"}
    
    # CORS Configuration
    CORS_ORIGINS: List[str] = os.getenv("CORS_ORIGINS", "*").split(",")
    
    # Storage Monitoring
    MIN_FREE_SPACE_PERCENT: float = float(os.getenv("MIN_FREE_SPACE_PERCENT", 10.0))
    
    # AI Service Settings
    AI_SERVICE_URL: str = os.getenv("AI_SERVICE_URL", "http://ai-analysis-service:8080")
    AI_SERVICE_TOKEN: Optional[str] = os.getenv("AI_SERVICE_TOKEN")
    AI_ANALYSIS_TIMEOUT: int = int(os.getenv("AI_ANALYSIS_TIMEOUT", "300"))  # seconds

    # Webhook Settings
    ANALYSIS_WEBHOOK_URL: Optional[str] = os.getenv("ANALYSIS_WEBHOOK_URL")
    ANALYSIS_WEBHOOK_TOKEN: Optional[str] = os.getenv("ANALYSIS_WEBHOOK_TOKEN")

    # Kafka Settings
    KAFKA_ENABLED: bool = os.getenv("KAFKA_ENABLED", "false").lower() == "true"
    KAFKA_BOOTSTRAP_SERVERS: str = os.getenv("KAFKA_BOOTSTRAP_SERVERS", "kafka:9092")
    KAFKA_TOPIC_UPLOAD: str = os.getenv("KAFKA_TOPIC_UPLOAD", "file-uploads")
    KAFKA_TOPIC_ANALYSIS: str = os.getenv("KAFKA_TOPIC_ANALYSIS", "analysis-results")
    KAFKA_CLIENT_ID: str = os.getenv("KAFKA_CLIENT_ID", "file-server")
    
    class Config:
        env_file = ".env"
        case_sensitive = True


# Create a global instance of settings
settings = Settings()
