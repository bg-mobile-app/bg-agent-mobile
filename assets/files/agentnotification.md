# Agent Notifications Screen Documentation

## URL
- https://demo.bideshgami.com/dashboard/notifications

## 1) Frontend Design
This page is an inbox-style notifications screen.

### Page Header
- Title: "Notifications"
- Subtitle: "Manage your latest activity and alerts"

### Main UI Elements
- A header with the page title and subtitle
- A "Mark all as read" button when there are unread notifications
- A list of notification cards
- Empty state when there are no notifications

### Notification Card Design
Each notification item shows:
- a bell icon
- notification title
- notification message
- relative time such as "2h ago"
- a "Take Action" link if the notification has a link
- a "Mark as read" button for unread notifications

### Visual Style
- White card container with rounded corners
- Soft border and shadow
- Unread notifications have a slightly blue tinted background
- Read notifications appear more neutral

---

## 2) API Request to Load Notifications
### Endpoint
- GET `/main/notifications/`

### Frontend API Call
The page calls this endpoint on load using `authApi.get(...)`.

### Example Request
```http
GET /main/notifications/
```

---

## 3) API Response for Notifications
The API returns an array of notification objects.

### Notification Object Shape
```ts
interface Notification {
  id: number;
  title: string;
  message: string;
  linkUrl: string | null;
  notification_type: string;
  isRead: boolean;
  createdAt: string;
}
```

### Example Response
```json
[
  {
    "id": 1,
    "title": "Booking Updated",
    "message": "Your booking status has changed.",
    "linkUrl": "/dashboard/booking/my",
    "notification_type": "BOOKING",
    "isRead": false,
    "createdAt": "2024-06-27T10:00:00Z"
  }
]
```

---

## 4) How the UI Uses the API Response
The page stores the API response in local state:

```ts
const [notifications, setNotifications] = useState<Notification[]>([]);
```

Then it renders each item as a row/card in the UI.

### Field Mapping
- `title` -> shown as the main heading
- `message` -> shown as the detail text
- `createdAt` -> shown as a relative time string via `timeAgo(...)`
- `linkUrl` -> shown as a clickable "Take Action" link
- `isRead` -> controls unread/read styling and whether the mark-as-read button appears

---

## 5) Mark as Read Action
There are two mark-as-read actions:

### A) Mark all as read
- Button text: "Mark all as read"
- Sends:

```http
POST /main/notifications/mark-read/
```

with payload:

```json
{ "id": "ALL" }
```

### B) Mark one notification as read
- Button text: "Mark as read"
- Sends:

```http
POST /main/notifications/mark-read/
```

with payload:

```json
{ "id": 123 }
```

### What happens after success
- The local UI updates the notification to `isRead: true`
- The unread styling disappears
- The item is visually treated as read

---

## 6) Take Action Link
If a notification has `linkUrl`, the UI shows a "Take Action" link.

### What it does
- Navigates the user to the linked page
- Before navigation, it also marks that specific notification as read

---

## 7) Empty State
If the API returns no notifications, the page shows:
- an inbox icon
- text: "Your inbox is empty"
- subtitle: "We'll notify you when something happens."

---

## 8) Summary
- Page URL: `/dashboard/notifications`
- Loads notifications from `/main/notifications/`
- Shows titles, messages, timestamps, and action links
- Supports marking notifications as read individually or all at once
- Uses the response fields to control styling, links, and empty state behavior
