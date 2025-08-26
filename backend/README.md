# FitNation API

A FastAPI-based backend service for the FitNation Android app, backed by Supabase.

---

## Table of Contents

1. [Features](#features)  
2. [Prerequisites](#prerequisites)  
3. [Project Structure](#project-structure)  
4. [Setup](#setup)  
   - [Environment Variables](#environment-variables)  
   - [Python Dependencies](#python-dependencies)  
5. [Running Locally](#running-locally)  
6. [API Documentation](#api-documentation)  
7. [Docker](#docker)  
   - [Build & Run Container](#build--run-container)  
   - [Docker Compose (with Local Supabase Emulator)](#docker-compose-with-local-supabase-emulator)  
8. [Testing](#testing)  
9. [License](#license)  

---

## Features

- **Signup & Login** with JWT tokens  
- **Password Reset** via email  
- **OTP Verification** for secure flows  
- **Profile Update** endpoint  
- **Swagger UI** (`/docs`) & ReDoc (`/redoc`)  

---

## Prerequisites

- Python 3.9+  
- [Poetry](https://python-poetry.org/) _or_ `pip` & `venv`  
- Supabase account & project  
- Docker & Docker Compose _(optional)_  

---

## Project Structure

```bash

   app
    ├───api
    │   └───v1
    │       └───endpoints        
    ├───core
    ├───crud
    ├───database
    ├───middleware
    ├───models
    └───schemas
    └───main.py

```
---

## Setup

### Environment Variables

Copy and populate `.env` from the example:

```bash
cp .env.example .env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-service-role-key
ACCESS_TOKEN_EXPIRE_MINUTES=60
SECRET_KEY=your-very-secret-key
```

Python Dependencies
Using pip & venv:

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```
Or Poetry:

```bash
poetry install
poetry shell
```
### Running Locally

```uvicorn app.main:app --reload --host 0.0.0.0```

Swagger UI → http://127.0.0.1:8000/docs

ReDoc → http://127.0.0.1:8000/redoc

### Docker
A Dockerfile is provided to containerize the service.

Build & Run Container
```bash
docker build -t fitnation-auth .
docker run -d \
  --name fitnation-auth \
  --env-file .env \
  -p 8000:80 \
  fitnation-auth
```
App will be accessible at http://localhost:8000

Swagger UI → http://127.0.0.1:8000/docs


## API Documentation
Each route is documented in the /docs UI, and also in the docs/ folder:

```
docs/signup.md

docs/login.md

docs/forgot_password.md

docs/verify_otp.md

docs/change_password.md

docs/update_profile.md
```