# 🚀 Deployment Guide - Search Analytics App

## 📋 **Prerequisites**
- GitHub account
- Render account (free at [render.com](https://render.com))

## 🎯 **Recommended: Deploy to Render (Free)**

### **Step 1: Push to GitHub**
```bash
# Initialize git if not already done
git init
git add .
git commit -m "Initial commit: Search Analytics app"

# Create a new repository on GitHub, then:
git remote add origin https://github.com/YOUR_USERNAME/search-analytics.git
git push -u origin main
```

### **Step 2: Deploy on Render**

1. **Go to [render.com](https://render.com)** and sign up/login
2. **Click "New +"** → **"Blueprint"**
3. **Connect your GitHub repository**
4. **Select your repository** (`search-analytics`)
5. **Render will automatically detect** the `render.yaml` file
6. **Click "Apply"** to deploy

### **Step 3: Configure Environment Variables**

After deployment, go to your web service and add:
- `RAILS_MASTER_KEY`: Copy from `config/master.key` file

### **Step 4: Run Database Migrations**

In Render dashboard:
1. Go to your **web service**
2. Click **"Shell"** tab
3. Run: `bundle exec rails db:migrate`
4. Run: `bundle exec rails db:seed`

## 🔧 **Alternative: Railway Deployment**

### **Step 1: Deploy to Railway**
1. Go to [railway.app](https://railway.app)
2. Connect GitHub repository
3. Add PostgreSQL and Redis services
4. Deploy automatically

### **Step 2: Configure Environment**
- Set `RAILS_ENV=production`
- Add `RAILS_MASTER_KEY`
- Railway will auto-set `DATABASE_URL` and `REDIS_URL`

## 🌐 **Your App URLs**

After deployment, you'll get:
- **Main App**: `https://your-app-name.onrender.com`
- **Analytics**: `https://your-app-name.onrender.com/analytics`

## 📊 **What's Included in Free Tier**

### **Render Free Tier:**
- ✅ **Web Service**: 750 hours/month
- ✅ **Worker Service**: 750 hours/month  
- ✅ **PostgreSQL**: 90 days free
- ✅ **Redis**: 90 days free
- ✅ **Custom domains** with SSL
- ✅ **Automatic deployments**

### **Railway Free Tier:**
- ✅ **$5 credit monthly**
- ✅ **PostgreSQL included**
- ✅ **Redis included**
- ✅ **Good performance**

## 🔍 **Testing Your Deployment**

1. **Visit your app URL**
2. **Test search functionality**:
   - Type "hello" → should find articles
   - Check real-time search works
3. **Visit analytics page**:
   - `/analytics` → should show dashboard
4. **Test article views**:
   - Click on articles → should track views

## 🛠 **Troubleshooting**

### **Common Issues:**

**1. Database Connection Error:**
```bash
# In Render shell:
bundle exec rails db:create
bundle exec rails db:migrate
```

**2. Redis Connection Error:**
- Check `REDIS_URL` environment variable
- Ensure Redis service is running

**3. Master Key Error:**
- Copy the exact content from `config/master.key`
- Set as `RAILS_MASTER_KEY` environment variable

**4. Sidekiq Not Working:**
- Check worker service is running
- Verify Redis connection

## 📈 **Monitoring**

### **Render Dashboard:**
- **Logs**: Real-time application logs
- **Metrics**: CPU, memory usage
- **Deployments**: Automatic from GitHub

### **Health Checks:**
- App responds at root URL
- Analytics page loads
- Search functionality works

## 🔒 **Security Notes**

- ✅ **HTTPS enabled** by default
- ✅ **Environment variables** for secrets
- ✅ **Database credentials** auto-managed
- ✅ **No hardcoded secrets** in code

## 💰 **Cost After Free Tier**

### **Render:**
- **PostgreSQL**: $7/month (after 90 days)
- **Redis**: $7/month (after 90 days)
- **Web/Worker**: Still free (750 hours/month)

### **Railway:**
- **$5 credit monthly** (usually sufficient for small apps)

---

## 🎉 **You're Ready to Deploy!**

Your app is fully configured for production deployment. The `render.yaml` file will automatically set up:
- Web service with Rails
- Worker service with Sidekiq
- PostgreSQL database
- Redis cache
- All environment variables

Just push to GitHub and deploy on Render! 🚀
