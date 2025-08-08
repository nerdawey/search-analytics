# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create dummy articles for testing
puts "Creating dummy articles..."

articles_data = [
  {
    title: "Getting Started with Ruby on Rails",
    content: "Ruby on Rails is a web application framework written in Ruby. It follows the Model-View-Controller (MVC) pattern and emphasizes convention over configuration. This article will guide you through setting up your first Rails application, understanding the basic structure, and deploying it to production. Rails makes web development faster and more enjoyable by providing sensible defaults and a rich ecosystem of gems.",
    published_at: 1.week.ago
  },
  {
    title: "Advanced JavaScript Techniques for Modern Web Apps",
    content: "Modern web applications require sophisticated JavaScript techniques to provide smooth user experiences. This article covers ES6+ features, async/await patterns, functional programming concepts, and performance optimization strategies. Learn how to build scalable, maintainable JavaScript code that works across different browsers and devices.",
    published_at: 5.days.ago
  },
  {
    title: "Database Design Best Practices",
    content: "Good database design is crucial for application performance and maintainability. This comprehensive guide covers normalization, indexing strategies, query optimization, and schema design patterns. Whether you're using PostgreSQL, MySQL, or another database system, these principles will help you create efficient and scalable data structures.",
    published_at: 3.days.ago
  },
  {
    title: "Building Real-time Applications with WebSockets",
    content: "WebSockets enable real-time communication between clients and servers, making them perfect for chat applications, live dashboards, and collaborative tools. This article explores WebSocket implementation, connection management, error handling, and scaling strategies. Learn how to build responsive applications that provide instant feedback to users.",
    published_at: 2.days.ago
  },
  {
    title: "Machine Learning Fundamentals for Developers",
    content: "Machine learning is transforming how we build applications. This introduction covers key concepts like supervised and unsupervised learning, neural networks, and model evaluation. Practical examples show how to integrate ML into web applications using popular frameworks like TensorFlow and scikit-learn.",
    published_at: 1.day.ago
  },
  {
    title: "DevOps and Continuous Deployment",
    content: "Modern software development requires robust DevOps practices. This guide covers containerization with Docker, orchestration with Kubernetes, CI/CD pipelines, and infrastructure as code. Learn how to automate deployments, monitor applications, and maintain high availability in production environments.",
    published_at: 12.hours.ago
  },
  {
    title: "API Design and RESTful Services",
    content: "Well-designed APIs are essential for modern applications. This article covers REST principles, API versioning, authentication, rate limiting, and documentation best practices. Learn how to create APIs that are intuitive, secure, and scalable for both internal and external consumers.",
    published_at: 6.hours.ago
  },
  {
    title: "Frontend Performance Optimization",
    content: "Fast-loading web applications provide better user experiences and higher conversion rates. This comprehensive guide covers image optimization, code splitting, lazy loading, caching strategies, and performance monitoring. Learn techniques to make your web applications lightning fast.",
    published_at: 3.hours.ago
  },
  {
    title: "Security Best Practices for Web Applications",
    content: "Web application security is more important than ever. This article covers common vulnerabilities like SQL injection, XSS, CSRF, and authentication bypass. Learn defensive programming techniques, security testing methodologies, and how to implement secure coding practices in your applications.",
    published_at: 1.hour.ago
  },
  {
    title: "Microservices Architecture Patterns",
    content: "Microservices offer flexibility and scalability for large applications. This guide explores service decomposition strategies, inter-service communication, data consistency patterns, and deployment strategies. Learn how to design and implement microservices that are maintainable and performant.",
    published_at: 30.minutes.ago
  },
  {
    title: "Hello world how are you?",
    content: "This article demonstrates the pyramid problem in search analytics. When users type incrementally like 'Hello' → 'Hello world' → 'Hello world how are you?', a poorly designed system would record all three searches. Our search analytics platform intelligently filters out intermediate searches and only records the final meaningful search term.",
    published_at: 2.hours.ago
  },
  {
    title: "How is emil hajric doing",
    content: "This article shows an example of good search finalization. When users search incrementally like 'How is' → 'How is emil hajric' → 'How is emil hajric doing', our system only records the final complete search term. This prevents the pyramid problem and provides clean, meaningful analytics data.",
    published_at: 1.hour.ago
  },
  {
    title: "What is a good car",
    content: "This article demonstrates another example of proper search finalization. When users type 'What is' → 'What is a' → 'What is a good car', our search analytics algorithm intelligently removes the intermediate searches and only tracks the final meaningful search term. This ensures accurate analytics without data pollution.",
    published_at: 30.minutes.ago
  }
]

articles_data.each do |article_data|
  Article.create!(article_data)
end

puts "Created #{Article.count} articles"

# Create some article views to demonstrate the analytics
puts "Creating article views..."

# Generate unique user hashes for different users
user1_hash = Digest::SHA256.hexdigest("user1_ip_user1_session_secret")
user2_hash = Digest::SHA256.hexdigest("user2_ip_user2_session_secret")
user3_hash = Digest::SHA256.hexdigest("user3_ip_user3_session_secret")

# User 1 viewed some articles
ArticleView.create!(
  user_hash: user1_hash,
  article: Article.find_by(title: "Hello world how are you?"),
  count: 3,
  last_viewed_at: 1.hour.ago
)

ArticleView.create!(
  user_hash: user1_hash,
  article: Article.find_by(title: "Getting Started with Ruby on Rails"),
  count: 1,
  last_viewed_at: 30.minutes.ago
)

# User 2 viewed different articles
ArticleView.create!(
  user_hash: user2_hash,
  article: Article.find_by(title: "How is emil hajric doing"),
  count: 2,
  last_viewed_at: 45.minutes.ago
)

ArticleView.create!(
  user_hash: user2_hash,
  article: Article.find_by(title: "Database Design Best Practices"),
  count: 1,
  last_viewed_at: 15.minutes.ago
)

# User 3 viewed more articles
ArticleView.create!(
  user_hash: user3_hash,
  article: Article.find_by(title: "What is a good car"),
  count: 4,
  last_viewed_at: 20.minutes.ago
)

ArticleView.create!(
  user_hash: user3_hash,
  article: Article.find_by(title: "Machine Learning Fundamentals for Developers"),
  count: 2,
  last_viewed_at: 10.minutes.ago
)

puts "Created #{ArticleView.count} article views"
puts "Seed data completed!"
