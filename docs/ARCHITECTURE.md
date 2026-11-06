# Architecture

## Platform

Native iOS application.

## Stack

- Swift
- SwiftUI
- SwiftData
- App Intents
- XCTest or Swift Testing

## Data Model

Transaction:
- id: UUID
- date: Date
- merchant: String
- amount: Decimal-compatible money representation
- category: String or typed category
- spendingType: Planned / Impulse
- notes: String?

## Storage

Local-first using SwiftData.

No remote backend required for MVP.

## App Structure

Proposed feature organization:

- App
- Models
- Features/Dashboard
- Features/QuickEntry
- Features/Transactions
- Features/Reflection
- Services
- AppIntents

Finalize the structure when creating the
Xcode project.

## Important Decisions

- Use precise monetary arithmetic.
- Keep calculations independent of UI.
- Use calendar-aware date boundaries.
- Avoid duplicate transaction creation.
- Preserve data across app restarts.
- Support CSV export.
- Keep architecture simple.

## Testing

Test:
- Transaction persistence
- Daily and weekly totals
- Month boundaries
- Category aggregation
- Planned/impulse calculations
- Editing and deletion
- App Intent navigation
