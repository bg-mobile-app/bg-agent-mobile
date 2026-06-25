# API Documentation: Agency Booking File Return Request
**URL**: `https://demo.bideshgami.com/dashboard/agency/booking-file/return/request`

---

## Overview
This page handles the display and management of booking file return requests from both customers and the agency. It allows viewing return requests with details about passports, costs, and payment information.

---

## API Endpoints

### 1. Get Return Request List
**Endpoint**: `/booking/wp/return/file-request/`  
**Method**: `GET`  
**Location**: `features/dashboard/admin/terminal/booking/api.ts`

#### Request Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `search` | string | No | Search term (e.g., passport number) |
| `page` | number | Yes | Page number for pagination |

#### Query String Example
```
/booking/wp/return/file-request/?search=&page=1
```

#### Response Structure
```typescript
interface TypesHandler<T> {
    count: number;        // Total number of records
    pageSize: number;     // Number of items per page
    results: T[];         // Array of return request items
}
```

#### Response Item Structure
```typescript
interface WPBookingReturnGETProps {
    id: number;
    workPermitSlug: string;
    workPermitId: string;
    name: string;
    phone: string;
    email: string;
    passportNo: string;
    fromCountry: string;
    toCountry: string;
    status: string;
    statusLabel: string;
    serviceType: string;
    branch: string;
    customerTotal: string;
    agencyTotalCost: string;
    paidAmount: number;
    agencyName?: string;
    agencyPhone?: string;
    rlNo?: string;
    returnFile?: BookingReturnInfo;
    createdAt: string;
    appointmentDate: string;
    medicalExpiryDate?: string | null;
    policeClearanceExpiryDate?: string | null;
    visaExpiryDate?: string | null;
    flightDate?: string | null;
    passportAt?: string;
    payoutRequests?: Array;
}
```

#### Return File Details
```typescript
interface BookingReturnInfo {
    id: number;
    packagePrice: string;
    receivedAmount: string;
    costAmount: string;
    requestAmount: string;
    agencyPaidAmount: string;
    status: string;                    // e.g., "RETURN_REQUEST", "RETURN_ACCEPTED"
    costDetails: string;
    reason: string;                     // Reason for return request
    requestedByType: "CUSTOMER" | "AGENCY";
    requestedAt: string;               // ISO datetime
    approvedAt: string | null;         // ISO datetime or null
    booking: number;
    agency: number;
    requestedBy: string;
    approvedBy: string | null;
}
```

#### Example Response
```json
{
    "count": 5,
    "pageSize": 10,
    "results": [
        {
            "id": 123,
            "workPermitSlug": "wp-2024-001",
            "workPermitId": "WP001",
            "name": "John Doe",
            "phone": "+880123456789",
            "email": "john@example.com",
            "passportNo": "AB123456",
            "fromCountry": "Bangladesh",
            "toCountry": "UAE",
            "status": "RETURN_REQUEST",
            "statusLabel": "Return Request",
            "serviceType": "Work Permit",
            "branch": "Dhaka",
            "customerTotal": "50000",
            "agencyTotalCost": "45000",
            "paidAmount": 40000,
            "agencyName": "ABC Agency",
            "agencyPhone": "+880987654321",
            "rlNo": "RL123",
            "returnFile": {
                "id": 456,
                "packagePrice": "50000",
                "receivedAmount": "40000",
                "costAmount": "5000",
                "requestAmount": "10000",
                "agencyPaidAmount": "5000",
                "status": "RETURN_REQUEST",
                "costDetails": "Processing fee: 5000",
                "reason": "Visa rejected due to medical issues",
                "requestedByType": "CUSTOMER",
                "requestedAt": "2024-06-20T10:30:00Z",
                "approvedAt": null,
                "booking": 123,
                "agency": 45,
                "requestedBy": "John Doe",
                "approvedBy": null
            },
            "createdAt": "2024-05-15T08:00:00Z",
            "appointmentDate": "2024-06-01T14:00:00Z",
            "medicalExpiryDate": "2025-06-01",
            "policeClearanceExpiryDate": "2025-07-01",
            "visaExpiryDate": null,
            "flightDate": null,
            "passportAt": "2024-05-10T12:00:00Z"
        }
    ]
}
```

