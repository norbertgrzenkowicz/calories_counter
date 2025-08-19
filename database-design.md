
Table: users
Columns:
- id (PK, integer, auto-increment)
- username (varchar, unique, not null)
- email (varchar, unique, not null)
- password_hash (varchar, not null)
- created_at (timestamp, default now())

Table: meals
Columns:
- id (PK, integer, auto-increment)
- user_id (FK, integer, not null, references users(id))
- name (varchar, not null)
- calories (integer, not null)
- proteins (decimal, not null)
- fats (decimal, not null)
- carbs (decimal, not null)
- photo_path (varchar, nullable)
- meal_date (datetime, not null)
- created_at (timestamp, default now())
