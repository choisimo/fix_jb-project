import os
import shutil
import uuid
import asyncio
import json
from typing import List, Optional
from fastapi import FastAPI, File, UploadFile, HTTPException, BackgroundTasks, Query, Request, Header
from fastapi.responses import FileResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from datetime import datetime
import aiofiles
import logging
from pathlib import Path

from .config import settings, api_key_manager
from .models import FileMetadata, FileResponse as FileResponseModel, TaskStatus
from .utils import get_file_hash, create_thumbnail, process_image, extract_metadata, validate_file_extension
from .ai_client import request_ai_analysis

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[
        logging.StreamHandler(),
        logging.FileHandler(os.path.join(settings.LOG_DIR, "file_server.log"))
    ]
)
logger = logging.getLogger("file_server")

app = FastAPI(
    title="JB-Project File Server",
    description="File storage and processing service for JB-Platform",
    version="1.0.0"
)

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Create storage directories if they don't exist
os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
os.makedirs(settings.THUMBNAIL_DIR, exist_ok=True)
os.makedirs(settings.TEMP_DIR, exist_ok=True)
os.makedirs(settings.LOG_DIR, exist_ok=True)

# Mount static files
app.mount("/files", StaticFiles(directory=settings.UPLOAD_DIR), name="files")
app.mount("/thumbnails", StaticFiles(directory=settings.THUMBNAIL_DIR), name="thumbnails")

# Task storage
running_tasks = {}

@app.get("/")
async def read_root():
    return {"status": "healthy", "service": "jb-file-server", "version": "1.0.0"}

@app.post("/upload/", response_model=FileResponseModel)
async def upload_file(
    file: UploadFile = File(...),
    analyze: bool = False,
    create_thumb: bool = True,
    background_tasks: BackgroundTasks = None,
    x_auth_token: Optional[str] = Header(None)
):
    """
    Upload a file to the server.
    
    - `file`: The file to upload
    - `analyze`: Whether to request AI analysis
    - `create_thumb`: Whether to create a thumbnail (for images)
    """
    # Validate auth token if security is enabled
    if settings.ENABLE_AUTH and not x_auth_token == api_key_manager.get_api_key_safe('file_server'):
        raise HTTPException(status_code=401, detail="Invalid authentication token")
        
    # Validate file extension
    if not validate_file_extension(file.filename, settings.ALLOWED_EXTENSIONS):
        raise HTTPException(
            status_code=400, 
            detail=f"Invalid file type. Allowed types: {', '.join(settings.ALLOWED_EXTENSIONS)}"
        )
    
    # Generate unique filename
    file_id = str(uuid.uuid4())
    timestamp = datetime.now().strftime("%Y%m%d-%H%M%S")
    file_extension = os.path.splitext(file.filename)[1]
    unique_filename = f"{file_id}-{timestamp}{file_extension}"
    
    # Save file path
    file_path = os.path.join(settings.UPLOAD_DIR, unique_filename)
    
    # Save uploaded file
    try:
        # Use aiofiles for non-blocking file operations
        async with aiofiles.open(file_path, 'wb') as out_file:
            # Process in chunks to handle large files efficiently
            while content := await file.read(settings.CHUNK_SIZE):
                await out_file.write(content)
        
        file_size = os.path.getsize(file_path)
        file_hash = await get_file_hash(file_path)
        
        # Extract metadata based on file type
        metadata = await extract_metadata(file_path)
        
        # Create thumbnail if it's an image and create_thumb is True
        thumbnail_url = None
        if create_thumb and file_extension.lower() in settings.IMAGE_EXTENSIONS:
            thumbnail_path = os.path.join(
                settings.THUMBNAIL_DIR, f"thumb_{unique_filename}"
            )
            background_tasks.add_task(
                create_thumbnail, file_path, thumbnail_path, width=300, height=300
            )
            thumbnail_url = settings.get_public_thumbnail_url(f"thumb_{unique_filename}")
        
        # Schedule AI analysis if requested
        analysis_task_id = None
        if analyze and file_extension.lower() in settings.ANALYZABLE_EXTENSIONS:
            analysis_task_id = str(uuid.uuid4())
            background_tasks.add_task(
                request_ai_analysis,
                file_path=file_path,
                file_id=file_id,
                task_id=analysis_task_id
            )
            running_tasks[analysis_task_id] = {
                "status": TaskStatus.PENDING,
                "type": "analysis",
                "file_id": file_id,
                "created_at": datetime.now().isoformat(),
            }
        
        # Create file metadata
        file_meta = FileMetadata(
            id=file_id,
            filename=file.filename,
            stored_filename=unique_filename,
            content_type=file.content_type,
            file_size=file_size,
            file_hash=file_hash,
            upload_time=datetime.now().isoformat(),
            file_url=settings.get_public_file_url(unique_filename),
            thumbnail_url=thumbnail_url,
            metadata=metadata,
            analysis_task_id=analysis_task_id
        )
        
        # Return file information
        return FileResponseModel(
            success=True,
            file_id=file_id,
            file_url=settings.get_public_file_url(unique_filename),
            thumbnail_url=thumbnail_url,
            filename=file.filename,
            size=file_size,
            content_type=file.content_type,
            analysis_task_id=analysis_task_id
        )
        
    except Exception as e:
        logger.error(f"Error during file upload: {str(e)}")
        # Try to clean up any partially written files
        if os.path.exists(file_path):
            os.unlink(file_path)
        raise HTTPException(status_code=500, detail=f"File upload failed: {str(e)}")

