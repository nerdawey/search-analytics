#  Search Analytics Platform


## Features

### Core Functionality
- **Real-time Search**: Instant search results as you type
- **Smart Analytics**: Only records final meaningful searches (prevents "pyramid problem")
- **User Tracking**: Anonymous user identification via IP + session hashing
- **Article Management**: Full article viewing with view tracking
- **Analytics Dashboard**: Comprehensive search and article analytics

### Advanced Features
- **Search Finalization**: Intelligent filtering of intermediate searches
- **Performance Optimized**: Handles thousands of requests per hour
- **Scalable Architecture**: Built for growth and high traffic
- **Comprehensive Testing**: Full test coverage with performance benchmarks

##  Tech Stack

- **Backend**: Ruby on Rails 7.1.0
- **Database**: PostgreSQL
- **Background Jobs**: Sidekiq + Redis (currently bypassed for reliability)
- **Frontend**: Vanilla JavaScript (no framework dependencies)
- **Testing**: RSpec, FactoryBot, Capybara, Performance Testing
- **Code Quality**: RuboCop with comprehensive linting
- **Deployment**: Heroku/Render ready

##  Prerequisites

- Ruby 3.2.6
- Rails 7.1.0
- PostgreSQL
- Node.js (for asset compilation)

##  Quick Start

### 1. Clone the Repository
```bash
git clone <repository-url>
cd search_analytics
```

### 2. Install Dependencies
```bash
bundle install
```

### 3. Database Setup
```bash
rails db:create
rails db:migrate
rails db:seed
```

### 4. Start the Server
```bash
rails server
```

Visit `http://localhost:3000` to see the application.

##  How It Works

### Search Analytics Algorithm

The platform solves the "pyramid problem" by intelligently tracking user search behavior:

**❌ Bad Example (Pyramid Problem):**
```
User types: "Hello" → "Hello world" → "Hello world how are you?"
System records: "Hello", "Hello world", "Hello world how are you?"
```

**✅ Good Example (Our Solution):**
```
User types: "Hello" → "Hello world" → "Hello world how are you?"
System records: "Hello world how are you?" (only the final meaningful search)
```

### User Identification
- Anonymous user tracking via IP + session cookie hashing
- No personal data collection
- Unique user identification for analytics

### Real-time Processing
- Keystroke events logged for analysis
- Finalize events trigger analytics processing
- Synchronous processing for reliability

##  Architecture

### Models
- **Article**: Content management with search functionality
- **SearchEvent**: Raw event logging (keystrokes, finalizations)
- **SearchSummary**: Aggregated search analytics per user
- **ArticleView**: Article view tracking per user

### Controllers
- **SearchController**: Main search interface and analytics dashboard
- **ArticlesController**: Article viewing and view tracking
- **Api::SearchEventsController**: Real-time event processing

### Key Features
- **Search Finalization**: Removes intermediate searches
- **Term Normalization**: Consistent search term handling
- **Session Management**: User session tracking
- **Performance Optimization**: Database indexing and query optimization

##  Testing

### Run All Tests
```bash
bundle exec rspec
```

### Test Coverage
- **Model Tests**: Validations, associations, scopes, custom methods
- **Controller Tests**: Action behavior, user identification, error handling
- **Request Tests**: API endpoints, integration testing
- **Performance Tests**: Load testing, response time validation

### Performance Benchmarks
```bash
bundle exec rspec spec/performance/
```

**Performance Targets:**
- Search queries: < 500ms
- API events: < 50ms
- Analytics dashboard: < 200ms
- Database queries: < 50ms

##  Analytics Dashboard

### Available Metrics
- **Top Searched Terms**: Most popular search terms
- **Recent Searches**: User's recent search history
- **Most Visited Articles**: Popular articles by view count
- **Search Trends**: Time-based search patterns
- **User Statistics**: Overall platform usage metrics

### Interactive Features
- Clickable search terms (auto-search)
- Clickable articles (full article viewing)
- Real-time data updates
- User-specific analytics

## Configuration

### Environment Variables
```bash
# Database
DATABASE_URL=postgresql://user:password@localhost/search_analytics

# Redis (for Sidekiq)
REDIS_URL=redis://localhost:6379

# Rails
RAILS_ENV=production
SECRET_KEY_BASE=your-secret-key
```

### Database Configuration
- PostgreSQL with optimized indexes
- Connection pooling for performance
- Migration-based schema management


##  API Endpoints

### Search Events API
```http
POST /api/search_events
Content-Type: application/json

{
  "search_event": {
    "raw_value": "search term",
    "event_type": "keystroke|finalize",
    "session_id": "unique-session-id"
  }
}
```

### Search Interface
```http
GET /search?q=search+term
```

### Analytics Dashboard
```http
GET /analytics
```

### Article Viewing
```http
GET /articles/:id
```

##  Security

### Data Protection
- **Anonymous Tracking**: No personal data collection
- **Hashed Identifiers**: Secure user identification
- **Input Validation**: Sanitized search inputs
- **CSRF Protection**: Rails built-in security

### Privacy Features
- **No Personal Data**: Only anonymous analytics
- **Session-based**: Temporary user identification
- **Compliant**: GDPR-friendly data handling


### Code Quality
- **RuboCop**: All code must pass linting
- **RSpec**: Maintain test coverage