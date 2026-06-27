# Agent Commission Screen Documentation

## URL
- https://demo.bideshgami.com/dashboard/agent/commission

## 1) Frontend Design
This page shows the agent commission list screen.

### Page Title
- "Commission List"

### UI Elements
- Search input
- Date range filter (from date and to date)
- Clear filter button
- Pagination
- Data table

### Table Columns
- Post ID
- Booking ID
- From, To, Service Type
- Apply Date & Status
- Customer Info
- Package Price
- Paid Amount
- Commission

### Page Style
- White background page
- Search and date filters with bordered input controls
- Blue heading text
- Table with hover effect
- Pagination at the bottom

---

## 2) API Request
### Endpoint
- GET `/booking/wp/my-bookings/`

### Frontend API Function
- Source: components/dashboard/general/api/api.dashboard.ts
- Function: myBookings({ status, debouncedSearch, fromDate, toDate, currentPage })

### Request Parameters Used Here
The commission page sends:
- `status=` (empty string)
- `search`
- `page`
- `from_date`
- `to_date`

### Example Request
```http
GET /booking/wp/my-bookings/?status=&search=AB123456&page=1&from_date=&to_date=
```

---

## 3) API Response
The API returns a paginated response object like this:

```ts
{
  count: number;
  pageSize: number;
  results: [];
}
```

### Booking Item Fields Used in the Commission Page
Each item in `results` contains fields such as:
- `id`
- `workPermitSlug`
- `workPermitId`
- `fromCountry`
- `toCountry`
- `serviceType`
- `createdAt`
- `statusLabel`
- `name`
- `passportNo`
- `customerTotal`
- `paidAmount`
- `commission`

### Example Response
```json
{
  "count": 12,
  "pageSize": 10,
  "results": [
    {
      "id": 101,
      "workPermitSlug": "wp-001",
      "workPermitId": "WP-001",
      "fromCountry": "Bangladesh",
      "toCountry": "UAE",
      "serviceType": "Work Permit",
      "createdAt": "2024-05-15T08:00:00Z",
      "statusLabel": "Under Processing",
      "name": "John Doe",
      "passportNo": "AB123456",
      "customerTotal": "50000",
      "paidAmount": "40000",
      "commission": "5000"
    }
  ]
}
```

---

## 4) How the UI Uses the API Response
The page stores the API data into local state using:

```ts
const [data, setData] = useState<TypesHandler<WPMyBookingGETProps>>(defaulTypeHandler);
```

Then it fills the table using:

```ts
setData(res);
```

### Field Mapping to UI Columns
- Post ID column -> `item.workPermitId`
- Booking ID column -> `item.id`
- From/To/Service Type column ->
  - `item.fromCountry`
  - `item.toCountry`
  - `item.serviceType`
- Apply Date & Status column ->
  - `item.createdAt` formatted by `formatDate(...)`
  - `item.statusLabel`
- Customer Info column ->
  - `item.name`
  - `item.passportNo`
- Package Price column -> `item.customerTotal`
- Paid Amount column -> `item.paidAmount`
- Commission column -> `item.commission`

### Important Note
The commission amount displayed on the page comes directly from the API response field `commission`.

---

## 5) Summary
- Page URL: `/dashboard/agent/commission`
- Frontend design: searchable commission list table
- API endpoint: `/booking/wp/my-bookings/`
- Response is paginated
- The UI maps response fields into the table rows and displays the commission value from `item.commission`
