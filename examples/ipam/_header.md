# IPAM Pool Allocation Example

This example demonstrates using Azure Virtual Network Manager IPAM pools for dynamic address allocation instead of static CIDR ranges when vending subscriptions with virtual networks.

> **Note:** This example uses the current subscription for both the Network Manager and VNet deployment for simplicity.
> In a production Azure Landing Zones deployment, the Network Manager and IPAM pools would typically reside in the
> **Connectivity subscription** (platform), with the NM scope set at the **management group level** (e.g., "Landing Zones" MG)
> so that all vended landing zone subscriptions are automatically within scope.
