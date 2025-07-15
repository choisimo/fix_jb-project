from typing import Dict, Optional, Any, List
from enum import Enum
from pydantic import BaseModel, Field


class TaskStatus(str, Enum):
    PENDING = "pending"
    IN_PROGRESS = "in_progress"
    COMPLETED = "completed"
    FAILED = "failed"


class FileMetadata(BaseModel):
    """Full internal metadata for a file"""
    id: str
    filename: str
    stored_filename: str
    content_type: str
    file_size: int
    file_hash: str
    upload_time: str
    file_url: str
    thumbnail_url: Optional[str] = None
    metadata: Dict[str, Any] = {}
    analysis_task_id: Optional[str] = None
    tags: List[str] = []


class FileResponse(BaseModel):
    """Public response for file upload"""
    success: bool
    file_id: str
    file_url: str
    thumbnail_url: Optional[str] = None
    filename: str
    size: int
    content_type: str
    analysis_task_id: Optional[str] = None


class AnalysisRequest(BaseModel):
    """Request to analyze a file"""
    file_path: str
    file_id: str
    options: Dict[str, Any] = {}


class AnalysisResponse(BaseModel):
    """Response from file analysis"""
    success: bool
    file_id: str
    analysis_id: str
    results: Dict[str, Any] = {}
    error: Optional[str] = None


class BatchUploadRequest(BaseModel):
    """Request for batch file uploads"""
    files: List[str]
    analyze: bool = False


class WebhookResponse(BaseModel):
    """Response for webhook calls"""
    success: bool
    message: str
    data: Dict[str, Any] = {}