---

### 2. Get Return Request Details
**Endpoint**: `/booking/wp/return/{pk}/simple-details/`  
**Method**: `GET`  
**Location**: `features/dashboard/admin/terminal/booking/api.ts`  
**URL**: `https://demo.bideshgami.com/dashboard/agency/booking-file/return/request/{id}`

#### Path Parameters
| Parameter | Type | Description |
|-----------|------|-------------|
| `pk` | number | Booking ID |

#### Response Structure
```typescript
interface WPBookingReturnDetailsProps {
    id: number;
    name: string;
    phone: string;
    email: string;
    passportNo: string;
    status: string;                    // Booking status
    
    customerTotal: string;             // Total cost from customer
    agencyTotalCost: string;          // Total cost from agency
    
    gender: string;
    serviceType: string;
    appointmentDate: string;
    createdAt: string;
    
    // Payment breakdown details
    agencyPaymentSteps: Array<{
        amount: string;
        requestType: string;
        payoutRequest: number;
        payoutRequestStep: string;
        payoutRequestStatus: string;
    }>;
    
    agencyPaidSteps: Array<{
        batch: number;
        batchStatus: string;
        amount: string;
        requestType: string;
        payoutRequest: number;
        payoutRequestStep: string;
        payoutRequestStatus: string;
    }>;
    
    paidSteps: Array<{
        booking: number;
        status: string;
        step: string;
        amount: string;
        sequence: number;
        transactionType: string;
        paymentMethod: string;
        collectedAt: string;
    }>;
    
    bookedByType: string;
    agencyPaidAmount: number;         // Amount paid by agency
    returnFile?: BookingReturnInfo;   // Return file details if exists
}
```

#### Example Response
```json
{
    "id": 123,
    "name": "John Doe",
    "phone": "+880123456789",
    "email": "john@example.com",
    "passportNo": "AB123456",
    "status": "RETURN_REQUEST",
    "customerTotal": "50000",
    "agencyTotalCost": "45000",
    "gender": "Male",
    "serviceType": "Work Permit",
    "appointmentDate": "2024-06-01T14:00:00Z",
    "createdAt": "2024-05-15T08:00:00Z",
    "agencyPaymentSteps": [
        {
            "amount": "15000",
            "requestType": "PARTIAL",
            "payoutRequest": 1,
            "payoutRequestStep": "STEP_1",
            "payoutRequestStatus": "COMPLETED"
        }
    ],
    "agencyPaidSteps": [
        {
            "batch": 1,
            "batchStatus": "COMPLETED",
            "amount": "15000",
            "requestType": "PARTIAL",
            "payoutRequest": 1,
            "payoutRequestStep": "STEP_1",
            "payoutRequestStatus": "COMPLETED"
        }
    ],
    "paidSteps": [
        {
            "booking": 123,
            "status": "COMPLETED",
            "step": "ADVANCE",
            "amount": "25000",
            "sequence": 1,
            "transactionType": "COLLECTION",
            "paymentMethod": "BANK_TRANSFER",
            "collectedAt": "2024-05-15T10:00:00Z"
        }
    ],
    "bookedByType": "AGENCY",
    "agencyPaidAmount": 40000,
    "returnFile": {
        "id": 456,
        "packagePrice": "50000",
        "receivedAmount": "40000",
        "costAmount": "5000",
        "requestAmount": "10000",
        "agencyPaidAmount": "5000",
        "status": "RETURN_REQUEST",
        "costDetails": "Processing fee: 5000",
        "reason": "Visa rejected due to medical issues",
        "requestedByType": "CUSTOMER",
        "requestedAt": "2024-06-20T10:30:00Z",
        "approvedAt": null,
        "booking": 123,
        "agency": 45,
        "requestedBy": "John Doe",
        "approvedBy": null
    }
}
```

