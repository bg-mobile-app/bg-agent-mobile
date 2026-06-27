# Agent Payments Screen Documentation

## URL
- https://demo.bideshgami.com/dashboard/my-payments

## 1) Frontend Design
This page shows the user’s payment history list.

### Page Title
- "Payments History(Count)"
- Subtitle: "See history of your payment plan invoice"

### UI Elements
- Search input
- Status dropdown filter
- Pagination
- Data table

### Filter Options
The dropdown contains these payment step values:
- ADVANCE
- AFTER_VISA
- BEFORE_FLIGHT
- RETURN

### Table Columns
- Payment Invoice
- Booking ID
- Post ID
- Payment Date
- Passport No
- Amount
- Status

### Page Style
- White background page
- Search and filter controls with bordered inputs
- Table with hover effect
- Pagination at the bottom

---

## 2) API Request
### Endpoint
- GET `/payment/payments-history-list/`

### Frontend API Call
The page calls this API directly from the component using `authApi.get(...)`.

### Request Parameters
The request sends:
- `step` = selected status filter
- `search` = search text
- `page` = current page number

### Example Request
```http
GET /payment/payments-history-list/?step=&search=AB123456&page=1
```

---

## 3) API Response
The API response is a paginated object:

```ts
{
  count: number;
  results: [];
}
```

### Payment Item Fields Used in the Table
Each payment row contains:
- `id`
- `postId`
- `bookingId`
- `passportNo`
- `step`
- `amount`
- `collectedAt`

### Example Response
```json
{
  "count": 8,
  "results": [
    {
      "id": 77,
      "postId": "WP-001",
      "bookingId": "101",
      "passportNo": "AB123456",
      "step": "BEFORE_FLIGHT",
      "amount": "5000",
      "collectedAt": "2024-06-01T14:00:00Z"
    }
  ]
}
```

---

## 4) How the UI Uses the API Response
The page stores the response in state and renders it as rows in the table.

### Data Mapping
- Payment Invoice -> `#${item.id}`
- Booking ID -> `item.bookingId`
- Post ID -> `item.postId`
- Payment Date -> `formatDateTime(item.collectedAt)`
- Passport No -> `item.passportNo`
- Amount -> `৳ ${item.amount}`
- Status -> `item.step.replace("_", " ")`

### Status UI Behavior
- If `item.step === "RETURN"`, the status dot is shown in red
- Otherwise, it is shown in green

---

## 5) Summary
- Page URL: `/dashboard/my-payments`
- Frontend design: payment history table with search and filter
- API endpoint: `/payment/payments-history-list/`
- The UI shows payment records from the API response and maps each field to the table columns
