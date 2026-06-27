# Work Permit Details

This document explains the work permit detail page for URLs like:

- `https://demo.bideshgami.com/work-permit/<slug>`

Example slug in the current request:

- `সৌদি-ভিসা-ড্রাইভার-নিয়োগ-saudi-arabia`

## Frontend route

- `app/(main)/work-permit/[slug]/page.tsx`

This is a Next.js server component that:

1. reads `slug` from the route params
2. calls `getWorkPermitBySlug(slug)`
3. renders `<WorkPermitDetails data={data} />`

## API request

The work permit detail page uses:

- `features/main/workpermit/api.ts`
- function: `getWorkPermitBySlug(slug)`
- request method: `GET`
- endpoint: `/work-permits/${slug}/`
- full request URL: `${process.env.NEXT_PUBLIC_API_URL}/work-permits/${slug}/`

It uses the native `fetch` API configured as:

```ts
const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL}/work-permits/${slug}/`, {
    next: { revalidate: 30 }
});
```

If the fetch response is not ok, it throws an error:

```ts
if (!res.ok) {
    throw new Error('Work permit not found');
}
```

## Rendered component

The response is passed into:

- `features/main/workpermit/details/WorkPermitDetails.tsx`
- which renders `WorkPermitDetailsDataSection`

## API response type

The response is expected to match `WorkPermitAdsGETProps` from:

- `types/workPermit/workPermit.types.ts`

### `WorkPermitAdsGETProps` fields

From `WorkPermitAdsGETProps` and its parent `WorkPermitAdsProps`, the API response includes:

- `id: number`
- `slug: string`
- `status: string`
- `countryName: string`
- `image: string`
- `favoriteCount: number`
- `bookedQuota?: number`
- `availableQuota?: number`
- `createdAt: string`
- `updatedAt: string`
- `agency: AgencyProps`
- `workType: { id: number; name: string; }`

From `WorkPermitAdsProps`:

- `title: string`
- `country: string`
- `companyName: string`
- `companyAddress: string`
- `visaSponsorName: string`
- `selectionType: string`
- `visaOccupation: string`
- `salary: number`
- `currency: string`
- `currencyFlag: string`
- `minAge: number`
- `maxAge: number`
- `iqama: string`
- `food: string`
- `accommodation: string`
- `workingHours: string`
- `quota: number`
- `contractDuration: string`
- `isRenewable?: boolean`
- `gender: string`
- `documentsRequired: string[]`
- `packageIncludes: string[]`
- `experienceRequired?: string`
- `processingTime: string`
- `applicationDeadline: string`
- `startDate: string`
- `endDate?: string`
- `packagePrice: number`
- `customerPercentage: number`
- `agentPercentage: number`
- `paymentSystem: string`
- `paymentSteps: { step: string; amount: number; sequence: number; }[]`
- `isBn: boolean`
- `description: string`
- `advancePrice?: number`
- `afterVisa: number`
- `beforeFlight: number`

### `AgencyProps` fields

- `id: number`
- `agencyName: string`
- `agencyPhone: string`
- `status: string`
- `documents: { image: string; rlNo: number }[]`

## Fields used in the page UI

The details component displays the following response fields:

- `title`
- `createdAt`
- `id`
- `image`
- `bookedQuota`
- `favoriteCount`
- `isBn`
- `agency.status`
- `slug`
- `countryName`
- `workType.name`
- `visaOccupation`
- `companyName`
- `companyAddress`
- `visaSponsorName`
- `salary`
- `currencyFlag`
- `availableQuota`
- `workingHours`
- `minAge`
- `maxAge`
- `accommodation`
- `food`
- `iqama`
- `experienceRequired`
- `gender`
- `packageIncludes`
- `documentsRequired`
- `contractDuration`
- `isRenewable`
- `paymentSteps`
- `processingTime`
- `applicationDeadline`
- `selectionType`
- `startDate`
- `endDate`
- `description`
- `packagePrice`
- `customerPercentage`
- `agentPercentage`

## Notes

- The details page is server-side rendered and uses live fetch with 30 seconds revalidation.
- The query does not use the frontend Axios `authApi`; it uses the public `fetch` API.
- The actual JSON response should include all of the fields listed above according to the response type.
