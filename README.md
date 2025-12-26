# Smart Task Management App

## 1. Project Overview

The **Smart Task Management App** is a full-stack task management application built to help users efficiently create, organize, and track tasks with enhanced intelligence. The application supports task categorization, priority management, status tracking, and audit history, making it suitable for both personal and professional task workflows.

The goal of this project was to:

* Build a **production-style Flutter application** integrated with a backend API
* Practice **clean architecture, OOP principles, and RESTful design**
* Implement **real-world features** like priority updates, task history, and filtering
* Demonstrate end-to-end development from database to UI

---

## 2. Tech Stack

### Frontend (Mobile App)

* **Flutter**
* **Dart**
* Material UI
* REST API integration

### Backend

* **Node.js / FastAPI** (API layer)
* RESTful API architecture
* OOP-based service and handler structure

### Database

* **Supabase (PostgreSQL)**
* UUID-based primary keys
* JSONB fields for flexible metadata

### Tools & Others

* Git & GitHub
* Postman (API testing)
* Render (Backend deployment)

---

## 3. Setup Instructions

### Prerequisites

* Flutter SDK installed
* Node.js / Python (based on backend choice)
* Supabase account
* Android Studio / Emulator or Physical Device

---

### Backend Setup

1. Clone the repository

   ```bash
   git clone <https://github.com/GowriChandanaPB/smart-task-manager-backend>
   cd backend
   ```

2. Install dependencies

   ```bash
   npm install
   ```

3. Configure environment variables

   ```env
   DATABASE_URL=https://jcdrfgsypujxufmcwslf.supabase.co
   ```

4. Run the backend server

   ```bash
   npm run dev
   ```

Backend will start at:

```
http://localhost:4000
```

---

### Flutter App Setup

1. Navigate to Flutter project

   ```bash
   cd smart_task_manager
   ```

2. Get dependencies

   ```bash
   flutter pub get
   ```

3. Run the app

   ```bash
   flutter run
   ```

---

## 4. API Documentation

### Create Task

**POST** `/api/tasks`

**Request Body**

```json
{
  "title": "Finish README",
  "description": "Write project documentation",
  "category": "technical",
  "priority": "high",
  "status": "pending",
  "assigned_to": "Gowri",
  "due_date": "2025-01-01"
}
```

**Response**

```json
{
  "success": true,
  "task_id": "uuid"
}
```

---

### Get All Tasks

**GET** `/api/tasks`

**Query Params (optional)**

* `status`
* `category`
* `priority`

**Response**

```json
{
  "tasks": [
    {
      "id": "uuid",
      "title": "Finish README",
      "priority": "high",
      "status": "pending"
    }
  ]
}
```

---

### Update Task

**PUT** `/api/tasks/{id}`

**Request Body**

```json
{
  "priority": "high",
  "status": "in_progress"
}
```

---

## 5. Database Schema

### Tasks Table

| Column             | Type      | Description                                         |
| ------------------ | --------- | --------------------------------------------------- |
| id                 | UUID      | Primary key                                         |
| title              | TEXT      | Task title                                          |
| description        | TEXT      | Task details                                        |
| category           | TEXT      | scheduling / finance / technical / safety / general |
| priority           | TEXT      | low / medium / high                                 |
| status             | TEXT      | pending / in_progress / completed                   |
| assigned_to        | TEXT      | Assignee                                            |
| due_date           | TIMESTAMP | Due date                                            |
| extracted_entities | JSONB     | NLP extracted data                                  |
| suggested_actions  | JSONB     | AI suggestions                                      |
| created_at         | TIMESTAMP | Created time                                        |
| updated_at         | TIMESTAMP | Updated time                                        |

### Task History Table

| Column     | Type      | Description                   |
| ---------- | --------- | ----------------------------- |
| id         | UUID      | Primary key                   |
| task_id    | UUID      | Foreign key (tasks.id)        |
| action     | TEXT      | created / updated / completed |
| old_value  | JSONB     | Previous state                |
| new_value  | JSONB     | Updated state                 |
| changed_by | TEXT      | User                          |
| changed_at | TIMESTAMP | Change time                   |

---

## 6. Screenshots

> Screenshots of the Flutter application:

* LightTheam Dashboard
![image alt](https://github.com/GowriChandanaPB/smart-task-manager-backend/blob/5f6f28f582bd9a1da3a45af632a4c958dc8a783e/lightdark.jpeg)

* Create Task
![image alt](https://github.com/GowriChandanaPB/smart-task-manager-backend/blob/54dca3e55b95ec9327c57ca49739825e01f948b4/create_task.jpeg)

---

## 7. Architecture Decisions

* **Clean separation of concerns** between UI, services, and data layers
* **OOP-based backend** for maintainability and scalability
* **Supabase** chosen for fast PostgreSQL setup and reliability
* **UUIDs** used to avoid ID collisions
* **Task history table** added for audit and tracking changes

---

## 8. What I’d Improve With More Time

* User authentication & role-based access
* Real-time updates using WebSockets
* Advanced AI-based task suggestions
* Offline-first support in Flutter
* Push notifications for due dates
* Proper CI/CD pipeline

---

## Conclusion

This project demonstrates a complete, real-world task management system covering backend APIs, database design, and Flutter UI integration, following clean coding and scalable architecture principles.
