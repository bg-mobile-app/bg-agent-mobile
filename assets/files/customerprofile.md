# Customer Profile

This document describes the customer profile page at:

- URL: `https://demo.bideshgami.com/dashboard/customer/profile`

## Frontend route and component

The page route is:

- `app/dashboard/customer/profile/page.tsx`

This route renders:

- `features/dashboard/customer/profile/DashboardCustomerProfile.tsx`

## API endpoint

The profile component loads data using:

- `features/dashboard/customer/profile/profile.apiHandler.ts`
- function: `getCustomerProfile()`
- endpoint: `GET /profile/customers/me/`

The request is sent via the authenticated Axios instance:

- `authApi.get(`/profile/customers/me/`)`

## Frontend design

The profile page renders a profile card with:

- User avatar image
- Full name
- Edit button linking to `/dashboard/customer/profile/edit/`
- Section: Personal Details
- Section: Basic Info
- Section: Contact Info
- Section: Passport Info
- Section: Personalized Info

Each section uses bordered rows with two columns:

- left column: label
- right column: data value

The displayed fields include:

Basic Info:
- Name
- Date of Birth
- Gender

Contact Info:
- Email Address
- Phone Number
- Address
- Police Station
- District

Passport Info:
- Passport Number
- Passport Expire Date
- Passport Issue Date

Personalized Info:
- Liked Services
- Liked Countries
- Liked Job Type

## API response fields

The response is typed as `CustomerDetailsProps` in:

- `types/auth/customer.types.ts`

The response fields used by the page are:

- `id`
- `image`
- `dob`
- `gender`
- `passportNo`
- `passportExpiry`
- `passportIssue`
- `address`
- `policeStation.name`
- `district.name`
- `services` (array of strings)
- `countries` (array of objects with `name`)
- `workTypes` (array of objects with `name`)
- `user.fullName`
- `user.email`
- `user.phone`

## Notes

- The component uses React Query to fetch and cache profile data.
- `staleTime` is set to 5 minutes.
- Errors are displayed through `AllErrorsToastMessage`.
- The edit page is separate and uses the same `getCustomerProfile` query for initial form values.
