# Return Accepted API and Events

This document outlines the API endpoints and events associated with the action buttons on the "Return Accepted" page.

## Action Buttons and Events

The following action buttons are available on the "Return Accepted" page:

### 1. Payment Request

*   **Event:** `onClick`
*   **Action:** Opens a confirmation dialog. If confirmed, it opens the `PaymentRequestModal` to initiate a payment request.
*   **API Call:** The `PaymentRequestModal` likely makes an API call to submit the payment request. The details of this API call are not directly visible in the `DashboardAgencyReturnAccepted.tsx` file but are handled within the `PaymentRequestModal` component.

### 2. See Reason

*   **Event:** `onClick`
*   **Action:** Opens the `ReasonModal` to display the reason for the return.
*   **API Call:** No API call is made. The reason is already available in the `item.returnFile.reason` property.

### 3. View Documents

*   **Event:** This is a Next.js `<Link>` component.
*   **Action:** Navigates the user to the documents page for the corresponding booking.
*   **API Call:** No direct API call is made on this page. The documents page will fetch the necessary data.

### 4. See Return Details

*   **Event:** This is a Next.js `<Link>` component.
*   **Action:** Navigates the user to the return request details page.
*   **API Call:** No direct API call is made on this page. The return request details page will fetch the necessary data.

### 5. Return PP Sent to BG

*   **Event:** `onClick`
*   **Action:** Triggers the `onAction` handler, which opens a confirmation dialog. If confirmed, it calls the `updateBookingStatus` function to update the booking status to `RETURN_PP_SENT_TO_BG`.
*   **API Call:** The `updateBookingStatus` function makes a `PATCH` request to the following endpoint:
    *   **Endpoint:** `/booking/wp/status/<pk>/set/`
    *   **Payload:** `{ "status": "RETURN_PP_SENT_TO_BG" }`

## Implementation Details

