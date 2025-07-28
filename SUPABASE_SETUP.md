# OilMate - Supabase Setup Guide

This guide will help you set up Supabase for the OilMate Flutter application.

## Prerequisites

- A Supabase account (sign up at [supabase.com](https://supabase.com))
- Basic understanding of SQL

## Setup Steps

### 1. Create a New Supabase Project

1. Go to [Supabase Dashboard](https://app.supabase.com)
2. Click "New Project"
3. Choose your organization
4. Enter project details:
   - **Name**: OilMate
   - **Database Password**: Generate a strong password
   - **Region**: Choose the closest region to your users

### 2. Get Project Credentials

After project creation:

1. Go to **Settings** → **API**
2. Copy the following values:
   - **Project URL** (looks like: `https://your-project-id.supabase.co`)
   - **anon public key** (starts with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`)

### 3. Update Flutter Configuration

1. Open `lib/config/supabase_config.dart`
2. Replace the placeholder values:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://your-project-id.supabase.co';
  static const String supabaseAnonKey = 'your-anon-public-key-here';
  
  // ... rest of the file remains the same
}
```

### 4. Set Up Database Schema

1. Go to **SQL Editor** in your Supabase dashboard
2. Copy the entire content from `database/schema.sql`
3. Paste it into the SQL Editor
4. Click **Run** to execute the schema

### 5. Seed Data (Optional)

1. After creating the schema, you can add sample data
2. Copy the content from `database/seed_data.sql`
3. Paste it into the SQL Editor
4. Click **Run** to insert sample data

### 6. Configure Authentication

The app uses Supabase Auth for user management:

1. Go to **Authentication** → **Settings**
2. Configure these settings:
   - **Site URL**: Your app's URL (for development: `http://localhost:3000`)
   - **Redirect URLs**: Add your app's redirect URLs
   - **Email Templates**: Customize if needed

#### Enable Email Authentication
- Email confirmation is enabled by default
- Users will receive confirmation emails

#### Social Providers (Optional)
You can enable social login providers like Google, Apple, etc. in the Auth settings.

### 7. Row Level Security (RLS)

The schema includes RLS policies for data security:
- Users can only access their own data
- Vehicle information is publicly readable (for VIN lookups)
- Maintenance records are private to each user

### 8. Environment Variables (Production)

For production deployments, use environment variables:

```dart
class SupabaseConfig {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://your-project-id.supabase.co',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'your-anon-key',
  );
}
```

## Database Tables Overview

- **user_profiles**: User account information
- **vehicles**: Vehicle master data (VIN, make, model, etc.)
- **user_vehicles**: User's owned vehicles with custom settings
- **engine_specifications**: Detailed engine information
- **oil_specifications**: Oil recommendations per vehicle
- **maintenance_records**: Service history tracking
- **notifications**: Maintenance reminders and alerts
- **car_models**: Reference data for car models
- **oil_products**: Commercial oil products catalog
- **service_centers**: Service center locations

## Testing the Setup

1. Run the Flutter app: `flutter run`
2. Try creating a new user account
3. Check if the user appears in the **Authentication** tab
4. Verify the user profile is created in the **Database** → **user_profiles** table

## Troubleshooting

### Common Issues:

1. **Connection Error**: Check URL and API key
2. **RLS Policies**: Ensure policies are enabled for user data access
3. **Email Confirmation**: Check spam folder for confirmation emails
4. **Schema Errors**: Ensure all tables are created successfully

### Support Resources:

- [Supabase Documentation](https://supabase.com/docs)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)
- [Supabase Discord Community](https://discord.supabase.com)

## Security Notes

- Never commit your actual API keys to version control
- Use environment variables for production
- Regularly rotate your service keys
- Monitor usage in the Supabase dashboard
- Set up proper RLS policies for all tables

## Production Checklist

- [ ] Database schema deployed
- [ ] RLS policies configured
- [ ] API keys secured
- [ ] Email templates customized
- [ ] Backup strategy in place
- [ ] Monitoring configured
- [ ] Performance optimizations applied

---

For more advanced configuration and features, refer to the [Supabase Documentation](https://supabase.com/docs).