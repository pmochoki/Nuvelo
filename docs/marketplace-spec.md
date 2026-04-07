# Nuvelo — Multi-Vertical Marketplace

## Goal

Launch a bold, fast **multi-vertical marketplace** spanning clothes, housing, jobs, events, and more—connecting buyers, renters, job seekers, and attendees with sellers, landlords, employers, and organizers.

> If anything is unclear, choose sensible defaults and continue. Do not pause for Q&A. Use a widely supported, production-ready stack.
>

## Brand & UX

- Niche/vertical: All-in-one marketplace (apparel, housing, jobs, events)
- Brand voice: Confident, urban, energetic
- Primary: #111827, Secondary: #0EA5E9, Accent: #F59E0B
- Logo: generate placeholder
- Typography vibe: Rounded, bold headings, tight line-height
- Dark mode: Enable
- Layout style: List + sticky sidebar filters (category-specific)
- Tone: high contrast, big images, clear badges (NEW/FEATURED/ENDING SOON)

## Roles

- **Guest:** browse/search by category, seller/organizer pages, add to cart (goods), RSVP/save (events/jobs); guest checkout: Yes
- **Buyer/Renter/Job Seeker/Attendee:** checkout, order/application/RSVP history, messaging, reviews, profile/addresses
- **Seller/Landlord/Employer/Organizer:** onboarding (bio, socials), listing CRUD per vertical (products, properties, jobs, events), variants/stock where applicable, media; orders/booking requests; store/organization profile; messaging; earnings/payouts
- **Admin:** approve vendors, moderate listings, manage users/orders/refunds, set commissions, promos, featured collections, CMS

## Verticals & Listing Types

| Vertical | Listing Type | Key Fields |
|----------|--------------|------------|
| **Clothes** | Product | Title, price, size/color variants, stock, category, media |
| **Housing** | Property | Title, price/rent, beds/baths, location, availability, amenities, media |
| **Jobs** | Job Posting | Title, company, salary/range, location, type (FT/PT/Contract), deadline, description |
| **Events** | Event | Title, date/time, venue, price, capacity, tickets, media |

## Core Journeys

### Discovery & Catalog

- Home: hero, featured by vertical ("Trending Clothes", "New Listings", "Jobs Near You", "Upcoming Events"), category switcher
- Search + suggestions; filters: category, price, location, date (events), type (jobs), rating, seller; sorts: newest/price/rating/ending soon
- Category/vertical pages with SEO slugs
- Seller/Organizer pages: bio, socials, listings grid, contact/message

### Product / Property / Job / Event Detail

- **Clothes:** Gallery (zoom), title, price, color/size swatches, stock status, add to cart, reviews
- **Housing:** Gallery, title, rent/price, beds/baths, location map, availability calendar, amenities, contact/inquire
- **Jobs:** Title, company, salary, location, type, description, apply button, deadline
- **Events:** Hero image, title, date/time, venue, price, capacity, buy tickets / RSVP, share

### Cart & Checkout / Applications / Bookings

- Persistent cart for physical goods; quantity edits; totals auto-recalc
- Checkout: shipping (goods), tax, discount code, order summary
- Job applications: apply form, resume upload
- Event tickets: quantity, attendee info, payment
- Housing: inquiry / booking request flow
- Payment: Simulated; create order/application/booking + success page

### Orders / Applications / Bookings

- Order/application/booking history & detail; status timeline; tracking (orders)
- Returns/exchanges (goods); application status; booking cancellation
- Vendor/admin approval flows

### Reviews & Messaging

- Ratings/reviews per vertical; auto-flag spam
- Buyer ↔ seller messaging; email alerts

### Seller / Organizer Dashboard

- Onboarding & KYC; store/organization policies
- **Clothes:** CRUD, variants, inventory, bulk CSV, media
- **Housing:** CRUD, availability, amenities, media
- **Jobs:** CRUD, deadline, applications list
- **Events:** CRUD, tickets, capacity, attendee list
- Orders/requests: list/detail, fulfill/ship, refund/partial
- Earnings & payouts: Stripe Connect; schedule: Weekly
- Analytics: sales/listings, top items, conversion

### Admin Console

- Vendor approvals, moderation
- User/order/refund/dispute management
- Commission config, promo codes
- Featured collections/categories per vertical
- CMS pages

## Content, SEO & Accessibility

- SEO, slugs, sitemap, robots, JSON-LD
- OG/Twitter cards
- Accessible forms, keyboard nav, focus states

## Settings & Internationalization

- Currency: USD; Countries: US, UK, EU; Units: Imperial
- Taxes: Simple fixed rate
- Languages: en
- Social login: Google (Yes), Apple (Yes)
- Guest checkout: Yes

## Data Model

- User, Vendor, Category, **Listing** (polymorphic: Product | Property | Job | Event), Order/Application/Booking, Review, Message

## Sample Data & Demo Logins

- Seed sample data per vertical: e.g. 5 clothes sellers, 3 housing listings, 5 job posts, 3 events
- Demo:
    - Buyer: buyer@nuvelo.test / Password123
    - Vendor: vendor@nuvelo.test / Password123 (approved)
    - Admin: admin@nuvelo.test / Password123

## Optional Feature Flags

- Wishlists / Saved items: Yes
- Saved carts: Yes
- Discount codes: Yes
- Gift cards: No
- Multi-currency: Yes
- Vendor vacation mode: No
- Vendor custom domains: No
- Inventory reservations (goods): Yes
- Calendar availability (housing/events): Yes
