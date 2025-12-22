# EventBridge Event Publishing

This document describes the event publishing specification for AWS EventBridge.

## Overview

User-related events are published to AWS EventBridge when changes occur in the IDP system. Downstream consumers can subscribe to these events for data synchronization, notifications, analytics, and other purposes.

## Event Structure

### EventBridge Envelope

| Field | Description | Example |
|-------|-------------|---------|
| `source` | Event source identifier | `com.twogate.idp/{tenant_id}/users` |
| `detail-type` | Event type with version | `profile.changed.v1` |
| `detail` | Event payload (JSON) | See below |
| `event-bus-name` | Target event bus | Configured via `Settings.aws.event_bus_name` |

### Source Format

```
com.twogate.idp/{tenant_id}/users
```

- `com.twogate.idp` - Reverse domain notation (corporate domain + service name)
- `{tenant_id}` - Tenant identifier
- `users` - Resource collection (all user-related events share this source)

### Detail Type Format

```
{resource}.{action}.{version}
```

Examples:
- `user.signed_up.v1`
- `profile.changed.v1`
- `delivery_address.added.v1`

## Event Types

### User Events

| detail-type | Trigger |
|-------------|---------|
| `user.signed_up.v1` | User completed sign-up |
| `user.deleted.v1` | User account deleted |

### Profile Events

| detail-type | Trigger |
|-------------|---------|
| `profile.registered.v1` | Initial profile registration |
| `profile.changed.v1` | Profile information changed |

### Email Events

| detail-type | Trigger |
|-------------|---------|
| `email.changed.v1` | Email address changed |

### Contact Address Events

| detail-type | Trigger |
|-------------|---------|
| `contact_address.registered.v1` | Initial contact address registration |
| `contact_address.changed.v1` | Contact address changed |

### Delivery Address Events

| detail-type | Trigger |
|-------------|---------|
| `delivery_address.added.v1` | Delivery address added |
| `delivery_address.changed.v1` | Delivery address changed |
| `delivery_address.removed.v1` | Delivery address removed |

### Tag Events

| detail-type | Trigger |
|-------------|---------|
| `tag.added.v1` | Tag assigned |
| `tag.removed.v1` | Tag removed |

## Detail Payload Structure

All payloads use **snake_case** for JSON keys.

```json
{
  "event_data": {
    "id": "evt_xxxxxxxxxxxx",
    "occurred_at": "2025-12-19T10:30:00+09:00",
    "attr1": "value1",
    "attr2": "value2"
  },
  "resource": {
    // Full snapshot of the resource after the change
  }
}
```

### Fields

| Field | Description |
|-------|-------------|
| `event_data.id` | Unique event identifier (for idempotency) |
| `event_data.occurred_at` | Event timestamp (ISO 8601 with timezone) |
| `event_data.*` | Event-specific attributes |
| `resource` | Complete resource snapshot after the change |

## Payload Examples

### profile.changed.v1

```json
{
  "event_data": {
    "id": "evt_abc123def456",
    "occurred_at": "2025-12-19T10:30:00+09:00",
    "last_name": "Suzuki",
    "last_name_kana": "スズキ"
  },
  "resource": {
    "user_id": "usr_123456",
    "first_name": "Taro",
    "last_name": "Suzuki",
    "first_name_kana": "タロウ",
    "last_name_kana": "スズキ",
    "birth_date": "1990-01-15",
    "gender": "male",
    "tags": []
  }
}
```

### delivery_address.added.v1

```json
{
  "event_data": {
    "id": "evt_xyz789",
    "occurred_at": "2025-12-19T10:30:00+09:00",
    "zip_code": "100-0001",
    "prefecture_code": "13",
    "city": "Chiyoda-ku",
    "street": "Marunouchi 1-1-1",
    "building": "Tokyo Building 5F",
    "phone_number": "+819012345678",
    "country_code": "JP",
    "is_default": true
  },
  "resource": {
    "id": "da_789",
    "user_id": "usr_123456",
    "zip_code": "100-0001",
    "prefecture_code": "13",
    "city": "Chiyoda-ku",
    "street": "Marunouchi 1-1-1",
    "building": "Tokyo Building 5F",
    "phone_number": "+819012345678",
    "country_code": "JP",
    "is_default": true
  }
}
```

## EventBridge Rule Examples

### Subscribe to all events from a tenant

```json
{
  "source": ["com.twogate.idp/tenant_abc/users"]
}
```

### Subscribe to all profile events

```json
{
  "source": [{ "wildcard": "com.twogate.idp/*/users" }],
  "detail-type": [{ "prefix": "profile." }]
}
```

### Subscribe to specific event types

```json
{
  "detail-type": [
    "user.signed_up.v1",
    "user.deleted.v1"
  ]
}
```

## Design Decisions

### Naming Conventions

| Item | Convention |
|------|------------|
| `source` | Reverse domain notation (`com.twogate.idp`) |
| `detail-type` | `{resource}.{action}.{version}` (snake_case) |
| JSON keys in `detail` | snake_case |
| Resource names in `detail-type` | Singular (e.g., `profile`, not `profiles`) |
| Resource names in `source` | Plural (e.g., `users`) |

### Versioning

Version is included in `detail-type` (e.g., `.v1`). When making breaking changes to the payload structure, increment the version.

### References

- [CloudEvents Specification](https://github.com/cloudevents/spec)
- [AWS EventBridge Event Patterns](https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns.html)
