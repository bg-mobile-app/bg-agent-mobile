# Change Password API Documentation

This document outlines the API endpoints and data structures used for the "Change Password" feature in the Bideshgami frontend application.

## Change Password API

This API is used to change a user's account password.

*   **API URL:** `${process.env.NEXT_PUBLIC_API_URL}/auth/change-password/`
*   **HTTP Method:** `POST`
*   **Authentication:** Required. The request is sent with credentials (e.g., an httpOnly cookie with a JWT token).

### Request Body

The request body should be a JSON object containing the old password and the new password.

```json
{
  "old_password": "currentPassword123",
  "new_password": "newPassword456",
  "confirm_password": "newPassword456"
}
```

### Request Body Field Descriptions

*   `old_password` (string): The user's current password. Required for authentication and verification.
*   `new_password` (string): The new password the user wants to set. Must be at least 8 characters long.
*   `confirm_password` (string): Confirmation of the new password. Must match `new_password` exactly.

### Client-Side Validation Rules

*   All fields are required (old_password, new_password, confirm_password).
*   `new_password` and `confirm_password` must match exactly.
*   `new_password` must be at least 8 characters long.

### API Response

The API returns a success response upon successful password change. A successful `2xx` status code indicates that the operation was successful. On error, the API returns error messages indicating what validation failed (e.g., incorrect old password, password requirements not met, etc.).

### Example Request

```javascript
POST ${process.env.NEXT_PUBLIC_API_URL}/auth/change-password/

{
  "old_password": "oldPassword123",
  "new_password": "newSecurePassword",
  "confirm_password": "newSecurePassword"
}
```

### Success Response

A successful response returns a `2xx` status code, indicating the password has been changed. The user can then use their new password for future authentication.

### Error Response Examples

- **400 Bad Request**: When validation fails (e.g., passwords don't match, new password too short)
- **401 Unauthorized**: When the old password is incorrect
- **401 Unauthenticated**: When the user is not authenticated
