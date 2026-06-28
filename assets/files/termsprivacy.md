# Terms & Privacy Pages - Frontend Design & API Documentation

## Overview

The Terms, Privacy Policy, Refund Policy, and About Us pages are all served through a **dynamic routing system** that fetches content from a backend CMS-style API.

### URLs

- **Terms & Conditions**: `https://demo.bideshgami.com/terms/TERMS`
- **Privacy Policy**: `https://demo.bideshgami.com/terms/PRIVACY`
- **Refund Policy**: `https://demo.bideshgami.com/terms/REFUND`
- **About Us**: `https://demo.bideshgami.com/terms/ABOUT_US`

---

## Frontend Route Structure

### Route File
**Path**: `app/(main)/terms/[slug]/page.tsx`

```typescript
import TermsPage from '@/features/main/terms/TermsPage';
import { ParamsSlugProps } from '@/types/custom/parameter'

const TermsPagePage = async ({ params }: ParamsSlugProps) => {
    const { slug } = await params;
    return <TermsPage slug={slug} />
}

export default TermsPagePage
```

### Component File
**Path**: `features/main/terms/TermsPage.tsx`

**Features**:
- Bilingual support (English & Bengali)
- Language toggle radio buttons
- HTML content rendering using `dangerouslySetInnerHTML`
- Loading state handling

```typescript
'use client';

import { useEffect, useState } from "react";
import { getPolicyByType, PolicyProps } from "./policy";
import { timeAgo } from "@/utils/time/formatDateTime";

const TermsPage = ({ slug }: { slug: string }) => {
    const [policy, setPolicy] = useState<PolicyProps | null>(null);
    const [isEn, setIsEn] = useState(true);

    useEffect(() => {
        if (!slug) return;
        getPolicyByType(slug).then(setPolicy);
    }, [slug]);

    if (!policy) return <div>Loading...</div>;

    return (
        <div className="container mx-auto px-4 py-8 max-w-4xl">
            {/* Language Toggle */}
            <div className="flex items-center gap-3 mb-6">
                <label className="flex items-center gap-1.5 cursor-pointer">
                    <input
                        type="radio"
                        name="language"
                        checked={isEn}
                        onChange={() => setIsEn(true)}
                        className="accent-blue-600"
                    />
                    <span className="text-sm font-medium">English</span>
                </label>
                <label className="flex items-center gap-1.5 cursor-pointer">
                    <input
                        type="radio"
                        name="language"
                        checked={!isEn}
                        onChange={() => setIsEn(false)}
                        className="accent-blue-600"
                        disabled={!policy.titleBn && !policy.contentBn}
                    />
                    <span className={`text-sm font-medium ${!policy.titleBn && !policy.contentBn ? 'text-gray-400' : ''}`}>
                        বাংলা
                    </span>
                </label>
            </div>

            <h1 className="text-2xl font-bold mb-2">
                {!isEn && policy.titleBn ? policy.titleBn : policy.title}
            </h1>
            <div
                className="prose max-w-none"
                dangerouslySetInnerHTML={{
                    __html: !isEn && policy.contentBn ? policy.contentBn : policy.content
                }}
            />
        </div>
    );
};

export default TermsPage;
```

---

## Frontend Design

### Layout
- **Container**: `max-w-4xl` centered with padding
- **Title**: 2xl font-bold
- **Language Toggle**: Top of page with radio buttons for English/বাংলা
- **Content**: Prose styling with HTML rendering

### Language Toggle Feature
```
┌─────────────────────────────────────┐
│  ◉ English    ○ বাংলা              │
└─────────────────────────────────────┘
```
- Default: English (isEn = true)
- Bengali toggle disabled if no Bengali content available
- Radio buttons styled with `accent-blue-600`

### Content Display
- Page uses `dangerouslySetInnerHTML` to render HTML content
- Prose styling applied for better text formatting
- Falls back to English if Bengali not available

---

## API Structure

### Endpoint
`GET /main/policies/by-type/?type={TYPE}`

### Request Parameters

| Parameter | Type   | Required | Options                                  |
|-----------|--------|----------|------------------------------------------|
| `type`    | string | Yes      | `TERMS`, `PRIVACY`, `REFUND`, `ABOUT_US` |

### Response Data Type

```typescript
interface PolicyProps {
    id: number;
    policyType: "TERMS" | "PRIVACY" | "REFUND" | "ABOUT_US";
    policyTypeDisplay: string;
    title: string;
    titleBn: string | null;
    content: string;
    contentBn: string | null;
    updatedAt: string;
    isActive: boolean;
}
```

### API Response Example

#### GET `/main/policies/by-type/?type=PRIVACY`