#### Usage
Used on the return request detail/edit page to:
- Display booking information
- Show payment history and breakdown
- Pre-fill return request form with existing data
- Calculate agency refund/payment amounts

---

### 3. Submit Return Request
**Endpoint**: `/booking/wp/return/file-request/`  
**Method**: `POST`  
**Location**: `features/dashboard/admin/terminal/booking/api.ts`

#### Request Payload Structure
```typescript
interface ReturnRequestPayload {
    bookingId: number;
    costAmount?: number | string;
    requestAmount?: number | string;
    costDetails?: string;
    reason: string;                    // Required: Reason for return request
}
```

#### Example Request Body
```json
{
    "bookingId": 123,
    "costAmount": "5000",
    "requestAmount": "10000",
    "costDetails": "Processing fee and documentation",
    "reason": "Visa rejection - medical grounds"
}
```

#### Response
```typescript
{ 
    "success": boolean 
}
```

---

### 4. Get Booking Return Simple Details
**Endpoint**: `/booking/wp/return/{pk}/simple-details/`  
**Method**: `GET`  
**Location**: `features/dashboard/admin/terminal/booking/api.ts`

#### Path Parameters
| Parameter | Type | Description |
|-----------|------|-------------|
| `pk` | number | Booking ID |

#### Usage
```typescript
const details = await getBookingReturnSimpleDetails(123);
```

---

### 5. Get Booking Details
**Endpoint**: `/booking/wp/{pk}/`  
**Method**: `GET`  
**Location**: `features/dashboard/admin/terminal/booking/api.ts`

#### Path Parameters
| Parameter | Type | Description |
|-----------|------|-------------|
| `pk` | number | Booking ID |

#### Usage
```typescript
const booking = await getBookingDetails(123);
```

---

## Frontend Components

### Main Component
- **File**: `features/dashboard/agency/booking/return/DashboardAgencyReturnRequest.tsx`
- **Page**: `app/dashboard/agency/booking-file/return/request/page.tsx`

### Features
- Displays return requests with two tabs: "Customer Return" and "My Return"
- Search functionality by passport number
- Pagination support
- Actions menu with options to:
  - View reason for return
  - View documents
  - Accept return passport (for customers)

---

## Data Types

### Request Type
```typescript
type RequesterType = "CUSTOMER" | "AGENCY";
```

### Booking Status
```typescript
export const newBookingStatus = [
    { label: "Under Processing", value: 'APPLIED_FILE,BG_COLLECT_PP,...' },
    { label: "Success File", value: "SUCCESS_FLIGHT" },
    { 
        label: "Return Passport", 
        value: 'RETURN_REQUEST,RETURN_ACCEPTED,RETURN_PP_SENT_TO_BG,...' 
    },
];
```

---

## Usage Pattern

### Fetching Return Requests
```typescript
// From the API file
const getReturnRequest = async (search: string, page: number) => {
    const res = await authApi.get(
        `/booking/wp/return/file-request/?search=${search}&page=${page}`
    );
    return res.data;
};

// Usage in component
const res = await getReturnRequest(debouncedSearch, currentPage);
setData(res);
```

### Submitting a Return Request
```typescript
const submitReturnRequest = async (payload: ReturnRequestPayload) => {
    const res = await authApi.post(
        "/booking/wp/return/file-request/",
        payload
    );
    return res.data;
};
```

---

## Return Request Detail Page

**URL**: `https://demo.bideshgami.com/dashboard/agency/booking-file/return/request/{id}`  
**Component**: `features/dashboard/agency/booking/return/DashboardAgencyReturnRequestAdd.tsx`  
**Page Route**: `app/dashboard/agency/booking-file/return/request/[id]/page.tsx`

### Features
- Displays booking details with return file information
- Shows payment breakdown (Agency Payment Steps, Agency Paid Steps, Paid Steps)
- Form to submit/edit return request with:
  - Package Price (read-only)
  - Paid Amount (read-only)
  - Expense Amount (Cost) - editable
  - Auto-calculated net request amount
  - Total Costing in Details - textarea
  - Reason of File Reject - textarea (read-only if already set)

