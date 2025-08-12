# Create User and Log In API

## Description

This is an api to create a user and log in.Client submits registration data. Server validates and creates new user and return public user data excluding the sensitive fields

## Base URL

The base URL for all API requests is:

```http
http://localhost:8000/api/v1/auth
```

## Endpoint

```http
POST /api/v1/auth/register
POST /api/v1/auth/login
```

## Validation Rules

For User Registration
| Field | Requirements |
| ----------- | ----------- |
| username | 3-20 chars,unique |
| email | Valid format,unique |
|password | Minimum 8 chars, special chars|
|role |Defaults to "user" if not specified|

## Response

Return a JSON object with the following properties for registration:

```http
{
  "username": "string",
  "email": "user@example.com",
  "id": "497f6eca-6276-4993-bfeb-53cbbbba6f08",
  "role": "string",
  "created_at": "2019-08-24T14:15:22Z"
}
```

Returns a JSON object with following properties for login:

```http
{
  "access_token": "string",
  "token_type": "bearer"
}

```

## Example

Request:

```http
POST /api/v1/auth/register
```

Response:

```http
{
  "username": "arqam",
  "email": "arqam@example.com",
  "id": "510629a6-50f5-4f4f-9019-51e553576db6",
  "role": "user",
  "created_at": "2025-05-25T09:58:40.719141+00:00"
}
```

```http
POST /api/v1/auth/login
```

Response:

```http
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhcnFhbSIsImV4cCI6MTc0ODE2OTAyMH0.daQq8m9M4UrRR9NFksDA51ALlVOWCuZOd8ZLTfF9BAw",
  "token_type": "bearer"
}
```

## Errors

**Registration Errors**

| Code | Condition         | Response Body                |
| ---- | ----------------- | ---------------------------- |
| 400  | Username exists   | {"detail": "Username taken"} |
| 400  | Email exists      | {"detail": "Email taken"}    |
| 422  | Validation failed | Field-specific errors        |

**Login Errors**

| Code | Condition           | Response Body                  |
| ---- | ------------------- | ------------------------------ |
| 401  | Invalid credentials | {"detail": "Bad credentials"}  |
| 400  | Inactive account    | {"detail": "Inactive account"} |
| 422  | Invalid form data   | Form validation errors         |
