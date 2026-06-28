# Work Permit Details API Response

**Endpoint:** `GET /work-permits/{slug}/`

This is the expected JSON response structure for a work permit details page such as:
`https://demo.bideshgami.com/work-permit/সৌদি-আরবের-নিয়োগ-বিবরণী-saudi-arabia`

```json
{
  "id": 123,
  "slug": "saudi-arabia",
  "title": "সৌদি আরবের নিয়োগ বিবরণী",
  "country": "Saudi Arabia",
  "companyName": "ABC Recruitment Agency",
  "companyAddress": "Riyadh, Saudi Arabia",
  "visaSponsorName": "Saudi Sponsor Co",
  "selectionType": "DELEGATE",
  "visaOccupation": "Housemaid",
  "salary": 25000,
  "currency": "BDT",
  "currencyFlag": "৳",
  "minAge": 18,
  "maxAge": 35,
  "iqama": "COMPANY",
  "food": "COMPANY",
  "accommodation": "COMPANY",
  "workingHours": "8 hours/day",
  "quota": 100,
  "contractDuration": "2_YEARS",
  "isRenewable": true,
  "gender": "Female",
  "documentsRequired": [
    "Passport",
    "Photo",
    "Medical Fit Certificate",
    "Experience Certificate"
  ],
  "packageIncludes": [
    "Visa",
    "Ticket",
    "Manpower",
    "Medical",
    "Takamul Certificate"
  ],
  "experienceRequired": "1 year",
  "processingTime": "30 days",
  "applicationDeadline": "2025-12-31",
  "startDate": "2026-01-15",
  "endDate": "2028-01-14",
  "packagePrice": 50000,
  "customerPercentage": 60,
  "agentPercentage": 40,
  "paymentSystem": "ADVANCE_AFTER_VISA_BEFORE_FLIGHT",
  "paymentSteps": [
    { "step": "ADVANCE", "amount": 15000, "sequence": 1 },
    { "step": "AFTER_VISA", "amount": 20000, "sequence": 2 },
    { "step": "BEFORE_FLIGHT", "amount": 15000, "sequence": 3 }
  ],
  "isBn": true,
  "description": "সৌদি আরবে হাউমেড চাকরির সুযোগ। আবেদন করার জন্য বিস্তারিত তথ্য দেখুন।",
  "advancePrice": 15000,
  "afterVisa": 20000,
  "beforeFlight": 15000,
  "status": "ACTIVE",
  "customerPrice": 50000,
  "agentPrice": 30000,
  "countryName": "Saudi Arabia",
  "image": "https://demo.bideshgami.com/media/work-permit/saudi-arabia.jpg",
  "agency": {
    "id": 11,
    "agencyName": "Bideshgami Agency",
    "agencyPhone": "+8801712345678",
    "status": "VERIFIED",
    "documents": [
      { "image": "https://demo.bideshgami.com/media/agency/doc-1.jpg", "rlNo": 12345 }
    ]
  },
  "workType": { "id": 2, "name": "Housemaid" },
  "favoriteCount": 45,
  "bookedQuota": 20,
  "availableQuota": 80,
  "createdAt": "2025-07-01T10:00:00Z",
  "updatedAt": "2025-07-10T08:30:00Z"
}
```

## Response field notes

- `slug`: URL-friendly slug used in the route.
- `countryName`: shown in the page metadata and search filters.
- `agency`: nested agency profile for the publisher of the work permit.
- `workType`: numeric ID plus name for the type of work permit.
- `paymentSteps`: payment schedule for the work permit.
- `isBn`: true when the content is in Bangla.
- `favoriteCount`, `bookedQuota`, and `availableQuota` are frontend counters.
- `createdAt` / `updatedAt`: timestamps for the work permit record.
