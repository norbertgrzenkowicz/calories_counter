from fastapi import HTTPException, Header
from typing import Optional
import jwt
import os
from functools import lru_cache


@lru_cache()
def get_supabase_jwt_secret():
    """Get Supabase JWT secret from environment"""
    secret = os.getenv('SUPABASE_JWT_SECRET')
    if not secret:
        raise Exception("SUPABASE_JWT_SECRET not configured")
    return secret


async def get_current_user(authorization: Optional[str] = Header(None)) -> str:
    """
    Verify Supabase JWT token and extract user ID

    Usage:
        @app.post("/endpoint")
        async def endpoint(user_id: str = Depends(get_current_user)):
            # user_id is now authenticated and verified
            ...

    Args:
        authorization: Authorization header in format "Bearer <token>"

    Returns:
        Authenticated user's Supabase UID

    Raises:
        HTTPException: If token is missing, invalid, or expired
    """
    if not authorization:
        raise HTTPException(
            status_code=401,
            detail="Authorization header required"
        )

    # Extract token from "Bearer <token>" format
    parts = authorization.split()
    if len(parts) != 2 or parts[0].lower() != 'bearer':
        raise HTTPException(
            status_code=401,
            detail="Invalid authorization header format. Expected: Bearer <token>"
        )

    token = parts[1]

    try:
        # Decode and verify JWT token
        secret = get_supabase_jwt_secret()
        payload = jwt.decode(
            token,
            secret,
            algorithms=["HS256"],
            audience="authenticated"
        )

        # Extract user ID from token
        user_id = payload.get('sub')
        if not user_id:
            raise HTTPException(
                status_code=401,
                detail="Invalid token: missing user ID"
            )

        return user_id

    except jwt.ExpiredSignatureError:
        raise HTTPException(
            status_code=401,
            detail="Token has expired"
        )
    except jwt.InvalidTokenError as e:
        raise HTTPException(
            status_code=401,
            detail=f"Invalid token: {str(e)}"
        )


async def get_optional_user(authorization: Optional[str] = Header(None)) -> Optional[str]:
    """
    Optional authentication - returns user_id if token is valid, None otherwise

    Usage:
        @app.get("/endpoint")
        async def endpoint(user_id: Optional[str] = Depends(get_optional_user)):
            if user_id:
                # Authenticated user
            else:
                # Anonymous user

    Args:
        authorization: Authorization header in format "Bearer <token>"

    Returns:
        User ID if authenticated, None otherwise
    """
    try:
        return await get_current_user(authorization)
    except HTTPException:
        return None
