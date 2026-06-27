# Customer Dashboard

This document describes the customer dashboard page at:

- URL: `https://demo.bideshgami.com/dashboard/customer`

## Frontend route and component

The page is implemented by:

- `app/dashboard/customer/page.tsx`

This component:

- loads customer dashboard stats on mount
- uses a dropdown to select a period filter
- displays a grid of small dashboard cards

## API endpoint

The page calls the customer dashboard stats API via:

- `api/common/dashboard.api.ts`
- function: `getCustomerDashboard(period)`
- endpoint: `GET /filter/customer/stats/?period=${period}`

The request is made through the shared authenticated Axios instance:

- `authApi.get(`/filter/customer/stats/?period=${period}`)`

## Frontend design

The customer dashboard page renders:

- page title: `Dashboard Overview`
- period selector dropdown with options from `DASHBOARD_PERIODS`
- a responsive grid of `DashboardSmallCard` components

Each card displays an icon, a label, and a numeric value.

The following cards are rendered:

- Total Applied Job
- Under Processing
- Success Flight
- Reject Flight
- Return Passport
- Total Appointment
- Total Amount
- Paid Amount
- Due Amount

The card values are formatted using `BDTFormat`.

## API response fields

The page expects the API result to contain these fields:

- `total` - numeric
- `successFlight` - numeric
- `rejectFlight` - numeric
- `processing` - numeric
- `returnProcessing` - numeric
- `totalAmount` - numeric
- `paidAmount` - numeric
- `dueAmount` - numeric

These are used directly in the page state and rendered into the card values.

## Notes

- The frontend does not perform additional transformation on the API response.
- The page calls the API again when the period selector changes.
- Loading state is shown while data is fetched.
