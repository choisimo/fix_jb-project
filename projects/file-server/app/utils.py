import os
import hashlib
import asyncio
import magic
from pathlib import Path
from PIL import Image, UnidentifiedImageError
import logging

logger = logging.getLogger("file_server")

async def get_file_hash(file_path: str) -> str:
    """Generate SHA-256 hash of a file"""
    h = hashlib.sha256()
    
    with open(file_path, 'rb') as file:
        while chunk := file.read(8192):  # Read in 8KB chunks
            h.update(chunk)
            
    return h.hexdigest()

async def create_thumbnail(file_path: str, thumbnail_path: str, width: int = 200, height: int = 200) -> bool:
    """Create a thumbnail of an image file"""
    try:
        with Image.open(file_path) as img:
            # Keep aspect ratio
            img.thumbnail((width, height))
            img.save(thumbnail_path, format='JPEG', quality=85)
        return True
    except UnidentifiedImageError:
        logger.error(f"Could not create thumbnail for {file_path}: not a valid image")
        return False
    except Exception as e:
        logger.error(f"Error creating thumbnail for {file_path}: {str(e)}")
        return False

async def process_image(file_path: str) -> dict:
    """Process image and extract basic metadata"""
    try:
        with Image.open(file_path) as img:
            metadata = {
                "width": img.width,
                "height": img.height,
                "format": img.format,
                "mode": img.mode,
            }
            
            # Try to get EXIF data if available
            if hasattr(img, '_getexif') and img._getexif():
                exif = {
                    ExifTags.TAGS[k]: v
                    for k, v in img._getexif().items()
                    if k in ExifTags.TAGS and isinstance(v, (int, float, str, bytes))
                }
                metadata["exif"] = exif
                
            return metadata
    except Exception as e:
        logger.error(f"Error processing image {file_path}: {str(e)}")
        return {"error": str(e)}

async def extract_metadata(file_path: str) -> dict:
    """Extract metadata based on file type"""
    try:
        # Use python-magic to detect file type
        mime = magic.Magic(mime=True)
        mime_type = mime.from_file(file_path)
        
        metadata = {
            "mime_type": mime_type,
            "extension": os.path.splitext(file_path)[1].lower(),
            "size_bytes": os.path.getsize(file_path),
        }
        
        # If it's an image, extract image-specific metadata
        if mime_type.startswith('image/'):
            image_metadata = await process_image(file_path)
            metadata.update(image_metadata)
            
        # For PDF, DOC, etc., we would implement specific extractors here
        # This could integrate with libraries like PyPDF2, python-docx, etc.
            
        return metadata
    except Exception as e:
        logger.error(f"Error extracting metadata for {file_path}: {str(e)}")
        return {"error": str(e)}

def validate_file_extension(filename: str, allowed_extensions: set) -> bool:
    """Check if the file extension is allowed"""
    return any(filename.lower().endswith(ext) for ext in allowed_extensions)

async def cleanup_temp_files(temp_dir: str, max_age_hours: int = 24):
    """Clean up temporary files older than max_age_hours"""
    try:
        now = time.time()
        for filename in os.listdir(temp_dir):
            file_path = os.path.join(temp_dir, filename)
            if os.path.isfile(file_path):
                file_age_hours = (now - os.path.getmtime(file_path)) / 3600
                if file_age_hours > max_age_hours:
                    os.unlink(file_path)
                    logger.info(f"Cleaned up temp file: {filename}")
    except Exception as e:
        logger.error(f"Error cleaning up temp files: {str(e)}")
