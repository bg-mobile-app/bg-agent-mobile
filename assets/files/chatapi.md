# Live Chat API — Mobile Integration Spec

## REST Endpoints

These must be called before/around the WebSocket connection — create the conversation first, load history on open, and mark messages read on view.

### 1. Create a conversation
```
POST /chat/conversations/
```
**Request body**
```json
{
 "participant_name": "Customer1",
 "participant_role": "CUSTOMER",
 "receiver_role": "CALL_CENTER",
 "work_permit_id": "13"
}
```
**Response** `201`
```json
{
 "id": "91b29b55-63e6-48ac-a73e-7266a6ed264d",
 "workPermitId": 13,
 "workPermitRef": "plumber-saudi-arabia",
 "receiverRole": "CALL_CENTER",
 "branchId": null,
 "branchName": null,
 "assignedToName": null,
 "assignedToCode": null,
 "assignedToRole": null,
 "status": "pending",
 "createdAt": "2026-06-21T17:30:06.732289+06:00",
 "updatedAt": "2026-06-21T17:32:54.637124+06:00",
 "lastMessageContent": "how can I help you",
 "lastMessageTime": "2026-06-21T11:32:54.633205+00:00",
 "unreadCount": 1,
 "participantName": "Customer1",
 "participantRole": "CUSTOMER",
 "isOnline": false,
 "isNew": false
}
```
Use the returned `id` as `conversation_id` for the WebSocket connection and the two endpoints below.

> MAP: confirm whether `participant_name`/`participant_role` are required for authenticated users too, or only needed for guest-initiated conversations — if a logged-in user creates a conversation, the server likely already knows their name/role from the JWT and these fields may be ignored or optional. Confirm with backend.

### 2. Get message history
```
GET /conversations/{conversation_id}/messages/?limit=40
```
Optional query params — confirm with backend whether pagination beyond `limit` exists (e.g. a `before_id` or cursor param for loading older messages), since the response includes `oldestId` which implies there's a way to page backward.

