# Agent Profile Screen Documentation

## URL
- https://demo.bideshgami.com/dashboard/agent/profile

## Frontend Design
This screen shows the logged-in agent's profile information in a read-only layout.

### Page Component
- Frontend page: app/dashboard/agent/profile/page.tsx
- Main UI component: features/dashboard/agent/profile/DashboardAgentProfile.tsx

### UI Structure
The screen contains:
- A profile image at the top
- A section titled "Personal Details"
- A section titled "Basic Info"
- A section titled "Contact Info"
- An image gallery area with:
  - NID Image
  - Trade License Image

### Displayed Fields
#### Basic Info
- Status
- Agent ID
- Name
- Gender
- Date of Birth
- Agency Name
- Agency Address

#### Contact Info
- Email Address
- Phone Number
- Address
- Police Station
- District

### Design Style
- White card layout with rounded corners
- Soft shadow styling
- Large profile image with circular shape
- Each field is displayed in a bordered row layout
- Responsive spacing for mobile and desktop

### Behavior
- On load, the component fetches the agent profile data
- If loading, it shows "Loading profile..."
- If there is no data, it shows "No data"
- If the request fails, it shows an error toast

---

## API Request
### Endpoint
- GET `/profile/agents/me/`

### Frontend API Function
- Source: features/dashboard/agent/profile/profile.apiHandler.ts
- Function: getAgentProfile()

### Request Details
- Method: GET
- Authentication: required via `authApi`
- No query parameters are required

### Example Request
```http
GET /profile/agents/me/
```

---

## API Response
### Response Shape
The frontend expects an object matching the following structure:

```ts
interface AgentDetailsProps {
  id: number;
  agencyName: string;
  image: string;
  user: {
    fullName: string;
    email: string;
    phone: string;
    status: string;
    userCode: string;
  };
  dob: string;
  gender: string;
  agencyAddress: string;
  address: string;
  policeStation: string;
  district: string;
  nidImage: string;
  tradeLicenseImage: string;
  createdAt: string;
  updatedAt: string;
}
```

### Example API Response
```json
{
  "id": 12,
  "agencyName": "ABC Recruitment Agency",
  "image": "https://example.com/agent.jpg",
  "user": {
    "fullName": "John Doe",
    "email": "john@example.com",
    "phone": "+880123456789",
    "status": "ACTIVE",
    "userCode": "AGT-001"
  },
  "dob": "1990-01-15",
  "gender": "MALE",
  "agencyAddress": "House 1, Road 2, Dhaka",
  "address": "Mirpur, Dhaka",
  "policeStation": "Mirpur Model Police Station",
  "district": "Dhaka",
  "nidImage": "https://example.com/nid.jpg",
  "tradeLicenseImage": "https://example.com/trade-license.jpg",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-06-01T00:00:00Z"
}
```

### How the Response Is Used
The API response is displayed directly in the UI:
- `data.user.fullName` -> Name
- `data.user.email` -> Email Address
- `data.user.phone` -> Phone Number
- `data.user.status` -> Status badge
- `data.user.userCode` -> Agent ID
- `data.gender` -> Gender
- `data.dob` -> Date of Birth
- `data.agencyName` -> Agency Name
- `data.agencyAddress` -> Agency Address
- `data.address` -> Address
- `data.policeStation` -> Police Station
- `data.district` -> District
- `data.nidImage` -> NID Image preview
- `data.tradeLicenseImage` -> Trade License Image preview

---

## Frontend Flow
1. The page loads the profile screen
2. The component calls `getAgentProfile()`
3. The data is fetched using React Query
4. The profile UI is rendered with the returned values

---

## Notes
- This is a read-only profile screen.
- It uses the authenticated agent profile API.
- The screen is specific to the agent role and uses the agent-specific endpoint `/profile/agents/me/`.
