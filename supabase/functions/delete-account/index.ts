import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  if (req.method !== 'POST' && req.method !== 'DELETE') {
    return new Response(JSON.stringify({ error: 'Method not allowed' }), {
      status: 405,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  const authHeader = req.headers.get('Authorization')
  if (!authHeader) {
    return new Response(JSON.stringify({ error: 'Missing authorization header' }), {
      status: 401,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL')!
  const serviceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  const anonKey = Deno.env.get('SUPABASE_ANON_KEY')!
  const stripeKey = Deno.env.get('STRIPE_SECRET_KEY')

  // Verify the caller's JWT using the user-scoped client
  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authHeader } },
    auth: { autoRefreshToken: false, persistSession: false },
  })

  const { data: { user }, error: authError } = await userClient.auth.getUser()
  if (authError || !user) {
    return new Response(JSON.stringify({ error: 'Unauthorized' }), {
      status: 401,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }

  const userId = user.id

  // Admin client bypasses RLS for cascading data deletion
  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  })

  try {
    // Fetch stripe_customer_id before nuking the profile row
    const { data: profile } = await adminClient
      .from('user_profiles')
      .select('stripe_customer_id')
      .eq('uid', userId)
      .maybeSingle()

    // Delete all user data — order matters if FKs exist
    const { error: mealsError } = await adminClient
      .from('meals')
      .delete()
      .eq('uid', userId)
    if (mealsError) console.error('meals delete error:', mealsError)

    const { error: weightError } = await adminClient
      .from('weight_history')
      .delete()
      .eq('uid', userId)
    if (weightError) console.error('weight_history delete error:', weightError)

    const { error: profileError } = await adminClient
      .from('user_profiles')
      .delete()
      .eq('uid', userId)
    if (profileError) console.error('user_profiles delete error:', profileError)

    // Best-effort Stripe customer deletion — cancels active subscriptions automatically
    if (stripeKey && profile?.stripe_customer_id) {
      try {
        const resp = await fetch(
          `https://api.stripe.com/v1/customers/${profile.stripe_customer_id}`,
          {
            method: 'DELETE',
            headers: { Authorization: `Bearer ${stripeKey}` },
          }
        )
        if (!resp.ok) {
          console.error('Stripe customer delete failed:', await resp.text())
        }
      } catch (stripeErr) {
        console.error('Stripe cleanup error (non-fatal):', stripeErr)
      }
    }

    // Remove the auth user last — once this is gone the JWT is worthless
    const { error: deleteAuthError } = await adminClient.auth.admin.deleteUser(userId)
    if (deleteAuthError) {
      console.error('auth.admin.deleteUser error:', deleteAuthError)
      return new Response(JSON.stringify({ error: 'Failed to delete auth user' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    return new Response(JSON.stringify({ success: true }), {
      status: 200,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  } catch (err) {
    console.error('Account deletion error:', err)
    return new Response(JSON.stringify({ error: 'Internal server error' }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
