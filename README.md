# Filipino Cookbook API

## API Description

The Filipino Cookbook API is a RESTful web service that provides structured information about traditional Filipino dishes, including their categories, regional origins, and ingredients. It was built as a laboratory activity for the Collaborative API Development and Integration project.

- **Purpose:** To give developers programmatic access to a curated database of Filipino foods for use in web or client applications.
- **Type of information provided:** Filipino dishes, their categories (ex. Main Dish, Dessert), regional origins, cooking instructions, and ingredient lists.
- **Intended users:** Students building client/driver applications that consume this API, and anyone interested in Filipino cuisine data.
- **Main functions:** Retrieve all foods, retrieve a single food by ID, search foods by name, list categories, list ingredients, and add a new food entry.
- **Technologies used:** PHP, Slim Framework 4, MySQL, Composer, and token-based authentication.

## Features

- Retrieve all Filipino foods with their category, origin, and ingredients
- Retrieve the full details of a specific food by ID
- Search for foods by name
- Retrieve all food categories
- Retrieve all ingredients
- Add a new food entry with ingredients via POST
- Authenticate requests using a Bearer token
- All responses returned in JSON format

## Technologies Used

- PHP 8.2
- Slim Framework 4
- MySQL
- Composer
- JSON
- Apache via XAMPP
- XAMPP
- Thunder Client for API testing
- Git and GitHub

## Installation Instructions

1. Clone the repository:
   ```
   git clone https://github.com/Saisoku-alt/filipino-cookbook-api-taborda.git
   cd filipino-cookbook-api-taborda
   ```
2. Install dependencies:
   ```
   composer install
   ```
3. Copy `config.example.php` to `config.php`:
   ```
   copy config.example.php config.php
   ```
   Then open `config.php` and fill in your own database username, password, and API token.
4. Import the database (see **Database Setup** below).
5. Place the project inside your XAMPP `htdocs` folder (if not already there).
6. Start **Apache** and **MySQL** in the XAMPP Control Panel.
7. Access the API at the **Base URL** below.

## Database Setup

- **Database name:** `filipino_cookbook_api`
- **SQL file:** `filipino_foods_relational.sql`
- **Import instructions:** In phpMyAdmin, create a database named `filipino_cookbook_api`, then import `filipino_foods_relational.sql` into it.
- **Table relationships:**
  ```
  categories -> foods <- origins
  foods -> food_ingredients <- ingredients
  ```

## Base URL

```
http://localhost/filipino-cookbook-api/public/api
```

## Authentication Instructions

All `/api` routes require a Bearer token, set via `API_TOKEN` in your local `config.php`.

**Required header:**
```
Authorization: Bearer YOUR_ACCESS_TOKEN
```

**Response when authentication is missing or invalid:**
```json
{
  "status": "error",
  "message": "Unauthorized access. Valid API token is required."
}
```

## Endpoint Documentation

### GET /api/foods
Returns all Filipino foods, including category, origin, and ingredients.

**Headers:** `Authorization: Bearer YOUR_ACCESS_TOKEN`

**Example request:**
```
GET http://localhost/filipino-cookbook-api/public/api/foods
```

**Example response:**
```json
[
  {
    "food_id": 1,
    "food_name": "Adobo",
    "category_name": "Main Dish",
    "origin_name": "Philippines",
    "instructions": "...",
    "ingredients": ["Chicken", "Soy sauce", "Vinegar", "Garlic"]
  }
]
```

### GET /api/foods/{id}
Returns the full details of a single food by ID.

**Example request:**
```
GET http://localhost/filipino-cookbook-api/public/api/foods/1
```

**Error response (not found):**
```json
{
  "status": "error",
  "message": "Food not found"
}
```

### GET /api/foods/search/{name}
Searches for foods whose name matches the given text.

**Example request:**
```
GET http://localhost/filipino-cookbook-api/public/api/foods/search/adobo
```

### GET /api/categories
Returns all food categories.

**Example request:**
```
GET http://localhost/filipino-cookbook-api/public/api/categories
```

### GET /api/ingredients
Returns all ingredients.

**Example request:**
```
GET http://localhost/filipino-cookbook-api/public/api/ingredients
```

### POST /api/foods
Adds a new food entry.

**Body (JSON or form):**
```json
{
  "food_name": "Sinigang",
  "category_id": 1,
  "origin_id": 1,
  "instructions": "...",
  "ingredient_ids": [1, 2, 3]
}
```

**Success response:**
```json
{
  "status": "success",
  "message": "Food added successfully."
}
```

## HTTP Status Codes

| Status Code | Meaning |
|---|---|
| 200 | Request completed successfully |
| 201 | Resource created successfully |
| 400 | Invalid request or missing required parameter |
| 401 | Missing or invalid authentication |
| 404 | Requested resource was not found |
| 500 | Internal server error |

## Testing Evidence

## Testing Evidence

**GET /api/foods — successful response**
![Get all foods](screenshots/Post_Foods.png)

**GET /api/foods/{id} — successful response**
![Get single food](screenshots/Post_Foods_Id.png)

**Missing/invalid token — 401 Unauthorized**
![Unauthorized](screenshots/Test_Unauthorized.png)

**Non-existent food — 404 Not Found**
![Not found](screenshots/Food_Id_Not_Found.png)

## Developer Information

- **Name:** Jake Taborda
- **Course and Section:** BS Information Technology 4-B
- **GitHub Username:** Saisoku-alt
- **Repository Link:** https://github.com/Saisoku-alt/filipino-cookbook-api-taborda
- **Date Completed:** 8/01/2026
