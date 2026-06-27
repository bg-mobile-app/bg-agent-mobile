# Agent Dashboard Screen Documentation

## URL
- https://demo.bideshgami.com/dashboard/agent

## Frontend Design
This screen is the agent dashboard overview page.

### Page Component
- Frontend page: app/dashboard/agent/page.tsx

### UI Structure
The page shows:
- A top heading: "Dashboard Overview"
- A period selector dropdown
- A grid of summary cards

### Summary Cards
The dashboard displays these cards:
- My Booking
- Under Processing
- Success Flight
- Return Passport
- Total Payment
- Paid Payment
- Due Payment
- Commission

### Design Style
- Page has padding and spacing
- Cards are arranged in a responsive grid
- Each card is a colored summary card using the shared component DashboardSmallColorCard
- The cards use different background colors for visual distinction

### Behavior
- On initial load, the page fetches data for the default period: "Today"
- When the user changes the period from the dropdown, the page fetches data again for the selected period

---

## API
### Endpoint
- GET `/filter/agent/stats/?period={period}`

### Frontend API Function
- Source: api/common/dashboard.api.ts
- Function: getAgentDashboard(period)

### Request Example
```http
GET /filter/agent/stats/?period=Today
```

### Request Details
- Method: GET
- Authentication: required via `authApi`
- Query parameter:
  - `period`: selected dashboard period

### Response Shape
The frontend expects an object with these fields:

```ts
interface Props {
  total: number;
  successFlight: number;
  rejectFlight: number;
  processing: number;
  returnProcessing: number;
  totalAmount: number;
  paidAmount: number;
  dueAmount: number;
  commissionAmount: number;
}
```

### Example API Response
```json
{
  "total": 125,
  "successFlight": 48,
  "rejectFlight": 7,
  "processing": 32,
  "returnProcessing": 10,
  "totalAmount": 1250000,
  "paidAmount": 980000,
  "dueAmount": 270000,
  "commissionAmount": 150000
}
```

### What the API Response Means
- `total`: total booking count for the selected period
- `processing`: bookings still under processing
- `successFlight`: successful flight/booked files
- `returnProcessing`: return passport related records
- `totalAmount`: total payment amount
- `paidAmount`: already paid amount
- `dueAmount`: pending due amount
- `commissionAmount`: commission earned for the agent

### Data Mapping
The API response is mapped to the cards as follows:
- `total` -> My Booking
- `processing` -> Under Processing
- `successFlight` -> Success Flight
- `returnProcessing` -> Return Passport
- `totalAmount` -> Total Payment
- `paidAmount` -> Paid Payment
- `dueAmount` -> Due Payment
- `commissionAmount` -> Commission

### Frontend Flow
1. On page load, the component calls `getAgentDashboard("Today")`
2. The returned object is stored in component state
3. The values are displayed in the colored cards
4. When the period dropdown changes, a new request is sent with the selected period

---

## Available Period Values
The dropdown uses these values:
- Today
- This Week
- This Month
- This Year
- Last Year
- Last 2 Years
- Last 3 Years
- Last 4 Years
- Last 5 Years

---

## Important Notes
- This screen is a read-only analytics/dashboard view.
- It does not contain charts or tables.
- It uses the authenticated axios instance (`authApi`).
- The screen is specific to the agent role and uses the agent stats endpoint.
