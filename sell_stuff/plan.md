# Sell Stuff - Project Plan

## Overview
We will build a simple storefront application focused on allowing users to list items for sale. It will share the overall project structure of `multi_counter`, utilizing a common Dart workspace with `app`, `server`, and `shared` packages.

## Core Features

### 1. Sell Page (Primary Focus)
A form-based screen allowing a user to create a new product listing.
**Fields:**
- Image (upload)
- Title
- Description
- Price
- Category

### 2. Listing Page
A minimal grid layout displaying all items currently for sale.
- Clicking an item in the grid opens a detailed view of the item.

## Project Structure

* **`shared`**: Contains code shared between the client and server.
  * **Data Models:** The core `Listing` data model.
* **`app`**: The frontend client application.
  * Main screens: Sell Page (Form), Listing Page (Grid), and Item Detail Page.
  * Logic for uploading images and submitting listing data.
* **`server`**: The backend.
  * API endpoint to handle new listing submissions.
  * API endpoint to retrieve the list of available items.

## Proposed Implementation Steps
1. **Scaffold Project:** Set up the `app`, `server`, and `shared` packages.
2. **Define Data Models:** Create the `Listing` data item in the `shared` package.
3. **Backend Setup:** Implement the server logic and data persistence layer.
4. **App UI:** Build the Sell Page form and Listing Page grid.
5. **Integration:** Connect the app to the server to finalize the end-to-end flow.

A key feature of this app is using functions support to mitigate create/edit of the entries
to make sure the data is valid beyond what you can do with normal Firebase rules.

If you want help runnig the server and/or client to validate things I can provide instructions when we get that far.