```json
{
  "id": 1,
  "policyType": "PRIVACY",
  "policyTypeDisplay": "Privacy Policy",
  "title": "Privacy Policy",
  "titleBn": "গোপনীয়তা নীতি",
  "content": "<h1>Privacy Policy</h1><p>Your privacy is important to us...</p><ul><li>We collect personal data</li><li>Your data is protected</li></ul>",
  "contentBn": "<h1>গোপনীয়তা নীতি</h1><p>আপনার গোপনীয়তা আমাদের কাছে গুরুত্বপূর্ণ...</p>",
  "updatedAt": "2025-07-10T08:30:00Z",
  "isActive": true
}
```

#### GET `/main/policies/by-type/?type=TERMS`

```json
{
  "id": 2,
  "policyType": "TERMS",
  "policyTypeDisplay": "Terms & Conditions",
  "title": "Terms & Conditions",
  "titleBn": "শর্তাবলী",
  "content": "<h1>Terms & Conditions</h1><p>These terms govern your use of our service...</p>",
  "contentBn": "<h1>শর্তাবলী</h1><p>এই শর্তাবলী আপনার সেবা ব্যবহার নিয়ন্ত্রণ করে...</p>",
  "updatedAt": "2025-07-05T10:15:00Z",
  "isActive": true
}
```

---

## API Functions (policy.ts)

### 1. Get Policy by Type
```typescript
export const getPolicyByType = async (type: string) => {
    const res = await api.get(`/main/policies/by-type/?type=${type}`);
    return res.data;
};
```
- Used by the TermsPage component
- Called with: `getPolicyByType("PRIVACY")`
- Returns: `PolicyProps`

### 2. Get All Policies
```typescript
export const getAllPolicies = async () => {
    const res = await api.get(`/main/policies/`);
    return res.data;
};
```

### 3. Get Single Policy
```typescript
export const getPolicy = async (id: number | undefined) => {
    const res = await api.get(`/main/policies/${id}/`);
    return res.data;
};
```

### 4. Create Policy (Admin)
```typescript
export const createPolicy = async (data: object) => {
    const res = await authApi.post(`/main/policies/`, data);
    return res.data;
};
```

### 5. Update Policy (Admin)
```typescript
export const putPolicy = async (id: number | undefined, data: object) => {
    const res = await authApi.patch(`/main/policies/${id}/`, data);
    return res.data;
};
```

---

## Footer Links

The Terms & Privacy pages are linked from the Footer component (`components/main/Footer.tsx`):

```typescript
<li><Link href="/terms/ABOUT_US">About Us</Link></li>
<li><Link href="/terms/MISSION">Mission</Link></li>
<li><Link href="/terms/VISION">Vision</Link></li>
<li><Link href="/terms/TERMS">Terms & Conditions</Link></li>
<li><Link href="/terms/PRIVACY">Privacy Policy</Link></li>
<li><Link href="/terms/REFUND">Refund Policy</Link></li>
```

---

## URL Path Mapping

| Slug | URL | Type | Page |
|------|-----|------|------|
| `TERMS` | `/terms/TERMS` | Terms & Conditions | Terms page |
| `PRIVACY` | `/terms/PRIVACY` | Privacy Policy | Privacy page |
| `REFUND` | `/terms/REFUND` | Refund Policy | Policy page |
| `ABOUT_US` | `/terms/ABOUT_US` | About Us | About page |

---

## User Flow

1. **User navigates** to `/terms/PRIVACY` or `/terms/TERMS`
2. **Route Component** extracts `slug` from URL params
3. **TermsPage Component** receives slug and calls `getPolicyByType(slug)`
4. **API Call** to `/main/policies/by-type/?type={slug}`
5. **Backend returns** Policy object with title, titleBn, content, contentBn
6. **Component renders**:
   - Language toggle buttons (English/বাংলা)
   - Title (in selected language)
   - HTML content (in selected language)
7. **User can toggle** between English and Bengali versions

---

## Key Features

✅ **Bilingual Support** - English and Bengali content with toggle  
✅ **HTML Content** - Rich text support with `dangerouslySetInnerHTML`  
✅ **Dynamic Routing** - Single component serves all policy pages  
✅ **Language Awareness** - Disables Bengali toggle if no content  
✅ **Responsive Design** - Centered container with max-width  
✅ **API Driven** - Content managed from backend CMS  
✅ **SEO Friendly** - Can be pre-rendered with metadata  
✅ **Loading State** - Handles async data fetching

---

## Styling Classes

- **Container**: `container mx-auto px-4 py-8 max-w-4xl`
- **Language Toggle**: `flex items-center gap-3 mb-6`
- **Radio Buttons**: `accent-blue-600`
- **Title**: `text-2xl font-bold mb-2`
- **Content**: `prose max-w-none`
- **Disabled Text**: `text-gray-400`

---

## Data Flow Diagram

```
User URL (/terms/PRIVACY)
    ↓
Route Component (page.tsx)
    ↓
TermsPage Component
    ↓
getPolicyByType("PRIVACY")
    ↓
API: /main/policies/by-type/?type=PRIVACY
    ↓
Backend Database
    ↓
PolicyProps Response
    ↓
Render with Language Toggle
    ↓
Display to User
```
