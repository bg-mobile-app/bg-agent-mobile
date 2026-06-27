# Agent API List

This file lists the API endpoints that are different for the agent role compared with agency and customer flows.

## 1. Agent Profile
- Get own agent profile: `/profile/agents/me/`

## 2. Agent Registration
- Register agent: `/user/register/agent/`

## 3. Agent Listing / Admin View
- List agents: `/profile/agents/`
- Get one agent by ID: `/profile/agents/{id}`

## 4. Comparison with Other Roles

### Agency
- Get own profile: `/profile/agency/me/`

### Customer
- Get own profile: `/profile/customers/me/`

## 5. Notes
- These are the main agent-specific API URLs found in the current frontend codebase.
- The agent profile endpoint uses the agent-specific path `/profile/agents/me/` instead of the agency or customer profile paths.
