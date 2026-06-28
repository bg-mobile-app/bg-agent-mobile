# Favourite Feature API Documentation

This document outlines the API endpoints and data structures used for the "Favourite" feature in the Bideshgami frontend application.

## Get Favourites API

This API is used to retrieve the list of a user's favourite work permits.

*   **API URL:** `${process.env.NEXT_PUBLIC_API_URL}/profile/favorite/`
*   **HTTP Method:** `GET`
*   **Authentication:** Required. The request is sent with credentials (e.g., an httpOnly cookie with a JWT token).

### API Response

The API returns a JSON array of "favourite" objects. Each object in the array has the following structure:

```json
[
  {
    "id": 123,
    "workPermit": {
      "id": 456,
      "title": "Software Engineer",
      "slug": "software-engineer-canada",
      "company_name": "Tech Solutions Inc.",
      "country": {
        "name": "Canada",
        "flag": "https://example.com/flags/ca.png"
      },
      "job_category": {
        "name": "Information Technology"
      },
      "views": 1500,
      "created_at": "2023-10-27T10:00:00Z"
    },
    "createdAt": "2023-10-28T12:30:00Z"
  }
]
```

### Response Field Descriptions

*   `id` (number): The unique identifier for the favourite entry.
*   `workPermit` (object): Contains the details of the favourited work permit.
    *   `id` (number): The unique identifier for the work permit.
    *   `title` (string): The title of the work permit/job.
    *   `slug` (string): A URL-friendly slug for the work permit.
    *   `company_name` (string): The name of the company offering the work permit.
    *   `country` (object): Information about the country.
        *   `name` (string): The name of the country.
        *   `flag` (string): A URL to an image of the country's flag.
    *   `job_category` (object): Information about the job category.
        *   `name` (string): The name of the job category.
    *   `views` (number): The number of times the work permit has been viewed.
    *   `created_at` (string): The date and time the work permit was created, in ISO 8601 format.
*   `createdAt` (string): The date and time the work permit was added to the user's favourites, in ISO 8601 format.

---

## Add Favourite API

This API is used to add a work permit to a user's list of favourites.

*   **API URL:** `${process.env.NEXT_PUBLIC_API_URL}/profile/favorite/`
*   **HTTP Method:** `POST`
*   **Authentication:** Required. The request is sent with credentials (e.g., an httpOnly cookie with a JWT token).

### Request Body

The request body should be a JSON object containing the ID of the work permit to be favourited.

```json
{
  "work_permit": 123
}
```

### Request Body Field Descriptions

*   `work_permit` (number): The unique identifier of the work permit to be added to the favourites.

### API Response

The API returns a success message upon successful addition of the favourite. The exact response may vary, but a successful `2xx` status code indicates that the operation was successful.