@app.get("/files/{file_id}")
async def get_file(file_id: str):
    """Retrieve file by ID"""
    # Implement file lookup logic here
    # This is a simplified version - in a real app, you'd look up the file in a database
    
    # For now, let's look for files with the prefix matching file_id
    for filename in os.listdir(settings.UPLOAD_DIR):
        if filename.startswith(file_id):
            return FileResponse(
                os.path.join(settings.UPLOAD_DIR, filename),
                filename=filename
            )
    
    raise HTTPException(status_code=404, detail="File not found")

@app.delete("/files/{file_id}")
async def delete_file(file_id: str, x_auth_token: Optional[str] = Header(None)):
    """Delete a file by ID"""
    # Validate auth token if security is enabled
    if settings.ENABLE_AUTH and not x_auth_token == api_key_manager.get_api_key_safe('file_server'):
        raise HTTPException(status_code=401, detail="Invalid authentication token")
    
    deleted = False
    
    # Find and delete the file
    for filename in os.listdir(settings.UPLOAD_DIR):
        if filename.startswith(file_id):
            file_path = os.path.join(settings.UPLOAD_DIR, filename)
            os.remove(file_path)
            
            # Also delete thumbnail if it exists
            thumb_name = f"thumb_{filename}"
            thumb_path = os.path.join(settings.THUMBNAIL_DIR, thumb_name)
            if os.path.exists(thumb_path):
                os.remove(thumb_path)
            
            deleted = True
            break
    
    if not deleted:
        raise HTTPException(status_code=404, detail="File not found")
    
    return {"success": True, "message": "File deleted successfully"}

@app.get("/status/{task_id}")
async def get_task_status(task_id: str):
    """Check the status of a background task"""
    if task_id not in running_tasks:
        raise HTTPException(status_code=404, detail="Task not found")
    
    return running_tasks[task_id]

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    try:
        # Check if storage directories are accessible
        for dir_path in [settings.UPLOAD_DIR, settings.THUMBNAIL_DIR, settings.TEMP_DIR]:
            if not os.path.isdir(dir_path) or not os.access(dir_path, os.W_OK):
                return JSONResponse(
                    status_code=503,
                    content={
                        "status": "unhealthy",
                        "message": f"Directory not accessible: {dir_path}"
                    }
                )
        
        # Check disk space
        total, used, free = shutil.disk_usage(settings.UPLOAD_DIR)
        free_percent = (free / total) * 100
        
        if free_percent < settings.MIN_FREE_SPACE_PERCENT:
            return JSONResponse(
                status_code=503,
                content={
                    "status": "degraded",
                    "message": f"Low disk space: {free_percent:.1f}% free",
                    "free_space": free,
                    "total_space": total,
                    "free_percent": free_percent
                }
            )
        
        return {
            "status": "healthy",
            "version": "1.0.0",
            "timestamp": datetime.now().isoformat(),
            "storage": {
                "total": total,
                "used": used,
                "free": free,
                "free_percent": free_percent
            }
        }
    
    except Exception as e:
        logger.error(f"Health check failed: {str(e)}")
        return JSONResponse(
            status_code=503,
            content={
                "status": "unhealthy",
                "message": f"Health check failed: {str(e)}"
            }
        )