### Form Submission
**Endpoint**: `/booking/wp/return/file-request/`  
**Method**: `POST`

#### Form Payload
```typescript
interface ReturnFormValues {
    costAmount: string;      // Expense/cost amount
    requestAmount: string;   // Request amount
    costDetails: string;     // Details of costing
    reason: string;          // Reason for rejection
}
```

#### Computed Values
The form auto-calculates:
- **Net Request Amount** = `costAmount - agencyPaidAmount`
- **Agency Must Return** flag based on whether net amount is negative

---

## Notes
- All API calls use the authenticated axios instance (`authApi`)
- Search is performed by passport number
- Pagination is required (specify `page` parameter)
- Request status can be filtered by `requestedByType` (CUSTOMER or AGENCY)
- Return requests can be approved/rejected through separate endpoints
- Detail page shows comprehensive payment history (agency payment steps, agency paid steps, paid steps)
- The "Reason of File Reject" field is read-only if already set from the booking

---

# API Documentation: Return PP Sent to BG
**URL**: `https://demo.bideshgami.com/dashboard/agency/booking-file/return-pp-sent-to-bg`

---

## Overview
This page displays and manages passports that have been returned to Bangladesh (return status). It shows bookings with `RETURN_PP_SENT_TO_BG` status and allows agencies to track return passport shipments.

---

## API Endpoints

### 1. Get Return PP Sent to BG List
**Endpoint**: `/booking/wp/`  
**Method**: `GET`  
**Location**: `features/dashboard/admin/terminal/booking/api.ts`

#### Request Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `status` | string | Yes | Filter by status (must be `RETURN_PP_SENT_TO_BG`) |
| `search` | string | No | Search term (e.g., passport number) |
| `page` | number | Yes | Page number for pagination |
| `from_date` | string | No | Start date for filtering |
| `to_date` | string | No | End date for filtering |

#### Query String Example
```
/booking/wp/?status=RETURN_PP_SENT_TO_BG&search=&from_date=&to_date=&page=1
```

#### Response Structure
```typescript
interface TypesHandler<T> {
    count: number;        // Total number of records
    pageSize: number;     // Number of items per page
    results: T[];         // Array of booking items
}
```

#### Response Item Structure
Uses the same `WPBookingGETProps` interface as other booking list endpoints (see Return Request List section above).

#### Example Response
```json
{
    "count": 3,
    "pageSize": 10,
    "results": [
        {
            "id": 123,
            "workPermitSlug": "wp-2024-001",
            "workPermitId": "WP001",
            "name": "Ahmed Hassan",
            "phone": "+880123456789",
            "email": "ahmed@example.com",
            "passportNo": "AB123456",
            "fromCountry": "Bangladesh",
            "toCountry": "UAE",
            "status": "RETURN_PP_SENT_TO_BG",
            "statusLabel": "Return PP Sent to BG",
            "serviceType": "Work Permit",
            "branch": "Dhaka",
            "customerTotal": "50000",
            "agencyTotalCost": "45000",
            "paidAmount": 50000,
            "agencyName": "ABC Agency",
            "agencyPhone": "+880987654321",
            "createdAt": "2024-05-15T08:00:00Z",
            "appointmentDate": "2024-06-01T14:00:00Z"
        }
    ]
}
```

---

### 2. Get Booking Minimal Details
**Endpoint**: `/booking/wp/send-passport/{pk}/one/`  
**Method**: `GET`  
**Location**: `features/dashboard/admin/terminal/booking/api.ts`

#### Path Parameters
| Parameter | Type | Description |
|-----------|------|-------------|
| `pk` | number | Booking ID |

#### Response Structure
```typescript
interface WPBookingGETProps {
    id: number;
    workPermitSlug: string;
    workPermitId: string;
    name: string;
    phone: string;
    email: string;
    passportNo: string;
    fromCountry: string;
    toCountry: string;
    status: string;
    statusLabel: string;
    serviceType: string;
    branch: string;
    customerTotal: string;
    agencyTotalCost: string;
    paidAmount: number;
    // ... other booking properties
}
```

