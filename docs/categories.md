# Categories and Fields

All listings use a shared core schema with category-specific fields.

## Core fields (all categories)
- title
- description
- categoryId
- price (optional for jobs)
- currency
- location (city, district)
- images (0..8)
- condition
- categoryFields (object)

## Category-specific fields
### Rentals / Real estate
- type (apartment/room/house)
- bedrooms
- bathrooms
- area
- furnished (yes/no)
- lease

### Jobs
- role
- contractType (full-time/part-time/contract)
- salaryRange
- experience

### Seeking work (CV profiles)
- roleSought
- experience
- languages
- workPermit (eu_citizen / work_permit / student / needs_sponsorship)
- availability
- workMode (on_site / remote / hybrid)
- salaryExpectation (optional)
- cvLink (optional)

### Clothes
- size
- brand

### Services
- serviceType
- availability
- serviceArea

### Electronics
- brand
- model
- storage
- warranty

### Vehicles
- make
- model
- year
- mileage
- transmission
- fuel