The API calls are defined in the [`/Users/aestheticinterior/Documents/Rayhan-work/bg-frontend/features/dashboard/admin/terminal/booking/api.ts`](file:///Users/aestheticinterior/Documents/Rayhan-work/bg-frontend/features/dashboard/admin/terminal/booking/api.ts) file. The `updateBookingStatus` function is used to change the status of a booking.

```typescript
export const updateBookingStatus = async (pk: number, formData: Props) => {
    const res = await authApi.patch(`/booking/wp/status/${pk}/set/`, formData);
    return res.data;
};
```

The `handle` function in [`/Users/aestheticinterior/Documents/Rayhan-work/bg-frontend/features/dashboard/agency/booking/return/DashboardAgencyReturnAccepted.tsx`](file:///Users/aestheticinterior/Documents/Rayhan-work/bg-frontend/features/dashboard/agency/booking/return/DashboardAgencyReturnAccepted.tsx) orchestrates the confirmation and API call for status updates.

```typescript
const handle = (
    row: WPBookingReturnGETProps,
    status: BookingStatus2,
    confirmMsg: string,
    successMsg: string,
) => MsgConfirmation(
    async () => {
        await updateBookingStatus(row.id, { status });
        toast.success(successMsg);
        load();
    },
    confirmMsg
);
```



# Return Request API and Events

This document outlines the API endpoints and events associated with the action buttons on the "Return Request" page.

## Action Buttons and Events

The following action buttons are available on the "Return Request" page for each booking:

### 1. See Reason

*   **Event:** `onClick`
*   **Action:** Opens the `ReasonModal` to display the reason for the return request.
*   **API Call:** No API call is made. The reason is already available in the `item.returnFile.reason` property.

### 2. View Documents

*   **Event:** This is a Next.js `<Link>` component.
*   **Action:** Navigates the user to the documents page for the corresponding booking.
*   **API Call:** No direct API call is made on this page. The documents page will fetch the necessary data.

### 3. Accept Return Passport

*   **Event:** This is a Next.js `<Link>` component.
*   **Action:** Navigates the user to a page where they can accept the return of the passport.
*   **API Call:** No direct API call is made on this page. The subsequent page will handle the API interaction for accepting the passport.

## API Endpoint for Submitting a Return Request

The action of submitting a return request is handled by the `submitReturnRequest` function, which sends a `POST` request to the following endpoint:

**Endpoint:** `/booking/wp/return/file-request/`

## Request Payload

The `submitReturnRequest` function sends a JSON payload with the following properties:

| Field         | Type           | Description                                                                                             |
|---------------|----------------|---------------------------------------------------------------------------------------------------------|
| `bookingId`   | `number`       | The ID of the booking for which the return is being requested.                                          |
| `costAmount`  | `number` or `string` (optional) | The amount of money spent on the booking.                                                               |
| `costDetails` | `string` (optional)       | A detailed breakdown of the costs incurred.                                                             |
| `reason`      | `string`       | The reason for the return request. This can be pre-filled from the booking or entered by the user.      |

## Implementation

The API call is made in the `submitReturnRequest` function, located in the [`/Users/aestheticinterior/Documents/Rayhan-work/bg-frontend/features/dashboard/admin/terminal/booking/api.ts`](file:///Users/aestheticinterior/Documents/Rayhan-work/bg-frontend/features/dashboard/admin/terminal/booking/api.ts) file.

```typescript
export const submitReturnRequest = async (
    payload: ReturnRequestPayload
): Promise<{ success: boolean }> => {
    const res = await authApi.post(
        "/booking/wp/return/file-request/",
        payload
    );
    return res.data;
};
```

This function is called from the `onSubmit` handler in the [`/Users/aestheticinterior/Documents/Rayhan-work/bg-frontend/features/dashboard/agency/booking/return/DashboardAgencyReturnRequestAdd.tsx`](file:///Users/aestheticinterior/Documents/Rayhan-work/bg-frontend/features/dashboard/agency/booking/return/DashboardAgencyReturnRequestAdd.tsx) component when the user submits the return request form.


# Return Process API and Events

This document outlines the API endpoints and events associated with the "Return PP Sent to BG," "BG Collect Return PP," and "BG Handover PP to Customer" pages.

## Overview

The return process is managed through a series of status updates. The `updateBookingStatus` function is used to transition a booking through the different stages of the return process. This function sends a `PATCH` request to the `/booking/wp/status/<pk>/set/` endpoint with the new status.

## 1. Return PP Sent to BG

*   **Page/Component:** This action is triggered from the "Return Accepted" page (`DashboardAgencyReturnAccepted.tsx`).
*   **Action:** A button click triggers the `onAction` handler, which calls the `updateBookingStatus` function.
*   **API Call:**
    *   **Endpoint:** `PATCH /booking/wp/status/<pk>/set/`
    *   **Payload:** `{ "status": "RETURN_PP_SENT_TO_BG" }`

## 2. BG Collect Return PP

*   **Page/Component:** `app/dashboard/admin/accounts/booking/bg-collect-return-pp/page.tsx`
*   **Action:** A button click on the "Sent to Clear For Handover" button triggers a confirmation dialog. If confirmed, it calls the `updateBookingStatus` function.
*   **API Call:**
    *   **Endpoint:** `PATCH /booking/wp/status/<pk>/set/`
    *   **Payload:** `{ "status": "CLEAR_FOR_HANDOVER" }`

## 3. BG Handover PP to Customer

*   **Page/Component:** The component for this page is not explicitly named "Handover". It is likely part of a generic return management page that filters bookings by the "CLEAR_FOR_HANDOVER" status.
*   **Action:** A button click on this page would trigger the final status update to "HANDOVERED_TO_CUSTOMER".
*   **API Call:**
    *   **Endpoint:** `PATCH /booking/wp/status/<pk>/set/`
    *   **Payload:** `{ "status": "HANDOVERED_TO_CUSTOMER" }`

## Implementation Details

The core logic for updating the booking status is in the `updateBookingStatus` function in the [`/Users/aestheticinterior/Documents/Rayhan-work/bg-frontend/features/dashboard/admin/terminal/booking/api.ts`](file:///Users/aestheticinterior/Documents/Rayhan-work/bg-frontend/features/dashboard/admin/terminal/booking/api.ts) file.

```typescript
export const updateBookingStatus = async (pk: number, formData: Props) => {
    const res = await authApi.patch(`/booking/wp/status/${pk}/set/`, formData);
    return res.data;
};
```

The different pages in the return process call this function with the appropriate status to move the booking to the next stage.