#### Usage
```typescript
const details = await getBookingOneMinimul(bookingId);
```

#### Example Response
```json
{
    "id": 123,
    "name": "Ahmed Hassan",
    "phone": "+880123456789",
    "email": "ahmed@example.com",
    "passportNo": "AB123456",
    "status": "RETURN_PP_SENT_TO_BG",
    "workPermitId": "WP001"
}
```

---

### 3. Search Bookings Send Passport
**Endpoint**: `/booking/wp/send-passport/list/`  
**Method**: `GET`  
**Location**: `features/dashboard/admin/terminal/booking/api.ts`

#### Request Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `work_permit_id` | string \| number | No | Filter by work permit ID |
| `search` | string | No | Search term (passport number, name, etc.) |

#### Query String Example
```
/booking/wp/send-passport/list/?work_permit_id=&search=AB123456
```

#### Response Structure
```typescript
interface TypesHandler<WPBookingGETProps> {
    count: number;
    pageSize: number;
    results: WPBookingGETProps[];
}
```

---

### 4. Submit/Save Passport Send to Agency
**Endpoint**: `/booking/wp/send-passport/list/`  
**Method**: `POST`  
**Location**: `features/dashboard/admin/terminal/booking/api.ts`

#### Request Payload Structure
```typescript
interface BookingItemProps {
    fullName: string;              // Full name of recipient/employee
    phone: string;                 // Phone number
    employeeId: string;            // Employee ID
    email: string;                 // Email address
    employeeOf: string;            // Organization/agency name
    bookingIds: number[];          // Array of booking IDs to process
}
```

#### Example Request Body
```json
{
    "fullName": "Ahmed Hassan",
    "phone": "+880123456789",
    "employeeId": "EMP001",
    "email": "ahmed@example.com",
    "employeeOf": "ABC Agency",
    "bookingIds": [123, 124, 125]
}
```

#### Response
```typescript
{ 
    "success": boolean 
}
```

---

## Frontend Components

### List View Component
- **File**: `features/dashboard/agency/booking/DashboardVerificationFilePageView.tsx`
- **Page**: `app/dashboard/agency/booking-file/[slug]/page.tsx` (with slug = `return-pp-sent-to-bg`)

### Add/Edit View Component
- **File**: `features/dashboard/agency/booking/pp/DashboardAgencyPPSentBGAdd.tsx`
- **Page**: `app/dashboard/agency/booking-file/pp-sent-bg/add/[id]/page.tsx`

### Features

#### List View
- Displays passports with `RETURN_PP_SENT_TO_BG` status
- Search functionality by passport number
- Pagination support
- Date range filtering (from_date, to_date)
- View documents action
- Status display

#### Add/Send View
- Pre-loads the initial booking details (locked/read-only)
- Allows selection of additional bookings to send together
- Form fields:
  - Full Name (recipient)
  - Phone
  - Employee ID
  - Email
  - Employee Of (organization name)
  - List of selected bookings
- Ability to remove selected bookings (except the first one)
- Submit to process multiple passport sends at once

---

## Data Types

### Booking Status
The `RETURN_PP_SENT_TO_BG` status indicates:
- Passport has been returned to Bangladesh
- Agency is tracking the return shipment
- No further action required on this status

### Work Permit Status Flow (Return Path)
```
RETURN_REQUEST 
  ↓
RETURN_ACCEPTED
  ↓
RETURN_PP_SENT_TO_BG ← Current page
  ↓
BG_COLLECT_RETURN_PP
  ↓
BG_HANDOVER_PP_TO_CUSTOMER
```

---

## Usage Pattern

### Fetching Return PP Sent to BG List
```typescript
// From the API file
export const fetchBookings = async (
    status: BookingStatus2 | "",
    debouncedSearch: string,
    currentPage: number,
    fromDate?: string,
    toDate?: string
) => {
    const res = await authApi.get(
        `/booking/wp/?status=${status}&search=${debouncedSearch}&from_date=${fromDate}&to_date=${toDate}&page=${currentPage}`
    );
    return res.data;
};

// Usage in component
const res = await fetchBookings("RETURN_PP_SENT_TO_BG", "AB123456", 1, "", "");
setData(res);
```

