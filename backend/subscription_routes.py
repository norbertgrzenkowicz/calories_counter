from fastapi import APIRouter, HTTPException, Header, Request
from pydantic import BaseModel
from typing import Optional
import stripe
import os
from stripe_service import StripeService

router = APIRouter(prefix="/subscription", tags=["subscription"])
webhook_router = APIRouter(prefix="/stripe", tags=["stripe"])


# Request/Response Models
class CreateCheckoutRequest(BaseModel):
    user_id: str
    tier: str  # 'monthly' or 'yearly'


class CreateCheckoutResponse(BaseModel):
    checkout_url: str
    session_id: str


class CreatePortalRequest(BaseModel):
    user_id: str


class CreatePortalResponse(BaseModel):
    portal_url: str


class SubscriptionStatusResponse(BaseModel):
    status: str
    tier: Optional[str]
    trial_ends_at: Optional[str]
    subscription_end_date: Optional[str]
    has_access: bool


# Endpoints
@router.post("/create-checkout", response_model=CreateCheckoutResponse)
async def create_checkout_session(request: CreateCheckoutRequest):
    """
    Create a Stripe Checkout session for subscription purchase
    """
    try:
        # Get price ID based on tier
        price_ids = StripeService.get_price_ids()

        if request.tier == 'monthly':
            price_id = price_ids['monthly']
        elif request.tier == 'yearly':
            price_id = price_ids['yearly']
        else:
            raise HTTPException(status_code=400, detail="Invalid tier. Must be 'monthly' or 'yearly'")

        if not price_id:
            raise HTTPException(
                status_code=500,
                detail=f"Price ID not configured for tier: {request.tier}"
            )

        # Create checkout session
        result = StripeService.create_checkout_session(
            user_id=request.user_id,
            price_id=price_id,
            tier=request.tier
        )

        return CreateCheckoutResponse(
            checkout_url=result['checkout_url'],
            session_id=result['session_id']
        )

    except Exception as e:
        print(f"Error creating checkout session: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/create-portal", response_model=CreatePortalResponse)
async def create_customer_portal_session(request: CreatePortalRequest):
    """
    Create a Stripe Customer Portal session for subscription management
    """
    try:
        result = StripeService.create_customer_portal_session(user_id=request.user_id)

        return CreatePortalResponse(portal_url=result['portal_url'])

    except Exception as e:
        print(f"Error creating portal session: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/status/{user_id}", response_model=SubscriptionStatusResponse)
async def get_subscription_status(user_id: str):
    """
    Get current subscription status for a user
    """
    try:
        status = StripeService.get_subscription_status(user_id)

        return SubscriptionStatusResponse(
            status=status['status'],
            tier=status['tier'],
            trial_ends_at=status['trial_ends_at'],
            subscription_end_date=status['subscription_end_date'],
            has_access=status['has_access']
        )

    except Exception as e:
        print(f"Error getting subscription status: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@webhook_router.post("/webhook")
async def stripe_webhook(
    request: Request,
    stripe_signature: str = Header(None, alias="Stripe-Signature")
):
    """
    Handle Stripe webhook events

    This endpoint receives events from Stripe (e.g., subscription created, updated, deleted)
    and syncs the subscription status to the database
    """
    try:
        # Get raw request body
        payload = await request.body()

        # Get webhook secret from environment
        webhook_secret = os.getenv('STRIPE_WEBHOOK_SECRET')
        if not webhook_secret:
            raise HTTPException(
                status_code=500,
                detail="Webhook secret not configured"
            )

        # Verify webhook signature
        try:
            event = stripe.Webhook.construct_event(
                payload=payload,
                sig_header=stripe_signature,
                secret=webhook_secret
            )
        except stripe.error.SignatureVerificationError as e:
            print(f"Webhook signature verification failed: {e}")
            raise HTTPException(status_code=400, detail="Invalid signature")

        # Handle the event
        StripeService.handle_webhook_event(event)

        return {"status": "success"}

    except HTTPException:
        raise
    except Exception as e:
        print(f"Error processing webhook: {e}")
        raise HTTPException(status_code=500, detail=str(e))