**Response** `200`
```json
{
 "messages": [
   {
     "id": "ff16b181-82f0-4edf-85c5-1cb3390a42b5",
     "senderName": "Customer1",
     "senderRole": "CUSTOMER",
     "senderExternalId": null,
     "senderUserCode": "USR_00001",
     "content": "Hi, I need help with my work permit.\n🔗 http://127.0.0.1:3000/work-permit/plumber-saudi-arabia",
     "timestamp": "2026-06-21T17:30:07.028961+06:00",
     "isRead": true,
     "readAt": "2026-06-21T17:31:29.680732+06:00",
     "attachmentUrl": null,
     "attachmentName": null
   }
 ],
 "hasMore": false,
 "oldestId": "ff16b181-82f0-4edf-85c5-1cb3390a42b5"
}
```
- Messages are ordered newest-first (confirm with backend — verify against actual order, don't assume from one sample).
- `attachmentUrl`/`attachmentName` are present in the schema but not exercised in the sample above — confirm with backend whether file/image attachments are supported yet, and if so, get the upload flow (separate endpoint? multipart on send?) since it isn't covered by the WS `chat_message` payload documented below.
- Use this endpoint to load history on conversation open and on reconnect after a dropped WS connection (per the open item flagged earlier in this doc).

### 3. Mark messages as read
```
POST /conversations/{conversation_id}/mark_read/
```
No request body shown in testing — confirm with backend if an empty POST is sufficient or if a body is expected.

**Response**: confirm status code and body with backend — not captured in testing notes. Likely `200` with no content or a simple `{"status": "ok"}`.

> Note: this duplicates the WS `read_receipt` message type. Confirm with backend which one is authoritative — if both exist, decide whether mobile should call this REST endpoint, send the WS message, or both. Calling both for every read could double up `read_at` writes; harmless but redundant.

### 4. List conversations
```
GET /chat/conversations/
```
**Response** `200`
```json
[
 {
   "id": "1d91c2b7-0018-45a2-a986-9d82d6a4324b",
   "workPermitId": 26,
   "workPermitRef": "postman-test-afghanistan",
   "receiverRole": "CALL_CENTER",
   "branchName": null,
   "assignedToName": null,
   "assignedToRole": null,
   "status": "open",
   "createdAt": "2026-05-12T16:11:57.127492+06:00",
   "updatedAt": "2026-05-12T16:34:53.140150+06:00",
   "lastMessageContent": "hi",
   "lastMessageTime": "2026-05-12T10:34:53.134144+00:00",
   "unreadCount": 0,
   "participantName": "Customer1",
   "participantRole": "CUSTOMER",
   "isOnline": false
 }
]
```
- Scoped to the authenticated user automatically — confirm with backend exactly how scoping works (own conversations only, vs agency-wide for staff roles), matching the pattern used elsewhere in the codebase (`my_bookings`-style role-based filtering).
- No pagination wrapper visible in the sample (plain array, not `{results: [...], count: ...}`) — confirm whether this list is paginated at all, since an unbounded list could grow large for long-time users.
- Note `status` values seen so far: `"pending"`, `"open"` — confirm the full enum (likely also `"closed"`/`"resolved"`) so mobile can build status-based UI (badges, filters) without guessing.

---

## WebSocket API

### Connection

**URL**
```
wss://api.bideshgami.com/ws/chat/{conversation_id}/
```

`conversation_id` is a UUID. It must already exist — created via the REST conversation-create endpoint *(link separately — not covered here)*.

### Authentication (required)

Send the JWT access token as a header on the WebSocket handshake:

```
Authorization: Bearer {access_token}
```

This is the **preferred** method — most WS client libraries (OkHttp on Android, `URLSessionWebSocketTask` on iOS) support setting custom handshake headers.

**Fallback only** if your WS library cannot set handshake headers:
```
wss://api.bideshgami.com/ws/chat/{conversation_id}/?token={access_token}
```
Avoid this where possible — query params can leak into logs. Use only if the header approach isn't available in your client library.

If no valid token is provided, the connection is treated as a **guest session**. For guest sessions, also pass:
```
?user_id={guest_id}&role={role}
```
`role` defaults to `CUSTOMER` if omitted. Skip `user_id`/`role` entirely for authenticated users — they're ignored when a valid token is present.

### Connection outcomes

| Close code | Meaning |
|---|---|
| (connects normally) | Access granted |
| `4003` | Access denied — wrong role for this conversation, branch mismatch, or conversation does not exist |
| `4401` | App/auth identity check failed *(if API-key gate is added — confirm with backend before relying on this)* |

If the connection closes immediately after opening, check the close code before retrying.

---

## Outgoing messages (app → server)

All messages are JSON text frames with a `"type"` field.

### Send a chat message
```json
{
 "type": "chat_message",
 "content": "Hello, I need help with my application"
}
```
- For **authenticated users**: only `content` is needed. `sender_name`/`sender_role` are ignored — server fills these from the DB.
- For **guest users**, also include:
```json
{
 "type": "chat_message",
 "content": "Hello",
 "sender_name": "Jane Doe",
 "sender_role": "CUSTOMER"
}
```

### Typing indicator
```json
{
 "type": "typing",
 "user_name": "Jane Doe"
}
```

### Mark messages as read
```json
{
 "type": "read_receipt"
}
```
No payload needed beyond `type`. This marks all unread messages *not sent by you* as read.

---

## Incoming messages (server → app)

Listen for these `"type"` values on the socket:

### `chat_message`
Sent to everyone in the conversation whenever any participant sends a message (including your own, echoed back).
```json
{
 "type": "chat_message",
 "message": {
   "id": "550e8400-e29b-41d4-a716-446655440000",
   "senderExternalId": null,
   "senderUserCode": "USR-00123",
   "senderName": "Jane Doe",
   "senderRole": "CUSTOMER",
   "content": "Hello, I need help with my application",
   "timestamp": "2026-06-21T10:15:30.123456+06:00",
   "isRead": false
 }
}
```
- `senderExternalId`: populated only for guest senders, otherwise `null`
- `senderUserCode`: populated only for authenticated senders, otherwise `null`

### `typing`
```json
{
 "type": "typing",
 "user_id": "42",
 "user_code": "USR-00123",
 "user_name": "Jane Doe",
 "role": "CUSTOMER"
}
```
`user_code` is `null` for guest senders.

### `user_status`
Sent when any participant connects or disconnects.
```json
{
 "type": "user_status",
 "user_id": "42",
 "role": "CUSTOMER",
 "is_online": true
}
```

### `read_receipt`
Broadcast to the room when someone marks messages as read.
```json
{
 "type": "read_receipt",
 "reader_id": "42",
 "role": "CUSTOMER"
}
```

---

### Notes for implementation

- This is a **plain WebSocket**, not Socket.IO — no auto-reconnect, no event-acknowledgement layer built in. Implement your own reconnect-with-backoff logic on the client.
- The server sends no heartbeat/ping frames at the application level — rely on standard WS ping/pong at the transport layer, or implement an app-level keepalive if your platform's WS library needs one to avoid idle timeouts on mobile networks.
- Malformed JSON sent to the server is silently dropped — no error frame is returned. Validate your JSON client-side before sending.
- On reconnect after a dropped connection, there is currently no "missed messages since X" replay — confirm with backend whether message history should be re-fetched via a REST endpoint after reconnect *(not covered in this spec — flag if missing)*.

## Open items to confirm with backend before mobile dev starts

1. Whether the `4401` API-key-style gate is actually implemented on the WS endpoint, and if so, the exact header name/format mobile must send.
2. Token refresh flow — confirm the existing `/api/r/auth/mobile/token/refresh/` endpoint is used so mobile knows when to refresh before reconnecting the socket after a token expires mid-session.
3. `participant_name`/`participant_role` requirement on conversation-create for authenticated (non-guest) users — likely redundant with JWT-derived identity, confirm if optional.
4. Pagination/cursor params for `GET .../messages/` beyond `limit` (older-message paging using `oldestId`).
5. Attachment upload flow — `attachmentUrl`/`attachmentName` fields exist in the message schema but no upload mechanism has been specified yet.
6. `mark_read` endpoint's exact response shape, and whether it's redundant with the WS `read_receipt` message (pick one as authoritative, or confirm both are intentionally supported).
7. Full `status` enum for conversations (`pending`, `open`, and likely others) for mobile UI.
8. Pagination on `GET /chat/conversations/` list — currently returns a plain array with no visible page wrapper.
