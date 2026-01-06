# CLAUDE.md

This file provides project-specific context and guidelines for Claude Code (claude.ai/code) to ensure high-quality code generation and consistent behavior within the moit repository.

## Communication Preference

**Language**: Always communicate with the user in Korean (한국어).

**Technical Content**: Use English for code, comments, documentation, and technical terms unless otherwise requested.

## Project Overview

moit is a Flutter-based social scheduling and voting application. It allows users to create meeting rooms, invite friends via links, and vote on dates and times to finalize appointments.

### Development Context

**Role**: Frontend development using Flutter.

**Backend Integration**: The backend team provides REST APIs documented in Swagger. Frontend development focuses on integrating these pre-built APIs into the Flutter application.

**API Documentation**: Swagger specifications serve as the source of truth for API contracts, request/response structures, and endpoint behaviors.

## Architecture Overview

### High-Level Structure

```
UI Layer (Screens/Widgets)
        ↓
State Management (Provider/Riverpod Notifiers)
        ↓
Domain Layer (Models/Entities)
        ↓
Service Layer (MeetingClient/AuthClient)
        ↓
Network Layer (Dio with Interceptors)
        ↓
Backend REST API (https://moit.shop/api)
```

### Core Components

**Network Layer** (`lib/core/network/`):
- `DioClient`: Centralized HTTP client with LoggingInterceptor and AuthInterceptor.
- `AuthInterceptor`: Automatically injects Bearer tokens into headers.

**State Management**:
- `MeetingProvider`: Manages meeting creation, fetching, and voting states.
- `HomeProvider`: Handles dynamic dashboard messages based on meeting status.
- `Authentication`: Integrated with Kakao and Naver login providers.

## Key Development Patterns & Constraints

### 1. Robust API Response Parsing

The backend response follows the structure: `{ "code": "SUCCESS", "message": "...", "data": ... }`.

**ID Extraction**: When creating a meeting, the ID might be located directly in `data` or as `{ "meetingId": 123 }`. Always implement defensive parsing (checking for both `id` and `meetingId`).

**Fallback Mechanism**: If a creation response lacks an ID, fetch the full meeting list and identify the latest entry as a fallback.

### 2. Role-Based Access Control (RBAC)

- **Host** (`isHost: true`): Can confirm dates/times and modify meeting settings.
- **Member** (`isHost: false`): Can only vote and view results.

**UI Differentiation**: Use `isHost` to toggle visibility of "Confirm" (확정하기) vs "Vote" (투표하기) buttons.

### 3. Home Dashboard Message Priority

Display messages based on the following hierarchy:

1. **Priority 1 (Today)**: Confirmed meeting today → "오늘은 모임이 있어요"
2. **Priority 2 (Voting)**: Active voting in progress → "[Meeting Name]에 대해 친구들이 이야기하고 있어요"
3. **Priority 3 (Upcoming)**: Confirmed meeting within 7 days → "곧 모임이 있어요"
4. **Priority 4 (Default)**: No active status → "모임을 만들어볼까요?"

### 4. Meeting Detail Flow

- **Date Voting**: Managed in `MeetingDetailScreen`.
- **Time Voting**: Initiated after a date is confirmed. Supports 30-minute interval selection.
- **Real-time Member List**: The "People who can meet" (만날 수 있는 사람) section must update dynamically based on the selected date/time chip.

## Coding Standards

**SVG Assets**: Use `flutter_svg` for icons in `/assets/icons/` (e.g., `Layer_1.svg`).

**Naming**:
- Screens: `*Screen` or `*Page`
- Models: `*Request`, `*Response`, or `*Model`

**Logging**: Always include verbose print statements for API requests and raw response data to facilitate debugging.

## Common Troubleshooting

**Refreshes**: Trigger `loadMeetings()` immediately after any POST/PATCH action (vote, create, confirm) to ensure state synchronization.

**Status Codes**: Handle 200 OK responses with empty or unexpected data payloads gracefully without crashing the app.
