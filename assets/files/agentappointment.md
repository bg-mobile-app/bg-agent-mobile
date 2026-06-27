# Agent Appointment Screen Documentation

## URL
- https://demo.bideshgami.com/dashboard/booking/appointment

## 1) Frontend Design
This is the appointment booking list page for the agent role.

### Page Title
- Heading: "All Appointment Booking"

### UI Elements
- Search input
- Date range filter (from date and to date)
- Clear filter button
- Pagination
- Data table

### Table Columns
- Post ID
- Booking ID
- Full Name
- Country
- Visa Category
- Meeting
- Date & Time
- Overview

### Row Action
Each row has a button labeled "Download" with an eye icon.

### Page Style
- White page background
- Search/date filter controls with bordered input boxes
- Table with alternating row hover effect
- Blue action button for opening the appointment ticket view

---

## 2) API Request for the List Page
### Endpoint
- GET `/booking/wp/my-bookings/`

### Frontend API Function
- Source: components/dashboard/general/api/api.dashboard.ts
- Function: myAppointments({ debouncedSearch, fromDate, toDate, currentPage })

### Request Parameters
The request sends these query parameters:
- `search`
- `page`
- `apt_from_date`
- `apt_to_date`

### Example Request
```http
GET /booking/wp/my-bookings/?search=&page=1&apt_from_date=&apt_to_date=
```

---

## 3) API Response for the List Page
The API response is a paginated object with:

```ts
{
  count: number;
  pageSize: number;
  results: [];
}
```

### Booking Item Fields Used in the Table
Each result item contains:
- `id`
- `workPermitSlug`
- `workPermitId`
- `name`
- `passportNo`
- `toCountry`
- `serviceType`
- `appointmentDate`

### Example Response
```json
{
  "count": 10,
  "pageSize": 10,
  "results": [
    {
      "id": 25,
      "workPermitSlug": "wp-001",
      "workPermitId": "WP-001",
      "name": "John Doe",
      "passportNo": "AB123456",
      "toCountry": "UAE",
      "serviceType": "Work Permit",
      "appointmentDate": "2024-06-01T14:00:00Z"
    }
  ]
}
```

---

## 4) What the Action Is
The action in the list page is the "Download" button in the Overview column.

### What it does
When the user clicks it, the app navigates to:
- `/dashboard/booking/appointment/{bookingId}`

### Frontend Route
- Page route: app/dashboard/(common-route)/booking/appointment/[id]/page.tsx

### What happens on click
- The detail page loads the appointment ticket data for that booking ID
- The page then renders the ticket UI

---

## 5) What the Download Action Is
The download action is the button inside the appointment ticket screen.

### Button Label
- "Download Appointment Ticket (PDF)"

### What it does
When clicked, the frontend:
1. Captures the visible ticket UI
2. Converts it into a canvas
3. Generates a PDF from that canvas
4. Downloads the file as:
   - `ticket-{id}.pdf`

### Frontend Logic
- Component: components/dashboard/common/booking/appointment/AppointmentBookingTicket.tsx
- Libraries used:
  - html2canvas-pro
  - jspdf

### Important Note
This is not a server-side file download endpoint.
It is a client-side PDF generation action.

---

## 6) Ticket API Response
When the detail page loads, it calls this API:

### Endpoint
- GET `/booking/wp/appointment/{id}/ticket/`

### Frontend API Call
- Source: app/dashboard/(common-route)/booking/appointment/[id]/page.tsx
- It uses `authApi.get(`/booking/wp/appointment/${id}/ticket/`)

### Ticket Response Shape
```ts
interface WPBTicketGETProps {
  id: number;
  qr: string;
  name: string;
  passportNo: string;
  appointmentDate: string;
  toCountry: string;
}
```

### Example Response
```json
{
  "id": 25,
  "qr": "https://example.com/qr.png",
  "name": "John Doe",
  "passportNo": "AB123456",
  "appointmentDate": "2024-06-01T14:00:00Z",
  "toCountry": "UAE"
}
```

---

## 7) Ticket Design
The ticket is a custom appointment ticket card with a modern blue gradient background.

### Main Layout
- A large rounded card
- Two-column layout on desktop
- Single-column layout on mobile

### Left Section
- Shows the booking ID as: `SL-BG-{id}`
- Shows a QR code image
- Has white rounded background and decorative circles

### Right Section
- Shows the company logo on the top-left
- Shows appointment date and time on the top-right
- Shows the applicant name in large uppercase text
- Shows:
  - Passport Number
  - Country
- Shows service information blocks:
  - Office Address
  - Service
  - Meeting Type

### Visual Style
- Blue gradient background
- White text
- Decorative circular shapes
- Background world map image in the corner
- Rounded corners and padding

### Ticket Footer Action
- A download button appears below the ticket
- Clicking it downloads the ticket as PDF

---

## 8) Summary
- Main page: `/dashboard/booking/appointment`
- List page shows appointment bookings with filters and pagination
- Action button navigates to the appointment ticket page
- Ticket data comes from `/booking/wp/appointment/{id}/ticket/`
- Download action creates a PDF from the ticket UI
- Ticket design is a branded blue appointment card with QR code and applicant details
