# Appointment QR Code Details

This document explains how the appointment QR code is handled in the frontend codebase.

## 1. Where the QR code is loaded

The appointment ticket page at:

- `app/dashboard/(common-route)/booking/appointment/[id]/page.tsx`

fetches ticket data from the backend API endpoint:

- `GET /booking/wp/appointment/${id}/ticket/`

That API response is stored in the frontend state and passed directly into the ticket component.

## 2. Data model for ticket response

The response is typed as `WPBTicketGETProps` in:

- `types/workPermit/booking/wpbooking.types.ts`

The relevant shape is:

```ts
export interface WPBTicketGETProps {
    id: number;
    name: string;
    passportNo: string;
    toCountry: string;
    appointmentDate: string;
    qr: string;
}
```

The `qr` property is a string, typically an image URL or a data URL, provided by the backend.

## 3. Frontend QR rendering

The QR code is displayed in:

- `components/dashboard/common/booking/appointment/AppointmentBookingTicket.tsx`

Using Next.js `Image`:

```tsx
<Image src={qr} alt="" width={100} height={100} className="w-full aspect-square" unoptimized />
```

This means the frontend does not generate the QR code itself. It only renders the image received from the backend.

## 4. PDF download behavior

The same component also supports downloading the appointment ticket as a PDF.

- The ticket DOM is cloned
- responsive classes are adjusted for desktop layout
- `html2canvas` renders the cloned ticket
- `jsPDF` embeds the rendered image into a PDF

The cloned ticket includes the same QR image rendered from `qr`, so the QR appears in the downloaded PDF as well.

## 5. Other QR usages in the project

There are other QR fields used in the admin terminal sticker flow:

- `features/dashboard/admin/terminal/booking/pages/details/modal/StickerModal.tsx`

This modal renders QR images from:

- `data.qrAgency`
- `data.qrCustomer`
- `data.qrBookedBy`

Those are also treated as image source strings and displayed with plain `<img>` tags.

## 6. Important takeaway

- The appointment booking QR code is provided by backend data.
- The frontend receives it as the `qr` field and renders it.
- The frontend does not generate the QR payload or encode the data itself.

## 7. Notes on older code

There is an older ticket component:

- `components/dashboard/common/booking/appointment/AppointmentBookingTicketOld.tsx`

It contains a placeholder QR image reference (`/pdf/qr.png`), but that component is not used for the current appointment booking QR flow.

## 8. If you need the backend source

The actual QR generation logic is not in this frontend repository. To see the generation mechanism, inspect the backend API implementation for:

- `/booking/wp/appointment/{id}/ticket/`

That endpoint is the source of truth for the QR image.
