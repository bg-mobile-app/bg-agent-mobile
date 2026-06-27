# Edit Customer Profile

This document outlines the specifications for the "Edit Customer Profile" feature.

## API URL

The endpoint for updating a customer's profile should be a `PUT` or `PATCH` request to:

`/api/v1/customer/profile`

## API Request

The request body should contain the fields that the user can update.

### Request Body Example (JSON)

```json
{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@example.com",
  "phoneNumber": "+1234567890",
  "address": {
    "street": "123 Main St",
    "city": "Anytown",
    "state": "CA",
    "zipCode": "12345",
    "country": "USA"
  }
}
```

### API Response

#### Success (200 OK)

The API should respond with the updated customer profile object.

```json
{
  "id": "customer-id-123",
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@example.com",
  "phoneNumber": "+1234567890",
  "address": {
    "street": "123 Main St",
    "city": "Anytown",
    "state": "CA",
    "zipCode": "12345",
    "country": "USA"
  },
  "updatedAt": "2026-06-27T10:00:00Z"
}
```

#### Error (4xx/5xx)

- **400 Bad Request**: If the request body is invalid (e.g., missing required fields, invalid email format).
- **401 Unauthorized**: If the user is not authenticated.
- **404 Not Found**: If the customer profile does not exist.
- **500 Internal Server Error**: For any server-side errors.

## Frontend Design

The frontend should consist of a form that allows the user to edit their profile information.

### Components

1.  **Profile Form**:
    -   Input field for `First Name`.
    -   Input field for `Last Name`.
    -   Input field for `Email` (potentially read-only if not editable).
    -   Input field for `Phone Number`.
    -   Input fields for `Address` (Street, City, State, ZIP Code, Country).
    -   A "Save Changes" button.
    -   A "Cancel" button to discard changes.

2.  **User Experience**:
    -   The form should be pre-filled with the user's current profile data.
    -   The "Save Changes" button should be disabled until the user makes a change.
    -   Display a success message or notification after the profile is updated successfully.
    -   Display clear error messages for any validation failures or API errors.
    -   Consider adding a loading indicator while the form is submitting.