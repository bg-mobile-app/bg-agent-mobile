# Agent Sidebar Menu for Mobile App

Source: constants/AgentDashboardLinks.tsx

This file lists the active sidebar items for the agent role, grouped into:
- Common / shared items
- Agent-only items

## Common / Shared Items
These are general dashboard items that are useful for the mobile app as common menu entries.

- Dashboard
- My Profile
- Payment
- Notificaitons
- Change Password
- Terms & Conditions

## Agent-Only Items
These are specific to the agent role.

- My Booking
  - My Booking
  - Success File
  - Retrun Passport
- Appointment Booking
- Commission
- Check Status

## Active Sidebar Names (Flat List)
- Dashboard
- My Profile
- My Booking
- My Booking
- Success File
- Retrun Passport
- Appointment Booking
- Commission
- Check Status
- Payment
- Notificaitons
- Change Password
- Terms & Conditions

## Route Details
- Dashboard -> /dashboard/agent
- My Profile -> /dashboard/agent/profile
- My Booking -> /dashboard/booking/my
- Success File -> /dashboard/booking/my/success-file
- Retrun Passport -> /dashboard/booking/my/return-passport
- Appointment Booking -> /dashboard/booking/appointment
- Commission -> /dashboard/agent/commission
- Check Status -> /dashboard/agent/check-status
- Payment -> /dashboard/my-payments
- Notifications -> /dashboard/notifications
- Change Password -> /dashboard/agent/change-password
- Terms & Conditions -> /dashboard/agent/terms-conditions

## Notes
- The commented-out menu items in the source file were not included because they are not active.
- The “My Booking” section is a parent menu with child items.
