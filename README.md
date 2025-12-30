# K-Dopamine 🚀

Spring Boot + PostgreSQL + Docker (Environment Variables Based)

## 📋 Tech Stack

- **Backend**: Spring Boot 4.0.1
- **Language**: Java 17
- **Database**: PostgreSQL 16
- **Build Tool**: Gradle
- **Container**: Docker & Docker Compose

## 🏗️ Project Structure

```
src/main/java/com/kdopamine/app/
├── global/
│   ├── exception/         # Exception handling
│   │   ├── ErrorCode.java
│   │   ├── BusinessException.java
│   │   └── GlobalExceptionHandler.java
│   └── response/          # Common API response
│       ├── ApiResponse.java
│       └── ErrorResponse.java
├── domain/                # Domain packages
└── KDopamineApplication.java
```

## 🚀 Quick Start

### 1. Environment Setup

```bash
# Copy .env.example to .env
cp .env.example .env

# Edit .env if needed
vim .env
```

### 2. Run PostgreSQL with Docker

```bash
# Start PostgreSQL + PgAdmin
docker-compose up -d

# Check logs
docker-compose logs -f postgres

# Check status
docker-compose ps
```

### 3. Run Application

```bash
# Run with Gradle
./gradlew bootRun

# Or run with IntelliJ
# KDopamineApplication.java -> Run
```

### 4. Access

- **API Server**: http://localhost:8080
- **PgAdmin**: http://localhost:5050
  - Email: `admin@kdopamine.com`
  - Password: `admin123`

## 📝 Environment Variables (.env)

```bash
# Application
SPRING_PROFILES_ACTIVE=local    # Profile: local, prod
SERVER_PORT=8080

# Database
DB_HOST=localhost               # Docker: localhost, Production: DB server IP
DB_PORT=5432
DB_NAME=kdopamine
DB_USERNAME=postgres
DB_PASSWORD=postgres

# JPA
JPA_DDL_AUTO=update            # validate, update, create, create-drop
JPA_SHOW_SQL=true
JPA_FORMAT_SQL=true

# Logging
LOG_LEVEL_ROOT=INFO
LOG_LEVEL_APP=DEBUG
LOG_LEVEL_SQL=DEBUG

# PgAdmin (Optional)
PGADMIN_EMAIL=admin@kdopamine.com
PGADMIN_PASSWORD=admin123
PGADMIN_PORT=5050
```

## 🔧 Profile Configuration

### Local (Development)
```bash
SPRING_PROFILES_ACTIVE=local
JPA_DDL_AUTO=update
```
- DDL: `update` (Auto schema update)
- SQL Logging: `ON`
- Debug Logging: `ON`

### Prod (Production)
```bash
SPRING_PROFILES_ACTIVE=prod
JPA_DDL_AUTO=validate
```
- DDL: `validate` (Schema validation only)
- SQL Logging: `OFF`
- Log Level: `INFO`

## 🐳 Docker Commands

```bash
# Start containers
docker-compose up -d

# Stop containers
docker-compose down

# Restart
docker-compose restart

# View logs
docker-compose logs -f

# Remove all (including volumes - WARNING: deletes data!)
docker-compose down -v

# Connect to PostgreSQL
docker exec -it kdopamine-postgres psql -U postgres -d kdopamine
```

## 🗃️ Database Info

- **Host**: localhost
- **Port**: 5432
- **Database**: kdopamine
- **Username**: postgres (configurable in .env)
- **Password**: postgres (configurable in .env)

### Backup & Restore
```bash
# Backup
docker exec kdopamine-postgres pg_dump -U postgres kdopamine > backup.sql

# Restore
docker exec -i kdopamine-postgres psql -U postgres kdopamine < backup.sql
```

## 📝 API Response Examples

### Success Response
```json
{
  "success": true,
  "data": {
    "id": 1,
    "name": "John Doe"
  },
  "message": "Success",
  "timestamp": "2025-12-30T10:30:00"
}
```

### Error Response
```json
{
  "code": "USER001",
  "message": "User not found",
  "errors": [],
  "timestamp": "2025-12-30T10:30:00"
}
```

### Validation Error
```json
{
  "code": "INVALID_INPUT",
  "message": "Invalid input values",
  "errors": [
    {
      "field": "email",
      "value": "invalid@",
      "reason": "Invalid email format"
    }
  ],
  "timestamp": "2025-12-30T10:30:00"
}
```

## 🛠️ Gradle Commands

```bash
# Build
./gradlew build

# Test
./gradlew test

# Clean build
./gradlew clean build

# Run
./gradlew bootRun

# Check dependencies
./gradlew dependencies
```

## 🐛 Troubleshooting

### PostgreSQL Connection Failed
```bash
# Check container status
docker-compose ps

# Check logs
docker-compose logs postgres

# Restart
docker-compose restart postgres
```

### Port Conflict (5432)
```bash
# Check port usage
lsof -i :5432

# Change port in .env
DB_PORT=5433

# Update docker-compose.yml ports section
```

### Environment Variables Not Applied
```bash
# Install EnvFile plugin in IntelliJ
# Run Configuration -> EnvFile tab -> Add .env file

# Or export manually
export $(cat .env | xargs)
./gradlew bootRun
```

## 📚 Additional Documentation

- [API Usage Guide](README_USAGE.md)
- [Error Codes](src/main/java/com/kdopamine/app/global/exception/ErrorCode.java)

## 🔒 Security

- **NEVER commit `.env` file to Git**
- Use `.env.example` as template
- Use strong passwords in production
- Keep database credentials secure

## 📄 License

This project is private.