@app.post("/batch-upload/")
async def batch_upload(
    files: List[UploadFile] = File(...),
    background_tasks: BackgroundTasks = None,
    x_auth_token: Optional[str] = Header(None)
):
    """Upload multiple files at once"""
    # Validate auth token if security is enabled
    if settings.ENABLE_AUTH and not x_auth_token == api_key_manager.get_api_key_safe('file_server'):
        raise HTTPException(status_code=401, detail="Invalid authentication token")
    
    results = []
    
    for file in files:
        try:
            # Reuse the upload_file logic
            result = await upload_file(
                file=file, 
                background_tasks=background_tasks,
                x_auth_token=x_auth_token
            )
            results.append({
                "filename": file.filename,
                "success": True,
                "file_id": result.file_id,
                "file_url": result.file_url
            })
        except HTTPException as e:
            results.append({
                "filename": file.filename,
                "success": False,
                "error": str(e.detail)
            })
        except Exception as e:
            results.append({
                "filename": file.filename,
                "success": False,
                "error": str(e)
            })
    
    return {"results": results}

@app.post("/webhook/upload/")
async def webhook_upload(
    request: Request,
    background_tasks: BackgroundTasks
):
    """
    Webhook endpoint for receiving file uploads from external systems
    """
    try:
        form = await request.form()
        
        if "file" not in form:
            raise HTTPException(status_code=400, detail="No file part in the request")
        
        file = form["file"]
        analyze = form.get("analyze", "false").lower() == "true"
        
        result = await upload_file(
            file=file,
            analyze=analyze,
            background_tasks=background_tasks,
        )
        
        return result
        
    except Exception as e:
        logger.error(f"Webhook upload error: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Webhook upload failed: {str(e)}")

@app.on_event("startup")
async def startup_event():
    logger.info("File server starting up")
    logger.info(f"Upload directory: {settings.UPLOAD_DIR}")
    logger.info(f"Server URL: {settings.SERVER_URL}")
    logger.info(f"Auth enabled: {settings.ENABLE_AUTH}")

@app.get("/files/search/")
async def search_files_by_tag(
    tag: Optional[str] = Query(None),
    tags: Optional[List[str]] = Query(None),
    x_auth_token: Optional[str] = Header(None)
):
    """
    Search for files by tag
    
    - `tag`: Tag to search for
    """
    # Validate auth token if security is enabled
    if settings.ENABLE_AUTH and not x_auth_token == api_key_manager.get_api_key_safe('file_server'):
        raise HTTPException(status_code=401, detail="Invalid authentication token")
    
    # Validate that at least one of tag or tags is provided
    if tag is None and (tags is None or len(tags) == 0):
        raise HTTPException(status_code=400, detail="Either 'tag' or 'tags' query parameter must be provided")
        
    # Convert single tag to list for unified processing
    search_tags = [tag] if tag else tags
    
    try:
        # Search for files with any of the given tags
        results = []
        for filename in os.listdir(settings.UPLOAD_DIR):
            # Skip non-files
            file_path = os.path.join(settings.UPLOAD_DIR, filename)
            if not os.path.isfile(file_path):
                continue
                
            # Try to parse filename to extract file_id
            try:
                file_id = filename.split('-')[0]  # UUID is the first part before the dash
            except:
                continue
                
            # Get metadata for this file
            try:
                metadata_path = os.path.join(settings.UPLOAD_DIR, f"{file_id}.metadata.json")
                if not os.path.exists(metadata_path):
                    continue
                    
                async with aiofiles.open(metadata_path, 'r') as f:
                    content = await f.read()
                    metadata = json.loads(content)
                    
                # Check if any of the search tags are in the file's tags
                if 'tags' in metadata and any(search_tag in metadata['tags'] for search_tag in search_tags):
                    # Get file info
                    file_url = f"{settings.SERVER_URL}/files/{filename}"
                    
                    # Check for thumbnail
                    thumbnail_url = None
                    thumbnail_filename = f"thumb_{filename}"
                    thumbnail_path = os.path.join(settings.THUMBNAIL_DIR, thumbnail_filename)
                    if os.path.exists(thumbnail_path):
                        thumbnail_url = f"{settings.SERVER_URL}/thumbnails/{thumbnail_filename}"
                    
                    results.append(FileDto(
                        file_id=file_id,
                        filename=metadata.get('original_filename', filename),
                        file_url=file_url,
                        thumbnail_url=thumbnail_url,
                        file_size=os.path.getsize(file_path),
                        content_type=metadata.get('content_type', 'application/octet-stream'),
                        upload_date=metadata.get('upload_date'),
                        tags=metadata.get('tags', []),
                        metadata=metadata.get('metadata', {})
                    ))
            except Exception as e:
                logger.error(f"Error processing file {filename}: {str(e)}")
                continue
        
        return results
    except Exception as e:
        logger.error(f"Error searching files by tag: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error searching files: {str(e)}")

