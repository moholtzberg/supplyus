Rails.configuration.stripe = {
  :publishable_key => "pk_test_bbWycAxBBkc7Jo9kejH7BpOL",
  :secret_key      => "sk_test_TfFdb0OJFgxF6PAzQiIxPF7q"
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]