### Sending Passport to Agency
```typescript
// From the API file
export const searchBookingsSendPassportPost = async (
    formData: BookingItemProps
) => {
    const res = await authApi.post(`/booking/wp/send-passport/list/`, formData);
    return res.data;
};

// Usage in component
const payload = {
    fullName: "Ahmed Hassan",
    phone: "+880123456789",
    employeeId: "EMP001",
    email: "ahmed@example.com",
    employeeOf: "ABC Agency",
    bookingIds: [123, 124, 125],
};
await searchBookingsSendPassportPost(payload);
```

---

## Notes
- All API calls use the authenticated axios instance (`authApi`)
- The list view supports filtering by date range for better tracking of shipments
- Multiple bookings can be sent together in a single submission
- The first/initial booking ID cannot be removed from the selection
- Search returns only bookings eligible for sending (e.g., status-appropriate bookings)
- Return PP Sent to BG is a read-only status - no status transitions occur from this page

---

# API Documentation: BG Collect Return PP
**URL**: `https://demo.bideshgami.com/dashboard/agency/booking-file/bg-collect-return-pp`

---

## Overview
This page displays passports that have been collected in Bangladesh for return processing. It shows bookings with `BG_COLLECT_RETURN_PP` status, indicating that the Bangladesh office has received and is now holding the return passports for further processing.

---

## API Endpoints

### 1. Get BG Collect Return PP List
**Endpoint**: `/booking/wp/`  
**Method**: `GET`  
**Location**: `features/dashboard/admin/terminal/booking/api.ts`

#### Request Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `status` | string | Yes | Filter by status (must be `BG_COLLECT_RETURN_PP`) |
| `search` | string | No | Search term (e.g., passport number) |
| `page` | number | Yes | Page number for pagination |
| `from_date` | string | No | Start date for filtering |
| `to_date` | string | No | End date for filtering |

#### Query String Example
```
/booking/wp/?status=BG_COLLECT_RETURN_PP&search=&from_date=&to_date=&page=1
```

#### Response Structure
```typescript
interface TypesHandler<T> {
    count: number;        // Total number of records
    pageSize: number;     // Number of items per page
    results: T[];         // Array of booking items
}
```

#### Response Item Structure
Uses the same `WPBookingGETProps` interface as other booking list endpoints.

#### Example Response
```json
{
    "count": 5,
    "pageSize": 10,
    "results": [
        {
            "id": 123,
            "workPermitSlug": "wp-2024-001",
            "workPermitId": "WP001",
            "name": "Ahmed Hassan",
            "phone": "+880123456789",
            "email": "ahmed@example.com",
            "passportNo": "AB123456",
            "fromCountry": "Bangladesh",
            "toCountry": "UAE",
            "status": "BG_COLLECT_RETURN_PP",
            "statusLabel": "BG Collect Return PP",
            "serviceType": "Work Permit",
            "branch": "Dhaka",
            "customerTotal": "50000",
            "agencyTotalCost": "45000",
            "paidAmount": 50000,
            "agencyName": "ABC Agency",
            "agencyPhone": "+880987654321",
            "createdAt": "2024-06-20T10:30:00Z",
            "appointmentDate": "2024-06-01T14:00:00Z"
        }
    ]
}
```

---

## Frontend Components

### List View Component
- **File**: `features/dashboard/agency/booking/DashboardVerificationFilePageView.tsx`
- **Page**: `app/dashboard/agency/booking-file/[slug]/page.tsx` (with slug = `bg-collect-return-pp`)

### Features

#### List View (Agency)
- Displays passports with `BG_COLLECT_RETURN_PP` status
- Read-only view - no edit or status change actions available
- Search functionality by passport number
- Pagination support
- Date range filtering (from_date, to_date)
- View documents action for each booking

