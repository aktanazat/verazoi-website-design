import asyncio
import logging

from app.config import settings

log = logging.getLogger("verazoi.redis")

_redis = None
_lock = asyncio.Lock()


async def get_redis():
    global _redis
    if _redis is not None:
        return _redis
    async with _lock:
        if _redis is not None:
            return _redis
        try:
            import redis.asyncio as redis
            _redis = redis.from_url(
                settings.redis_url,
                decode_responses=True,
                socket_connect_timeout=3,
                retry_on_timeout=True,
            )
            await _redis.ping()
            log.info("Redis connected")
        except Exception as e:
            log.warning("Redis unavailable: %s", e)
            _redis = None
    return _redis


async def close_redis():
    global _redis
    if _redis:
        await _redis.aclose()
        _redis = None