@app.on_event("shutdown")
async def shutdown_event():
    logger.info("File server shutting down")

# Standard API endpoints for compatibility
@app.get("/api/files")
async def list_files(
    limit: int = Query(50, ge=1, le=1000),
    offset: int = Query(0, ge=0),
    x_auth_token: Optional[str] = Header(None)
):
    """List all files with pagination"""
    # Validate auth token if security is enabled
    if settings.ENABLE_AUTH and not x_auth_token == api_key_manager.get_api_key_safe('file_server'):
        raise HTTPException(status_code=401, detail="Invalid authentication token")
    
    try:
        files = []
        all_files = []
        
        # Collect all files
        for filename in os.listdir(settings.UPLOAD_DIR):
            file_path = os.path.join(settings.UPLOAD_DIR, filename)
            if os.path.isfile(file_path):
                try:
                    file_id = filename.split('-')[0]
                    file_stats = os.stat(file_path)
                    
                    all_files.append({
                        "file_id": file_id,
                        "filename": filename,
                        "stored_filename": filename,
                        "size": file_stats.st_size,
                        "file_url": settings.get_public_file_url(filename),
                        "upload_time": datetime.fromtimestamp(file_stats.st_mtime).isoformat(),
                        "content_type": "application/octet-stream"  # Default type
                    })
                except Exception as e:
                    logger.error(f"Error processing file {filename}: {str(e)}")
                    continue
        
        # Sort by upload time (newest first)
        all_files.sort(key=lambda x: x["upload_time"], reverse=True)
        
        # Apply pagination
        total_files = len(all_files)
        start_idx = offset
        end_idx = min(offset + limit, total_files)
        files = all_files[start_idx:end_idx]
        
        return {
            "success": True,
            "files": files,
            "pagination": {
                "total": total_files,
                "offset": offset,
                "limit": limit,
                "has_more": end_idx < total_files
            },
            "timestamp": datetime.now().isoformat()
        }
    
    except Exception as e:
        logger.error(f"Error listing files: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error listing files: {str(e)}")

@app.get("/api/files/status")
async def get_files_status():
    """Get file system status and statistics"""
    try:
        # Count files
        total_files = 0
        total_size = 0
        
        for filename in os.listdir(settings.UPLOAD_DIR):
            file_path = os.path.join(settings.UPLOAD_DIR, filename)
            if os.path.isfile(file_path):
                total_files += 1
                total_size += os.path.getsize(file_path)
        
        # Disk usage
        total, used, free = shutil.disk_usage(settings.UPLOAD_DIR)
        free_percent = (free / total) * 100
        
        return {
            "service": "File Server",
            "status": "ACTIVE",
            "version": "1.0.0",
            "statistics": {
                "total_files": total_files,
                "total_size_bytes": total_size,
                "total_size_mb": round(total_size / (1024 * 1024), 2)
            },
            "storage": {
                "total_space_bytes": total,
                "used_space_bytes": used,
                "free_space_bytes": free,
                "free_percent": round(free_percent, 1)
            },
            "endpoints": {
                "upload": "/upload/",
                "list": "/api/files",
                "get": "/files/{file_id}",
                "delete": "/files/{file_id}",
                "status": "/api/files/status",
                "health": "/health"
            },
            "timestamp": datetime.now().isoformat()
        }
    
    except Exception as e:
        logger.error(f"Error getting files status: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Error getting status: {str(e)}")

@app.get("/api/files/info")
async def get_files_info():
    """Get file server information"""
    return {
        "service": "JB-Project File Server",
        "version": "1.0.0",
        "description": "파일 저장 및 처리 서비스",
        "features": [
            "파일 업로드",
            "썸네일 생성",
            "AI 분석 통합",
            "배치 업로드",
            "웹훅 지원"
        ],
        "supported_formats": list(settings.ALLOWED_EXTENSIONS),
        "max_file_size": "100MB",
        "auth_required": settings.ENABLE_AUTH,
        "ai_integration": True,
        "timestamp": datetime.now().isoformat()
    }
