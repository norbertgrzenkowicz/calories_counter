import os
import stripe
from datetime import datetime
from typing import Optional, Dict, Any
from supabase import create_client, Client

# Initialize Stripe with secret key
stripe.api_key = os.getenv('STRIPE_SECRET_KEY')

# Initialize Supabase client lazily
_supabase_url = os.getenv('SUPABASE_URL')
# Use SERVICE_ROLE_KEY for backend operations to bypass RLS
_supabase_key = os.getenv('SUPABASE_SERVICE_ROLE_KEY') or os.getenv('SUPABASE_ANON_KEY')

# Only create Supabase client if credentials are provided
supabase: Optional[Client] = None
if _supabase_url and _supabase_key and len(_supabase_url) > 0 and len(_supabase_key) > 0:
    try:
        supabase = create_client(_supabase_url, _supabase_key)
        key_type = "SERVICE_ROLE" if os.getenv('SUPABASE_SERVICE_ROLE_KEY') else "ANON"
        print(f"✓ Supabase client initialized with {key_type} key")
    except Exception as e:
        print(f"⚠️  Failed to initialize Supabase: {e}")
        supabase = None
else:
    print("⚠️  Supabase credentials not found - some features will be limited")

class StripeService:
    """Service for handling all Stripe-related operations"""

    @staticmethod
    def get_price_ids() -> Dict[str, str]:
        """Get Stripe price IDs from environment"""
        return {
            'monthly': os.getenv('STRIPE_MONTHLY_PRICE_ID'),
            'yearly': os.getenv('STRIPE_YEARLY_PRICE_ID')
        }

    @staticmethod
    def create_checkout_session(user_id: str, price_id: str, tier: str) -> Dict[str, Any]:
        """
        Create a Stripe Checkout session for subscription purchase

        Args:
            user_id: Supabase user ID
            price_id: Stripe price ID (monthly or yearly)
            tier: 'monthly' or 'yearly'

        Returns:
            Dict with checkout_url and session_id
        """
        try:
            # Get or create Stripe customer
            stripe_customer_id = StripeService._get_or_create_customer(user_id)

            # Create checkout session
            session = stripe.checkout.Session.create(
                customer=stripe_customer_id,
                line_items=[{
                    'price': price_id,
                    'quantity': 1,
                }],
                mode='subscription',
                success_url='foodscanner://subscription/success?session_id={CHECKOUT_SESSION_ID}',
                cancel_url='foodscanner://subscription/cancel',
                metadata={
                    'user_id': user_id,
                    'tier': tier
                },
                # Trial is configured at product level in Stripe Dashboard
                # but we can override it here if needed:
                # subscription_data={'trial_period_days': 7},
            )

            return {
                'checkout_url': session.url,
                'session_id': session.id
            }

        except stripe.error.StripeError as e:
            print(f"Stripe error creating checkout session: {e}")
            raise Exception(f"Failed to create checkout session: {str(e)}")

    @staticmethod
    def create_customer_portal_session(user_id: str) -> Dict[str, str]:
        """
        Create a Stripe Customer Portal session for subscription management

        Args:
            user_id: Supabase user ID

        Returns:
            Dict with portal_url
        """
        try:
            # Get Stripe customer ID from database
            response = supabase.table('user_profiles').select('stripe_customer_id').eq('uid', user_id).execute()

            if not response.data or len(response.data) == 0 or not response.data[0].get('stripe_customer_id'):
                raise Exception("No Stripe customer found for this user")

            stripe_customer_id = response.data[0]['stripe_customer_id']

            # Create portal session
            session = stripe.billing_portal.Session.create(
                customer=stripe_customer_id,
                return_url='foodscanner://subscription/manage',
            )

            return {'portal_url': session.url}

        except stripe.error.StripeError as e:
            print(f"Stripe error creating portal session: {e}")
            raise Exception(f"Failed to create portal session: {str(e)}")

    @staticmethod
    def _get_or_create_customer(user_id: str) -> str:
        """
        Get existing Stripe customer ID or create a new customer

        Args:
            user_id: Supabase user ID

        Returns:
            Stripe customer ID
        """
        if supabase is None:
            raise Exception("Supabase not initialized - cannot create customer")

        # Check if user already has a Stripe customer ID
        response = supabase.table('user_profiles').select('stripe_customer_id, email, full_name').eq('uid', user_id).execute()

        # Check if profile exists
        if not response.data or len(response.data) == 0:
            raise Exception(f"User profile not found for {user_id}. User must complete signup before subscribing.")

        user_data = response.data[0]
        if user_data.get('stripe_customer_id'):
            return user_data['stripe_customer_id']

        # Create new Stripe customer
        customer = stripe.Customer.create(
            email=user_data.get('email'),
            name=user_data.get('full_name'),
            metadata={'user_id': user_id}
        )

        # Store customer ID in database
        supabase.table('user_profiles').update({
            'stripe_customer_id': customer.id
        }).eq('uid', user_id).execute()

        return customer.id

    @staticmethod
    def handle_webhook_event(event: Dict[str, Any]) -> None:
        """
        Handle Stripe webhook events and sync subscription status to database

        Args:
            event: Stripe webhook event object
        """
        event_type = event['type']
        data = event['data']['object']

        print(f"Processing webhook event: {event_type}")

        if event_type == 'customer.subscription.created':
            StripeService._handle_subscription_created(data)

        elif event_type == 'customer.subscription.updated':
            StripeService._handle_subscription_updated(data)

        elif event_type == 'customer.subscription.deleted':
            StripeService._handle_subscription_deleted(data)

        elif event_type == 'invoice.payment_succeeded':
            StripeService._handle_payment_succeeded(data)

        elif event_type == 'invoice.payment_failed':
            StripeService._handle_payment_failed(data)

        else:
            print(f"Unhandled webhook event type: {event_type}")

    @staticmethod
    def _handle_subscription_created(subscription: Dict[str, Any]) -> None:
        """Handle subscription.created webhook"""
        user_id = subscription['metadata'].get('user_id')
        if not user_id:
            # Fallback: get user_id from customer metadata
            customer = stripe.Customer.retrieve(subscription['customer'])
            user_id = customer.metadata.get('user_id')

        if not user_id:
            print(f"Could not find user_id for subscription {subscription['id']}")
            return

        # Determine tier from price
        price_id = subscription['items']['data'][0]['price']['id']
        tier = StripeService._get_tier_from_price_id(price_id)

        # Check if in trial
        status = 'trialing' if subscription['status'] == 'trialing' else 'active'
        trial_end = datetime.fromtimestamp(subscription['trial_end']) if subscription.get('trial_end') else None

        # Update database
        supabase.table('user_profiles').update({
            'subscription_status': status,
            'subscription_tier': tier,
            'stripe_subscription_id': subscription['id'],
            'subscription_start_date': datetime.fromtimestamp(subscription['current_period_start']).isoformat(),
            'subscription_end_date': datetime.fromtimestamp(subscription['current_period_end']).isoformat(),
            'trial_ends_at': trial_end.isoformat() if trial_end else None,
        }).eq('uid', user_id).execute()

        print(f"Subscription created for user {user_id}: {status} ({tier})")

    @staticmethod
    def _handle_subscription_updated(subscription: Dict[str, Any]) -> None:
        """Handle subscription.updated webhook"""
        subscription_id = subscription['id']
        status_map = {
            'active': 'active',
            'trialing': 'trialing',
            'past_due': 'past_due',
            'canceled': 'canceled',
            'unpaid': 'canceled'
        }

        status = status_map.get(subscription['status'], 'free')
        trial_end = datetime.fromtimestamp(subscription['trial_end']) if subscription.get('trial_end') else None

        # Update database
        supabase.table('user_profiles').update({
            'subscription_status': status,
            'subscription_end_date': datetime.fromtimestamp(subscription['current_period_end']).isoformat(),
            'trial_ends_at': trial_end.isoformat() if trial_end else None,
        }).eq('stripe_subscription_id', subscription_id).execute()

        print(f"Subscription {subscription_id} updated to status: {status}")

    @staticmethod
    def _handle_subscription_deleted(subscription: Dict[str, Any]) -> None:
        """Handle subscription.deleted webhook"""
        subscription_id = subscription['id']

        # Update database
        supabase.table('user_profiles').update({
            'subscription_status': 'canceled',
            'subscription_tier': None,
            'stripe_subscription_id': None,
        }).eq('stripe_subscription_id', subscription_id).execute()

        print(f"Subscription {subscription_id} canceled")

    @staticmethod
    def _handle_payment_succeeded(invoice: Dict[str, Any]) -> None:
        """Handle invoice.payment_succeeded webhook"""
        subscription_id = invoice.get('subscription')
        if subscription_id:
            # Ensure subscription is marked as active
            supabase.table('user_profiles').update({
                'subscription_status': 'active',
            }).eq('stripe_subscription_id', subscription_id).execute()

            print(f"Payment succeeded for subscription {subscription_id}")

    @staticmethod
    def _handle_payment_failed(invoice: Dict[str, Any]) -> None:
        """Handle invoice.payment_failed webhook"""
        subscription_id = invoice.get('subscription')
        if subscription_id:
            # Mark subscription as past_due
            supabase.table('user_profiles').update({
                'subscription_status': 'past_due',
            }).eq('stripe_subscription_id', subscription_id).execute()

            print(f"Payment failed for subscription {subscription_id}")

    @staticmethod
    def _get_tier_from_price_id(price_id: str) -> str:
        """Determine subscription tier from price ID"""
        price_ids = StripeService.get_price_ids()

        if price_id == price_ids['monthly']:
            return 'monthly'
        elif price_id == price_ids['yearly']:
            return 'yearly'
        else:
            return 'unknown'

    @staticmethod
    def get_subscription_status(user_id: str) -> Dict[str, Any]:
        """
        Get current subscription status for a user

        Args:
            user_id: Supabase user ID

        Returns:
            Dict with subscription details
        """
        try:
            # Check if Supabase is available
            if supabase is None:
                print("Supabase client not initialized - returning free tier")
                return {
                    'status': 'free',
                    'tier': None,
                    'trial_ends_at': None,
                    'subscription_end_date': None,
                    'has_access': False
                }

            response = supabase.table('user_profiles').select(
                'subscription_status, subscription_tier, trial_ends_at, subscription_end_date'
            ).eq('uid', user_id).execute()

            # Check if user profile exists
            if not response.data or len(response.data) == 0:
                # User profile doesn't exist - return free tier status
                # Profile should be created during user signup in the Flutter app
                print(f"User profile not found for {user_id}, returning free tier status")
                return {
                    'status': 'free',
                    'tier': None,
                    'trial_ends_at': None,
                    'subscription_end_date': None,
                    'has_access': False
                }

            data = response.data[0]
            status = data.get('subscription_status', 'free')

            # Check if user has active access
            has_access = status in ('active', 'trialing')

            # Check if trial is still valid
            trial_ends_at = data.get('trial_ends_at')
            if trial_ends_at:
                trial_end_date = datetime.fromisoformat(trial_ends_at.replace('Z', '+00:00'))
                if datetime.now() < trial_end_date:
                    has_access = True

            return {
                'status': status,
                'tier': data.get('subscription_tier'),
                'trial_ends_at': trial_ends_at,
                'subscription_end_date': data.get('subscription_end_date'),
                'has_access': has_access
            }

        except Exception as e:
            print(f"Error getting subscription status: {e}")
            return {
                'status': 'free',
                'tier': None,
                'trial_ends_at': None,
                'subscription_end_date': None,
                'has_access': False
            }

