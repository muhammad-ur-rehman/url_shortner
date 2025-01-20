# URL Shortener

## Table of Contents

- [Overview](#overview)
- [Setup Instructions](#setup-instructions)
  - [Clone the Project](#clone-the-project)
  - [Install Dependencies](#install-dependencies)
  - [Set Up Rails Credentials](#set-up-rails-credentials)
  - [Run the Application](#run-the-application)
- [API Endpoints](#api-endpoints)
  - [Authentication](#authentication)
    - [Login](#login)
    - [Signup](#signup)
  - [URL Management](#url-management)
    - [Create a URL](#create-a-url)
    - [List URLs](#list-urls)
    - [Show a URL](#show-a-url)
    - [Redirect](#redirect)
- [Background Jobs](#background-jobs)
- [Improvements](#improvements)

---

## Overview
This application provides a URL shortening service with JWT-based authentication, caching, and support for background jobs to update click counts periodically.

---

## Setup Instructions

### Clone the Project
1. Clone the repository:
   ```bash
   git clone https://github.com/muhammad-ur-rehman/url_shortner
   cd url-shortener
   ```

### Install Dependencies
2. Install required gems:
   ```bash
   bundle install
   ```

### Set Up Rails Credentials
3. Set the JWT secret key in your Rails credentials:
   ```bash
   EDITOR="nano" rails credentials:edit
   ```
   Add the following:
   ```yaml
   devise_jwt_secret_key: "your_secret_key_here"
   ```

### Run the Application
4. Set up the database:
   ```bash
   rails db:setup
   ```

5. Start the Rails server:
   ```bash
   rails server
   ```

6. Start Sidekiq for background job processing:
   ```bash
   bundle exec sidekiq
   ```

7. Run the Specs:
   ```bash
   rspec
   ```

8. Run the rubocop:
   ```bash
   rubocop
   ```
---

## API Endpoints

### Authentication

#### Login
**Endpoint:** `/auth/login`

**Method:** `POST`

**Request:**
```json
{
  "email": "user@example.com",
  "password": "password"
}
```

**Response:**
```json
{
  "jwt": "<your_jwt_token>"
}
```

#### Signup
**Endpoint:** `/auth/signup`

**Method:** `POST`

**Request:**
```json
{
  "user": {
    "email": "user@example.com",
    "password": "password",
    "password_confirmation": "password"
  }
}
```

**Response:**
```json
{
  "jwt": "<your_jwt_token>"
}
```

### URL Management

#### Create a URL
**Endpoint:** `/api/urls`

**Method:** `POST`

**Headers:**
```text
Authorization: Bearer <your_jwt_token>
```

**Request:**
```json
{
  "url": {
    "original_url": "https://example.com",
    "expires_at": "2025-02-18 16:28:01"
  }
}
```

**Response:**
```json
{
  "id": 1,
  "original_url": "https://example.com",
  "key": "short_key",
  "click_count": 0,
  "expires_at": "2025-02-18T16:28:01.000Z",
  "shortened_url": "/short_key"
}
```

#### List URLs
**Endpoint:** `/api/urls`

**Method:** `GET`

**Headers:**
```text
Authorization: Bearer <your_jwt_token>
```

**Request:**
```text
/api/urls?per_page=2
```

**Response:**
```json
{
  "data": [
    {
      "id": 1,
      "original_url": "https://example.com",
      "key": "short_key",
      "click_count": 0,
      "expires_at": "2025-02-18T16:28:01.000Z",
      "shortened_url": "/short_key"
    }
  ],
  "metadata": {
    "total_pages": 1,
    "current_page": 1,
    "total_count": 1
  }
}
```

#### Show a URL
**Endpoint:** `/api/urls/:id`

**Method:** `GET`

**Headers:**
```text
Authorization: Bearer <your_jwt_token>
```

**Response:**
```json
{
  "id": 1,
  "original_url": "https://example.com",
  "key": "short_key",
  "click_count": 10,
  "expires_at": "2025-02-18T16:28:01.000Z",
  "shortened_url": "/short_key"
}
```

#### Redirect
**Endpoint:** `/:key`

**Method:** `GET`

**Description:** Redirects to the original URL associated with the provided key.

---

## Background Jobs

The `SyncClickCountJob` runs every 5 minutes to synchronize the click counts from the cache to the database.

### Improvements
- Replace the cron job with a messaging queue like Kafka or RabbitMQ for faster and more reliable updates.

