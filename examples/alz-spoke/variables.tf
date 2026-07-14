variable "subscription_billing_scope" {
  type        = string
  default     = "/providers/Microsoft.Billing/billingAccounts/1234567/enrollmentAccounts/123456"
  description = "The billing scope for the subscription."
}
