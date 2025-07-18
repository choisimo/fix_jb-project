import os
from pydantic import BaseSettings
from typing import List, Set, Optional
import logging

logger = logging.getLogger(__name__)

class ApiKeyManager:
    """Centralized API Key Manager for File Server using Singleton pattern"""
    
    _instance = None
    _api_keys = {}
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(ApiKeyManager, cls).__new__(cls)
            cls._instance._load_api_keys()
        return cls._instance
    
    def _load_api_keys(self):
        """Load all API keys from environment variables"""
        self._api_keys = {
            'file_server': os.getenv("API_KEY", ""),
            'ai_service': os.getenv("AI_SERVICE_TOKEN", ""),
            'analysis_webhook': os.getenv("ANALYSIS_WEBHOOK_TOKEN", ""),
            'google_cloud': os.getenv("GOOGLE_CLOUD_API_KEY", ""),
            'openrouter': os.getenv("OPENROUTER_API_KEY", ""),
            'gemini': os.getenv("GEMINI_API_KEY", ""),
            'roboflow': os.getenv("ROBOFLOW_API_KEY", "")
        }
        
        # Log available keys (masked)
        available_keys = [key for key, value in self._api_keys.items() if value]
        logger.info(f"API Keys loaded. Available keys: {available_keys}")
    
    def get_api_key(self, key_type: str) -> str:
        """Get API key by type
        
        Args:
            key_type: Type of API key
            
        Returns:
            API key value
            
        Raises:
            ValueError: If key is not configured
        """
        if key_type not in self._api_keys or not self._api_keys[key_type]:
            raise ValueError(f"API key not configured for: {key_type}")
        return self._api_keys[key_type]
    
    def get_api_key_safe(self, key_type: str) -> Optional[str]:
        """Get API key safely (returns None if not available)"""
        return self._api_keys.get(key_type)
    
    def has_api_key(self, key_type: str) -> bool:
        """Check if API key is available"""
        return bool(self._api_keys.get(key_type))
    
    def get_masked_api_key(self, key_type: str) -> str:
        """Get masked API key for logging"""
        key = self._api_keys.get(key_type, "")
        if not key:
            return "NOT_CONFIGURED"
        if len(key) <= 8:
            return "****"
        return key[:4] + "****" + key[-4:]
    
    def refresh_api_keys(self):
        """Refresh API keys from environment"""
        logger.info("Refreshing API keys...")
        self._load_api_keys()
    
    def get_available_keys(self) -> List[str]:
        """Get list of configured API key types"""
        return [key for key, value in self._api_keys.items() if value]


class Settings(BaseSettings):
    # Server Configuration
    PORT: int = 12020
    HOST: str = "0.0.0.0"
    SERVER_URL: str = os.getenv("SERVER_URL", "http://localhost:12020")
    
    # External URL for public access (nginx proxy)
    PUBLIC_URL: str = os.getenv("PUBLIC_URL", "http://localhost:8090")
    
    # Storage Configuration
    BASE_DIR: str = os.getenv("BASE_DIR", os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "data"))
    UPLOAD_DIR: str = os.path.join(BASE_DIR, "uploads")
    THUMBNAIL_DIR: str = os.path.join(BASE_DIR, "thumbnails")
    TEMP_DIR: str = os.path.join(BASE_DIR, "temp")
    LOG_DIR: str = os.path.join(BASE_DIR, "logs")
    
    # Security Configuration - Now managed by ApiKeyManager
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
    AI_ANALYSIS_TIMEOUT: int = int(os.getenv("AI_ANALYSIS_TIMEOUT", "300"))  # seconds

    # Webhook Settings
    ANALYSIS_WEBHOOK_URL: Optional[str] = os.getenv("ANALYSIS_WEBHOOK_URL")

    # Kafka Settings
    KAFKA_ENABLED: bool = os.getenv("KAFKA_ENABLED", "false").lower() == "true"
    KAFKA_BOOTSTRAP_SERVERS: str = os.getenv("KAFKA_BOOTSTRAP_SERVERS", "kafka:9092")
    KAFKA_TOPIC_UPLOAD: str = os.getenv("KAFKA_TOPIC_UPLOAD", "file-uploads")
    KAFKA_TOPIC_ANALYSIS: str = os.getenv("KAFKA_TOPIC_ANALYSIS", "analysis-results")
    KAFKA_CLIENT_ID: str = os.getenv("KAFKA_CLIENT_ID", "file-server")
    
    # URL generation methods
    def get_public_file_url(self, filename: str) -> str:
        """Generate public URL for file access through nginx proxy"""
        return f"{self.PUBLIC_URL}/files/{filename}"
    
    def get_public_thumbnail_url(self, filename: str) -> str:
        """Generate public URL for thumbnail access through nginx proxy"""
        return f"{self.PUBLIC_URL}/thumbnails/{filename}"
    
    @property
    def api_key_manager(self) -> ApiKeyManager:
        """Get API key manager instance"""
        return ApiKeyManager()
    
    class Config:
        env_file = ".env"
        case_sensitive = True


# Create a global instance of settings
settings = Settings()

# Create a global instance of API key manager
api_key_manager = ApiKeyManager()