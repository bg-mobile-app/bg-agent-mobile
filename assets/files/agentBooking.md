# Agent Booking Screen Documentation

## URL
- https://demo.bideshgami.com/dashboard/booking/my

## Frontend Design
This screen shows the agent's booking list page, which is a shared booking table used for the agent role.

### Page Component
- Frontend route: app/dashboard/(common-route)/booking/my/page.tsx
- Main UI component: components/dashboard/common/booking/our-file/DashboardBookingList.tsx

### UI Structure
The page includes:
- A page title: "All Booking File"
- A search input
- A date range filter (from date and to date)
- A status dropdown
- A clear filter button
- A data table with booking rows
- Pagination at the bottom

### Table Columns
Each booking row displays:
- Post ID
- Booking ID
- Service Type
- Date
- Customer Info
- Package Price
- Paid Amount
- Status
- Actions

### Row Actions
Each row has an actions menu with:
- Reject (only for `APPLIED_FILE` status)
- View Return Reason (if return file exists)
- Return Passport (for eligible statuses)
- View Document

### Design Style
- White background page layout
- Search and filter controls with bordered inputs
- Table with alternating hover states
- Action buttons in a small dropdown menu

### Behavior
- The page loads bookings automatically on first render
- Search and date filters update the list after a short debounce
- Status changes or pagination trigger a new data fetch

---

## API Request
### Endpoint
- GET `/booking/wp/my-bookings/`

### Frontend API Function
- Source: components/dashboard/general/api/api.dashboard.ts
- Function: myBookings({ status, debouncedSearch, fromDate, toDate, currentPage })

### Request Parameters
The request sends these query parameters:
- `status`
- `search`
- `page`
- `from_date`
- `to_date`

### Example Request
```http
GET /booking/wp/my-bookings/?status=&search=AB123456&page=1&from_date=&to_date=
```

---

## API Response
### Response Shape
The API returns a paginated object with:

```ts
interface TypesHandler<T> {
  count: number;
  pageSize: number;
  results: T[];
}
```

### Booking Item Response Shape
```ts
interface WPMyBookingGETProps {
  id: number;
  workPermitSlug: string;
  workPermitId: string;
  name: string;
  passportNo: string;
  fromCountry: string;
  toCountry: string;
  status: string;
  statusLabel: string;
  customerTotal: string;
  paidAmount: string;
  commission: string;
  serviceType: string;
  branch: string;
  createdAt: string;
  appointmentDate: string;
  medicalExpiryDate?: string;
  policeClearanceExpiryDate?: string;
  visaExpiryDate?: string;
  flightDate?: string;
  returnFile?: BookingReturnInfo;
}
```

### Example API Response
```json
{
  "count": 25,
  "pageSize": 10,
  "results": [
    {
      "id": 101,
      "workPermitSlug": "wp-001",
      "workPermitId": "WP-001",
      "name": "John Doe",
      "passportNo": "AB123456",
      "fromCountry": "Bangladesh",
      "toCountry": "UAE",
      "status": "APPLIED_FILE",
      "statusLabel": "Under Processing",
      "customerTotal": "50000",
      "paidAmount": "40000",
      "commission": "5000",
      "serviceType": "Work Permit",
      "branch": "Dhaka",
      "createdAt": "2024-05-15T08:00:00Z",
      "appointmentDate": "2024-06-01T14:00:00Z"
    }
  ]
}
```

---

## Which API Response Value Is Used Where

### 1. Post ID Column
- Uses: `item.workPermitId`
- Link target: `/work-permit/${item.workPermitSlug}`

### 2. Booking ID Column
- Uses: `item.id`

### 3. Service Type Column
- Uses: `item.serviceType`

### 4. Date Column
- Uses: `item.createdAt`
- Displayed with `formatDate(...)`

### 5. Customer Info Column
- Uses:
  - `item.name`
  - `item.passportNo`

### 6. Package Price Column
- Uses: `item.customerTotal`
- Displayed as: `৳ {item.customerTotal}`

