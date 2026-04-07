# Data Model

## User
- id
- name
- role (buyer/tenant/customer/seller/agent/landlord; `customer` is legacy)
- email
- phone
- emailVerified
- phoneVerified
- banned
- createdAt

## Category
- id
- name

## Location
- id
- name
- region

## Listing
- id
- title
- description
- categoryId
- price
- currency
- location
- images
- condition
- categoryFields (object)
- userId
- status (pending/approved/rejected)
- createdAt

## Conversation
- id
- listingId
- buyerId
- sellerId
- createdAt

## Message
- id
- conversationId
- senderId
- text
- createdAt

## Report
- id
- type (listing/user/message)
- targetId
- reason
- reporterId
- status
- createdAt

## Favorite
- id
- userId
- listingId
- createdAt

## SavedSearch
- id
- userId
- query
- categoryId
- location
- minPrice
- maxPrice
- createdAt

## Block
- id
- blockerId
- blockedId
- createdAt
