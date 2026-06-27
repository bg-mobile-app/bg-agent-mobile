# Agent Booking Document Action Documentation

## URL
- https://demo.bideshgami.com/dashboard/booking/documents/61

## What the Action Is
The action shown in the agent booking list is the "View Document" action.

When the user clicks it from the booking list, the app navigates to the booking documents page for that booking ID.

### Where It Comes From
- Source in booking list: components/dashboard/common/booking/our-file/DashboardBookingList.tsx
- The button uses a link:

```tsx
<Link href={`/dashboard/booking/documents/${item.id}`}>
  View Document
</Link>
```

---

## Frontend Design / What Happens
When the user clicks this action:
1. The app navigates to a new page using the booking ID.
2. The documents page loads the booking documents for that ID.
3. The page shows either:
   - a PDF document with a download button, or
   - an image with a download button
4. If no documents are found, it shows:
   - "No Documents Available!"

### Page Component
- Route: app/dashboard/(common-route)/booking/documents/[id]/page.tsx
- Main UI component: components/dashboard/common/booking/our-file/DashboardBookingDocuments.tsx

### UI Behavior
- Each document item is shown inside an accordion
- If the item has a `document` field, it is treated as a PDF
- Otherwise, it is treated as an image
- The user can download the file directly

---

## API Request
### Endpoint
- GET `/booking/wp/{id}/documents/`

### Frontend API Function
- Source: components/dashboard/general/api/api.dashboard.ts
- Function: wpbDocuments(id)

### Request Example
```http
GET /booking/wp/61/documents/
```

### Request Details
- Method: GET
- Authentication: required via `authApi`
- Path parameter:
  - `id`: booking ID

---

## API Response
### Response Shape
The response is an object with a `documents` array:

```ts
interface Props {
  documents: WPBDocumentsGETProps[]
}
```

### Document Item Shape
```ts
interface WPBDocumentsGETProps {
  id: number;
  document?: string;
  image?: string;
  createdAt: string;
}
```

### Example API Response
```json
{
  "documents": [
    {
      "id": 1,
      "document": "https://example.com/files/abc.pdf",
      "image": null,
      "createdAt": "2024-05-15T08:00:00Z"
    },
    {
      "id": 2,
      "document": null,
      "image": "https://example.com/files/abc.jpg",
      "createdAt": "2024-05-15T08:00:00Z"
    }
  ]
}
```

---

## How the API Response Is Used
- If `item.document` exists, the UI shows a PDF section and a download link
- If `item.image` exists, the UI shows an image preview and a download link
- If neither exists, the UI shows no valid content

### UI Mapping
- `item.document` -> PDF display + Download PDF button
- `item.image` -> Image preview + Download Image button
- `item.id` -> Accordion key

---

## Summary
- Action name: View Document
- Frontend route: `/dashboard/booking/documents/{bookingId}`
- API URL: `/booking/wp/{bookingId}/documents/`
- Purpose: fetch and display booking-related uploaded documents or images