---

## Data Types

### Booking Status
The `BG_COLLECT_RETURN_PP` status indicates:
- Passport has been received and collected in Bangladesh
- Passports are being held/stored in BG office
- Awaiting next step in return process (handover to customer)
- Status is managed by BG office, not editable by agency

### Work Permit Status Flow (Return Path)
```
RETURN_REQUEST 
  ↓
RETURN_ACCEPTED
  ↓
RETURN_PP_SENT_TO_BG
  ↓
BG_COLLECT_RETURN_PP ← Current page (read-only for agency)
  ↓
BG_HANDOVER_PP_TO_CUSTOMER
```

---

## Usage Pattern

### Fetching BG Collect Return PP List
```typescript
// From the API file
export const fetchBookings = async (
    status: BookingStatus2 | "",
    debouncedSearch: string,
    currentPage: number,
    fromDate?: string,
    toDate?: string
) => {
    const res = await authApi.get(
        `/booking/wp/?status=${status}&search=${debouncedSearch}&from_date=${fromDate}&to_date=${toDate}&page=${currentPage}`
    );
    return res.data;
};

// Usage in component
const res = await fetchBookings("BG_COLLECT_RETURN_PP", "AB123456", 1, "", "");
setData(res);
```

---

## Terminal (Admin) View - Status Transition

### Update Booking Status (Collect PP)
**Endpoint**: `/booking/wp/status/{pk}/set/`  
**Method**: `PATCH`  
**Location**: `features/dashboard/admin/terminal/booking/api.ts`

This endpoint is used by the Terminal admin to transition from `RETURN_PP_SENT_TO_BG` to `BG_COLLECT_RETURN_PP`.

#### Request Payload
```typescript
interface StatusUpdatePayload {
    status: "BG_COLLECT_RETURN_PP";
}
```

#### Handler in Terminal Config
```typescript
collectPP: (row) => handle(
    row,
    "BG_COLLECT_RETURN_PP",
    "Confirm passport collection for return?",
    `Passport ${row.passportNo} collected for return`
),
```

---

## Notes
- All API calls use the authenticated axios instance (`authApi`)
- This page is read-only for agencies - status transitions are managed only by the Terminal (BG office)
- The status is automatically set when the "Collect PP" action is performed by the Terminal admin
- Pagination is required (specify `page` parameter)
- Date range filtering is available for tracking shipment timelines
- View Documents action allows agencies to access uploaded documentation for these passports

---

# API Documentation: BG Handover PP to Customer
**URL**: `https://demo.bideshgami.com/dashboard/agency/booking-file/bg-handover-pp-to-customer`

---

## Overview
This page displays passports that have been handed over to customers in Bangladesh. It shows bookings with `BG_HANDOVER_PP_TO_CUSTOMER` status, indicating the final stage of the return process where passports are delivered to the customers.

---

## API Endpoints

### 1. Get BG Handover PP to Customer List
**Endpoint**: `/booking/wp/`  
**Method**: `GET`  
**Location**: `features/dashboard/admin/terminal/booking/api.ts`

#### Request Parameters
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `status` | string | Yes | Filter by status (must be `BG_HANDOVER_PP_TO_CUSTOMER`) |
| `search` | string | No | Search term (e.g., passport number) |
| `page` | number | Yes | Page number for pagination |
| `from_date` | string | No | Start date for filtering |
| `to_date` | string | No | End date for filtering |

#### Query String Example
```
/booking/wp/?status=BG_HANDOVER_PP_TO_CUSTOMER&search=&from_date=&to_date=&page=1
```

#### Response Structure
```typescript
interface TypesHandler<T> {
    count: number;        // Total number of records
    pageSize: number;     // Number of items per page
    results: T[];         // Array of booking items
}
```

#### Response Item Structure
Uses the same `WPBookingGETProps` interface as other booking list endpoints.

