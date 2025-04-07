# TODO List API Application - Planning Document

## Project Overview
This document outlines the high-level plan for developing a robust TODO list API application using the Phoenix framework in Elixir. The application will provide a complete set of CRUD operations for managing tasks, along with filtering, sorting, and potentially user authentication features.

## Project Scope

### Core Features (MVP)
- Todo item CRUD operations
  - Create, read, update, and delete todo items
  - Each todo includes: ID, name, description, due date, and status
- Filtering todos by status and due date
- Sorting todos by different attributes
- API documentation using Swagger
- Comprehensive test coverage

### Extended Features (Post-MVP)
- User authentication and authorization
- Collaborative todo lists (sharing)
- Tags/categories for todos
- Priority levels for todos
- Task reminders/notifications
- Team management for shared todos

## Technology Stack

### Backend
- **Language**: Elixir
- **Framework**: Phoenix
- **Database**: PostgreSQL
- **API Format**: JSON REST API

### Architecture Components
- **Ecto**: For database interactions and schema definitions
- **Phoenix Controllers**: For handling HTTP requests
- **Phoenix Context**: For business logic separation
- **Ex_doc**: For API documentation
- **ExUnit**: For testing

### DevOps & Deployment
- **Docker**: For containerization
- **GitHub Actions**: For CI/CD pipeline
- **Fly.io**: For deployment

## Data Model

### Todo Schema
```elixir
schema "todos" do
  field :name, :string
  field :description, :string
  field :due_date, :utc_datetime
  field :status, Ecto.Enum, values: [:not_started, :in_progress, :completed]
  
  # Extended features
  field :priority, Ecto.Enum, values: [:low, :medium, :high], default: :medium
  # For user authentication
  belongs_to :user, User
  
  timestamps()
end
```

### User Schema (Extended Feature)
```elixir
schema "users" do
  field :email, :string
  field :password_hash, :string
  field :name, :string
  
  has_many :todos, Todo
  
  timestamps()
end
```

## API Endpoints

### Todo Endpoints
- `GET /api/todos` - List all todos (with filtering/sorting)
- `GET /api/todos/:id` - Get a specific todo
- `POST /api/todos` - Create a new todo
- `PUT /api/todos/:id` - Update a todo
- `DELETE /api/todos/:id` - Delete a todo

### Authentication Endpoints (Extended)
- `POST /api/users/register` - Register a new user
- `POST /api/users/login` - Log in a user
- `GET /api/users/me` - Get current user info

## Development Approach
1. **Test-Driven Development (TDD)**: Writing tests before implementing features
2. **SOLID Principles**: Ensuring clean, maintainable code
3. **Incremental Development**: Building core features first, then adding extended features
4. **Documentation-First**: Documenting API endpoints before implementation

## Quality Assurance
- Unit tests for all business logic
- Integration tests for API endpoints
- Documentation using ExDoc and Swagger
- CI/CD pipeline for automated testing and deployment

## Roadmap
1. Set up project structure and database
2. Implement Todo schema and migrations
3. Create Todo CRUD operations
4. Add filtering and sorting functionality
5. Implement API documentation
6. Add user authentication (extended)
7. Implement collaborative features (extended) 