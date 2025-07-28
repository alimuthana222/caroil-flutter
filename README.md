# OilMate - Complete Car Oil Management System

A comprehensive Flutter application for managing car maintenance with real-time oil recommendations, VIN lookup, and Supabase database integration.

## 🌟 Features

### 🔐 User Authentication
- Complete user registration and login system
- Profile management with customizable settings
- Secure Supabase authentication with Row Level Security

### 🚗 Vehicle Management
- **Multi-vehicle garage** - Manage multiple cars
- **VIN lookup integration** - Automatic vehicle data retrieval
- **Vehicle customization** - Nicknames, colors, license plates
- **Mileage tracking** - Current odometer readings

### 🛠️ Maintenance Tracking
- **Service history** - Complete maintenance records
- **Smart reminders** - Automated maintenance notifications
- **Cost tracking** - Multi-currency support (SAR, USD, EUR, AED, CNY)
- **Service scheduling** - Plan upcoming maintenance

### 🛢️ Oil Recommendations
- **Precise specifications** - Oil capacity with/without filter
- **Filter details** - OEM part numbers and torque specs
- **Multi-brand options** - Primary and alternative recommendations
- **Regional support** - USA, Middle East, China, Europe, Asia

### 📱 Modern UI/UX
- **Arabic-first design** - RTL language support
- **Tabbed navigation** - Intuitive bottom navigation
- **Dark/Light themes** - System preference support
- **Responsive design** - Works on phones and tablets

### 🌍 Regional Support
- **Global coverage** - Vehicles from multiple regions
- **Local specifications** - Region-specific oil recommendations
- **Multi-currency** - Localized pricing and costs
- **Multi-language** - Arabic and English support

## 🏗️ Technical Architecture

### Database Schema
- **10 comprehensive tables** with real car data
- **Row Level Security (RLS)** for data protection
- **Optimized indexing** for fast queries
- **JSONB support** for flexible data storage

### Flutter Stack
- **Latest Flutter 3.x** with Material Design 3
- **Supabase integration** for backend services
- **JSON serialization** for type-safe data models
- **State management** with built-in solutions

### Dependencies
```yaml
dependencies:
  supabase_flutter: ^2.5.6      # Backend integration
  json_annotation: ^4.9.0       # Model serialization
  equatable: ^2.0.5             # Value equality
  uuid: ^4.4.0                  # Unique identifiers
  shared_preferences: ^2.2.3    # Local storage
  cached_network_image: ^3.3.1  # Image caching
  intl: ^0.19.0                 # Internationalization
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK 3.8.1 or higher
- Supabase account

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/alimuthana222/caroil-flutter.git
   cd caroil-flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Supabase**
   - Follow the detailed guide in [`SUPABASE_SETUP.md`](SUPABASE_SETUP.md)
   - Update `lib/config/supabase_config.dart` with your credentials

4. **Generate code**
   ```bash
   flutter packages pub run build_runner build
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## 📋 Supabase Setup

The app requires a Supabase backend for full functionality. See [`SUPABASE_SETUP.md`](SUPABASE_SETUP.md) for detailed setup instructions.

### Quick Setup:
1. Create a Supabase project
2. Run the SQL schema from `database/schema.sql`
3. Optionally add seed data from `database/seed_data.sql`
4. Update the config file with your project URL and API key

## 📱 App Structure

```
lib/
├── config/
│   └── supabase_config.dart          # Supabase configuration
├── models/                           # Data models
│   ├── user_model.dart              # User profile model
│   ├── user_vehicle.dart            # User vehicle model
│   ├── notification_model.dart      # Notification model
│   ├── vehicle_model.dart           # Vehicle data model
│   ├── engine_specification.dart    # Engine specs model
│   ├── oil_specification.dart       # Oil recommendation model
│   └── maintenance_record.dart      # Maintenance record model
├── services/                        # Business logic
│   ├── auth_service.dart           # Authentication service
│   ├── car_database_service.dart   # Vehicle data service
│   └── vin_service.dart            # VIN lookup service
├── screens/                         # UI screens
│   ├── login_screen.dart           # Authentication screen
│   ├── main_app_screen.dart        # Main navigation
│   ├── dashboard_screen.dart       # Home dashboard
│   ├── garage_screen.dart          # Vehicle management
│   ├── splash_screen.dart          # VIN search screen
│   ├── maintenance_screen.dart     # Maintenance tracking
│   ├── oil_products_screen.dart    # Oil catalog
│   ├── settings_screen.dart        # App settings
│   └── ...                        # Additional screens
└── main.dart                       # App entry point

database/
├── schema.sql                      # Complete database schema
└── seed_data.sql                  # Sample data for testing
```

## 🔧 Key Features Implementation

### Authentication Flow
- **Automatic auth state management** with StreamBuilder
- **Persistent sessions** across app restarts
- **Profile creation** on first registration
- **Password reset** functionality

### Vehicle Management
- **VIN decoding** via NHTSA API with caching
- **Multi-vehicle support** per user account
- **Custom vehicle settings** with JSONB storage
- **Primary vehicle** designation

### Maintenance System
- **Smart notifications** based on mileage/time
- **Cost tracking** in multiple currencies
- **Service history** with detailed records
- **Reminder management** system

### Data Security
- **Row Level Security** policies for user data
- **Encrypted connections** to Supabase
- **API key protection** with environment variables
- **Input validation** and sanitization

## 🎨 UI/UX Design

### Design Principles
- **Arabic-first** interface with RTL support
- **Material Design 3** components and theming
- **Consistent spacing** and typography
- **Accessibility** considerations

### Color Scheme
- **Primary**: Blue 700 (#1976D2)
- **Secondary**: Blue 500 (#2196F3)
- **Surface**: White/Grey 50
- **Error**: Red 500

### Typography
- **Headers**: Bold, 18-24px
- **Body**: Regular, 14-16px
- **Captions**: Light, 12px
- **Font**: System fonts with Arabic support

## 🧪 Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Database Tests
Test your Supabase setup with the included test queries in the schema file.

## 📦 Building for Production

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🔒 Security Considerations

- **Environment Variables**: Use for production API keys
- **RLS Policies**: Ensure proper data access control
- **Input Validation**: Sanitize all user inputs
- **API Rate Limiting**: Monitor Supabase usage
- **Regular Updates**: Keep dependencies current

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: Check the setup guides
- **Issues**: Report bugs via GitHub Issues
- **Discussions**: Use GitHub Discussions for questions
- **Email**: Contact the maintainers

## 🚀 Roadmap

### Phase 1 (Current)
- [x] Complete authentication system
- [x] Vehicle management with VIN lookup
- [x] Basic maintenance tracking
- [x] Oil recommendations engine

### Phase 2 (Next)
- [ ] Advanced analytics and insights
- [ ] Service center integration
- [ ] Parts ordering system
- [ ] Social features and communities

### Phase 3 (Future)
- [ ] IoT integration for automatic data
- [ ] Machine learning recommendations
- [ ] Fleet management features
- [ ] Multi-platform sync

## 🏆 Acknowledgments

- **Supabase** for the excellent backend platform
- **Flutter Team** for the amazing framework
- **NHTSA** for vehicle data API
- **Community** for feedback and contributions

---

**OilMate** - Your complete car maintenance companion 🚗✨