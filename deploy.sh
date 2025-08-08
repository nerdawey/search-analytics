#!/bin/bash

# 🚀 Search Analytics Deployment Script
# This script helps you deploy your Rails app to Render

echo "🚀 Starting deployment process..."

# Check if git is initialized
if [ ! -d ".git" ]; then
    echo "📁 Initializing git repository..."
    git init
fi

# Add all files
echo "📦 Adding files to git..."
git add .

# Commit changes
echo "💾 Committing changes..."
git commit -m "Deploy: Search Analytics app $(date)"

# Check if remote exists
if ! git remote get-url origin > /dev/null 2>&1; then
    echo "⚠️  No remote repository configured!"
    echo "📝 Please create a GitHub repository and run:"
    echo "   git remote add origin https://github.com/YOUR_USERNAME/search-analytics.git"
    echo "   git push -u origin main"
    echo ""
    echo "🔗 Then deploy on Render: https://render.com"
    exit 1
fi

# Push to GitHub
echo "⬆️  Pushing to GitHub..."
git push origin main

echo ""
echo "✅ Code pushed to GitHub successfully!"
echo ""
echo "🎯 Next steps:"
echo "1. Go to https://render.com"
echo "2. Click 'New +' → 'Blueprint'"
echo "3. Connect your GitHub repository"
echo "4. Select 'search-analytics' repository"
echo "5. Click 'Apply' to deploy"
echo ""
echo "🔧 After deployment:"
echo "- Add RAILS_MASTER_KEY environment variable"
echo "- Run: bundle exec rails db:migrate"
echo "- Run: bundle exec rails db:seed"
echo ""
echo "🌐 Your app will be available at: https://your-app-name.onrender.com"
