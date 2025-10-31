from fastapi import HTTPException, Header
from typing import Optional
from stripe_service import StripeService


async def require_subscription(user_id: Optional[str] = Header(None, alias="X-User-ID")):
    """
    Dependency to check if user has an active subscription

    Usage:
        @app.post("/premium-endpoint", dependencies=[Depends(require_subscription)])
        async def premium_endpoint(user_id: str = Header(..., alias="X-User-ID")):
            ...

    Args:
        user_id: User ID passed in X-User-ID header

    Raises:
        HTTPException: If user doesn't have active subscription
    """
    if not user_id:
        raise HTTPException(
            status_code=401,
            detail="User ID header (X-User-ID) is required"
        )

    # Get subscription status
    status = StripeService.get_subscription_status(user_id)

    # Check if user has access
    if not status['has_access']:
        raise HTTPException(
            status_code=403,
            detail={
                "error": "subscription_required",
                "message": "Active subscription required to access this feature",
                "status": status['status'],
                "trial_ends_at": status['trial_ends_at']
            }
        )

    return user_id


async def get_user_subscription_status(user_id: Optional[str] = Header(None, alias="X-User-ID")):
    """
    Dependency to get user subscription status without blocking access

    Usage:
        @app.get("/endpoint")
        async def endpoint(sub_status = Depends(get_user_subscription_status)):
            if sub_status['has_access']:
                # Premium features
            else:
                # Free features

    Args:
        user_id: User ID passed in X-User-ID header

    Returns:
        Dict with subscription status
    """
    if not user_id:
        return {
            'status': 'free',
            'tier': None,
            'trial_ends_at': None,
            'subscription_end_date': None,
            'has_access': False
        }

    return StripeService.get_subscription_status(user_id)
