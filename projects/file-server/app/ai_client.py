import os
import json
import time
import aiohttp
import asyncio
import logging
from typing import Dict, Any, Optional
from .models import TaskStatus
from .config import settings

try:
    from aiokafka import AIOKafkaProducer
    KAFKA_AVAILABLE = True
except ImportError:
    KAFKA_AVAILABLE = False
    logger = logging.getLogger("file_server")
    logger.warning("aiokafka not installed. Kafka notification disabled.")

logger = logging.getLogger("file_server")

# Kafka producer singleton
kafka_producer = None

async def get_kafka_producer():
    """Get or initialize the Kafka producer"""
    global kafka_producer
    
    if not KAFKA_AVAILABLE or not settings.KAFKA_ENABLED:
        return None
        
    if kafka_producer is None and settings.KAFKA_ENABLED:
        try:
            kafka_producer = AIOKafkaProducer(
                bootstrap_servers=settings.KAFKA_BOOTSTRAP_SERVERS,
                value_serializer=lambda v: json.dumps(v).encode('utf-8'),
                client_id=settings.KAFKA_CLIENT_ID
            )
            await kafka_producer.start()
            logger.info("Kafka producer initialized successfully")
        except Exception as e:
            logger.error(f"Failed to initialize Kafka producer: {str(e)}")
            kafka_producer = None
    
    return kafka_producer

# Reference to the task storage from main.py
# This will be imported there, but we define it here to avoid circular imports
running_tasks = {}

async def request_ai_analysis(file_path: str, file_id: str, task_id: str) -> Dict[str, Any]:
    """
    Send a request to the AI Analysis Service to process a file.
    Updates the task status as it progresses.
    """
    if task_id in running_tasks:
        running_tasks[task_id]["status"] = TaskStatus.IN_PROGRESS
        
    # Initialize Kafka if enabled
    if settings.KAFKA_ENABLED and KAFKA_AVAILABLE:
        await get_kafka_producer()
    
    try:
        logger.info(f"Starting AI analysis for file {file_id}, task {task_id}")
        
        # Prepare the file for upload
        filename = os.path.basename(file_path)
        
        # Create the API endpoint URL
        url = f"{settings.AI_SERVICE_URL}/api/analyze"
        
        # Prepare the form data with the file and options
        options = {
            "fileId": file_id,
            "taskId": task_id,
            "detailed": True,
            "webhook": f"{settings.SERVER_URL}/webhook/analysis-complete"
        }
        
        # Prepare headers
        headers = {}
        if settings.AI_SERVICE_TOKEN:
            headers["Authorization"] = f"Bearer {settings.AI_SERVICE_TOKEN}"
        
        async with aiohttp.ClientSession() as session:
            # Upload the file as multipart form data
            form = aiohttp.FormData()
            form.add_field("file", 
                open(file_path, "rb"),
                filename=filename,
                content_type="application/octet-stream")
            form.add_field("options", json.dumps(options))
            
            # Send the request
            async with session.post(url, data=form, headers=headers) as response:
                if response.status == 200:
                    # Handle successful response
                    result = await response.json()
                    
                    if task_id in running_tasks:
                        running_tasks[task_id].update({
                            "status": TaskStatus.COMPLETED,
                            "result": result,
                            "completed_at": time.time()
                        })
                    
                    logger.info(f"AI analysis completed for task {task_id}")
                    return result
                else:
                    # Handle error response
                    error_text = await response.text()
                    logger.error(f"AI analysis failed for task {task_id}: {error_text}")
                    
                    if task_id in running_tasks:
                        running_tasks[task_id].update({
                            "status": TaskStatus.FAILED,
                            "error": error_text,
                            "completed_at": time.time()
                        })
                    
                    return {"success": False, "error": error_text}
    
    except Exception as e:
        logger.error(f"Error during AI analysis request: {str(e)}")
        
        if task_id in running_tasks:
            running_tasks[task_id].update({
                "status": TaskStatus.FAILED,
                "error": str(e),
                "completed_at": time.time()
            })
        
        return {"success": False, "error": str(e)}

async def notify_analysis_complete(task_id: str, result: Dict[str, Any]) -> bool:
    """
    Send a notification that an analysis task is complete.
    This publishes to Kafka if enabled or calls a webhook.
    """
    try:
        # Prepare notification payload
        payload = {
            "taskId": task_id,
            "status": "completed" if result.get("success", False) else "failed",
            "timestamp": time.time(),
            "result": result,
        }
        
        # If Kafka is enabled, publish to Kafka
        if settings.KAFKA_ENABLED and KAFKA_AVAILABLE:
            producer = await get_kafka_producer()
            if producer:
                try:
                    await producer.send_and_wait(
                        topic=settings.KAFKA_TOPIC_ANALYSIS,
                        value=payload
                    )
                    logger.info(f"Analysis result published to Kafka for task {task_id}")
                except Exception as ke:
                    logger.error(f"Failed to publish to Kafka: {str(ke)}")
                    
        # If webhook URL is configured, send HTTP POST request
        if settings.ANALYSIS_WEBHOOK_URL:
            try:
                async with aiohttp.ClientSession() as session:
                    webhook_headers = {"Content-Type": "application/json"}
                    if settings.ANALYSIS_WEBHOOK_TOKEN:
                        webhook_headers["Authorization"] = f"Bearer {settings.ANALYSIS_WEBHOOK_TOKEN}"
                    
                    async with session.post(
                        settings.ANALYSIS_WEBHOOK_URL,
                        json=payload,
                        headers=webhook_headers
                    ) as response:
                        if response.status == 200:
                            logger.info(f"Webhook notification sent for task {task_id}")
                        else:
                            error_text = await response.text()
                            logger.error(f"Webhook notification failed: {error_text}")
            except Exception as we:
                logger.error(f"Failed to send webhook notification: {str(we)}")
            
        # Return success
        return True
    
    except Exception as e:
        logger.error(f"Failed to notify about analysis completion: {str(e)}")
        return False