#### Example Response
```json
{
    "count": 8,
    "pageSize": 10,
    "results": [
        {
            "id": 123,
            "workPermitSlug": "wp-2024-001",
            "workPermitId": "WP001",
            "name": "Ahmed Hassan",
            "phone": "+880123456789",
            "email": "ahmed@example.com",
            "passportNo": "AB123456",
            "fromCountry": "Bangladesh",
            "toCountry": "UAE",
            "status": "BG_HANDOVER_PP_TO_CUSTOMER",
            "statusLabel": "BG Handover PP to Customer",
            "serviceType": "Work Permit",
            "branch": "Dhaka",
            "customerTotal": "50000",
            "agencyTotalCost": "45000",
            "paidAmount": 50000,
            "agencyName": "ABC Agency",
            "agencyPhone": "+880987654321",
            "createdAt": "2024-06-20T10:30:00Z",
            "appointmentDate": "2024-06-01T14:00:00Z"
        }
    ]
}
```

---

## Frontend Components

### List View Component
- **File**: `features/dashboard/agency/booking/DashboardVerificationFilePageView.tsx`
- **Page**: `app/dashboard/agency/booking-file/[slug]/page.tsx` (with slug = `bg-handover-pp-to-customer`)

### Features

#### List View (Agency)
- Displays passports with `BG_HANDOVER_PP_TO_CUSTOMER` status
- Read-only view - no edit or status change actions available
- Search functionality by passport number
- Pagination support
- Date range filtering (from_date, to_date)
- View documents action for each booking
- View details action for each booking

---

## Data Types

### Booking Status
The `BG_HANDOVER_PP_TO_CUSTOMER` status indicates:
- Passport has been handed over to the customer in Bangladesh
- Final stage of the return process
- Return process is complete
- Status is managed by BG office, not editable by agency

### Work Permit Status Flow (Return Path - Final Stage)
```
RETURN_REQUEST 
  ↓
RETURN_ACCEPTED
  ↓
RETURN_PP_SENT_TO_BG
  ↓
BG_COLLECT_RETURN_PP
  ↓
BG_HANDOVER_PP_TO_CUSTOMER ← Final status (read-only for agency)
  ✓ Return process complete
```

---

## Usage Pattern

### Fetching BG Handover PP to Customer List
```typescript
// From the API file
export const fetchBookings = async (
    status: BookingStatus2 | "",
    debouncedSearch: string,
    currentPage: number,
    fromDate?: string,
    toDate?: string
) => {
    const res = await authApi.get(
        `/booking/wp/?status=${status}&search=${debouncedSearch}&from_date=${fromDate}&to_date=${toDate}&page=${currentPage}`
    );
    return res.data;
};

// Usage in component
const res = await fetchBookings("BG_HANDOVER_PP_TO_CUSTOMER", "AB123456", 1, "", "");
setData(res);
```

---

## Terminal (Admin) View - Status Transition

### Update Booking Status (Handover to Customer)
**Endpoint**: `/booking/wp/status/{pk}/set/`  
**Method**: `PATCH`  
**Location**: `features/dashboard/admin/terminal/booking/api.ts`

This endpoint is used by the Terminal admin to transition from `BG_COLLECT_RETURN_PP` to `BG_HANDOVER_PP_TO_CUSTOMER`.

#### Request Payload
```typescript
interface StatusUpdatePayload {
    status: "BG_HANDOVER_PP_TO_CUSTOMER";
}
```

#### Handler in Terminal Config
```typescript
handoverToCustomer: (row) => handle(
    row,
    "BG_HANDOVER_PP_TO_CUSTOMER",
    "Confirm handover of passport to customer?",
    `Passport ${row.passportNo} handed over to customer`
),
```

---

## Notes
- All API calls use the authenticated axios instance (`authApi`)
- This page is read-only for agencies - status transitions are managed only by the Terminal (BG office)
- This is the final status in the return process lifecycle
- The status is automatically set when the "PP Handover to Customer" action is performed by the Terminal admin
- Pagination is required (specify `page` parameter)
- Date range filtering is available for tracking completion timelines
- View Documents action allows agencies to access uploaded documentation for these passports
- View Details action provides comprehensive booking and return information
