# API Overview

Base URL: `http://localhost:4000`

## Health
- `GET /health`

## Categories
- `GET /categories`

## Auth
- `POST /auth/login`

## Listings
- `GET /listings?query=&categoryId=&location=&minPrice=&maxPrice=&status=&userId=`
- `GET /listings/:id`
- `POST /listings`
- `PUT /listings/:id`
- `DELETE /listings/:id`

## Conversations and Messages
- `POST /conversations`
- `GET /conversations?userId=`
- `GET /conversations/:id/messages`
- `POST /conversations/:id/messages`
- `POST /conversations/:id/mark-read`

## Favorites and Saved Searches
- `GET /favorites?userId=`
- `POST /favorites`
- `DELETE /favorites`
- `GET /saved-searches?userId=`
- `POST /saved-searches`
- `DELETE /saved-searches/:id`

## Blocks
- `POST /blocks`
- `GET /blocks?userId=`

## Reports and Moderation
- `POST /reports`
- `GET /admin/reports`
- `POST /admin/reports/:id/resolve`
- `GET /admin/listings?status=pending|approved|rejected`
- `POST /admin/listings/:id/status`
- `POST /admin/ban-user`
- `GET /admin/categories`
- `POST /admin/categories`
- `PUT /admin/categories/:id`
- `GET /admin/metrics`