### 7. Paid Amount Column
- Uses: `item.paidAmount`
- Displayed as: `৳ {item.paidAmount}`

### 8. Status Column
- Uses: `item.statusLabel`

### 9. Actions Column
- Uses:
  - `item.status` for action eligibility
  - `item.returnFile.reason` for view return reason

---

## Status Filter Options
The dropdown uses these values from the shared status list:

```ts
newBookingStatus = [
  { label: "Under Processing", value: "APPLIED_FILE,BG_COLLECT_PP,BG_SENT_PP,A_RECEIVE_PP,UNDER_PROCESSING,VISA_APPROVED,BMET_DONE,TICKET_DONE,PP_SENT_TO_BG,BG_RECEIVED_PP,READY_FOR_FLIGHT" },
  { label: "Success File", value: "SUCCESS_FLIGHT" },
  { label: "Return Passport", value: "RETURN_REQUEST,RETURN_ACCEPTED,RETURN_PP_SENT_TO_BG,BG_COLLECT_RETURN_PP,BG_HANDOVER_PP_TO_CUSTOMER,REJECT_FILE" }
]
```

---

## Success File and Return Passport Views
These two routes are not separate booking APIs. They are filtered versions of the same booking list screen that is already used by the main My Booking page.

### 1) Success File Page
- URL: https://demo.bideshgami.com/dashboard/booking/my/success-file
- Route file: app/dashboard/(common-route)/booking/my/success-file/page.tsx
- UI component: components/dashboard/common/booking/our-file/DashboardBookingSuccessList.tsx

#### What API response shows
It calls the same API as the main My Booking page:
- GET `/booking/wp/my-bookings/`

But it sends this status filter:
- `status=SUCCESS_FLIGHT`

So the response shows only bookings whose booking status is in the success-flight state.

#### What this page displays
- Search by passport or ID
- Date filter
- Pagination
- A table of successful flight bookings
- A View Document action for each booking

### 2) Return Passport Page
- URL: https://demo.bideshgami.com/dashboard/booking/my/return-passport
- Route file: app/dashboard/(common-route)/booking/my/return-passport/page.tsx
- UI component: components/dashboard/common/booking/our-file/DashboardBookingReturnList.tsx

#### What API response shows
It also uses the same endpoint:
- GET `/booking/wp/my-bookings/`

But it sends a grouped return-related status filter:
- `status=RETURN_REQUEST,RETURN_ACCEPTED,RETURN_PP_SENT_TO_BG,BG_COLLECT_RETURN_PP,BG_HANDOVER_PP_TO_CUSTOMER,REJECT_FILE`

So the response shows only bookings that are in the return-passport workflow.

#### What this page displays
- Search by passport or ID
- Date filter
- Pagination
- A table of bookings that need return-passport handling
- A View Document action for each booking

---

## Why These Are Under “My Booking”
These pages are under the My Booking section because they are all part of the same booking workflow:
- “My Booking” = all booking files
- “Success File” = only completed/success bookings
- “Return Passport” = only bookings that are in return-passport handling

They are connected by the same frontend component structure and the same backend endpoint, with different status filters.

---

## Connection Between the Three Pages
The connection is simple and direct:

1. Main My Booking page
   - Calls `/booking/wp/my-bookings/` with no specific status filter
   - Shows all booking records

2. Success File page
   - Calls the same endpoint
   - Filters by `SUCCESS_FLIGHT`
   - Shows only successful bookings

3. Return Passport page
   - Calls the same endpoint
   - Filters by return-related statuses
   - Shows only bookings in the passport-return process

### In short
- Same API endpoint
- Same response shape
- Different status filter values
- Different UI views of the same booking data

---

## Notes
- This is a list/search/pagination screen for bookings.
- The data is fetched from the authenticated booking API.
- The screen is shared and used by the agent role through the route `/dashboard/booking/my`.
- The success-file and return-passport pages are just filtered shortcuts inside the same booking module.
