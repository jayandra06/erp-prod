# Maritime Admin Portal 🚢

A professional, modern admin portal for the Maritime Procurement ERP system built with Flutter.

## ✨ Features

### 🎨 **Professional UI/UX**
- **Dark Mode Support** - Seamlessly switch between light, dark, and system themes
- **Mobile Responsive** - Optimized for desktop, tablet, and mobile devices
- **Modern Design** - Clean, professional maritime-themed interface
- **Smooth Animations** - Engaging micro-interactions and transitions

### 📊 **Dashboard & Analytics**
- **Real-time Statistics** - User counts, revenue, orders, and system metrics
- **Interactive Charts** - Beautiful data visualizations with fl_chart
- **Activity Feed** - Recent system activities and notifications
- **Quick Actions** - Fast access to common admin tasks

### 👥 **User Management**
- **User Overview** - Comprehensive user statistics and management
- **Role-based Access** - Secure permission system
- **User Search & Filter** - Advanced filtering and search capabilities
- **Activity Tracking** - Monitor user activities and sessions

### 🏢 **Multi-tenant Management**
- **Tenant Overview** - Manage multiple organizations
- **Tenant Statistics** - Revenue, users, and usage metrics per tenant
- **Tenant Configuration** - Customize settings per organization
- **Isolation Management** - Ensure proper data separation

### ⚙️ **System Settings**
- **Theme Customization** - Light, dark, and system theme modes
- **Security Settings** - Two-factor authentication, session management
- **Notification Preferences** - Email, push, and SMS notifications
- **Integration Management** - API connections and external services
- **System Information** - Version, uptime, and health status

### 🔧 **Technical Features**
- **State Management** - Riverpod for reactive state management
- **Navigation** - Smooth navigation with proper routing
- **Form Validation** - Comprehensive input validation
- **Error Handling** - Graceful error handling and user feedback
- **Performance** - Optimized for smooth performance

## 🚀 Getting Started

### Prerequisites
- Flutter 3.10+
- Dart 3.0+
- VS Code or Android Studio

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd maritime-procurement-erp/apps/admin_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run -d chrome --web-port=8086
   ```

4. **Access the admin portal**
   - URL: `http://localhost:8086`
   - Demo credentials:
     - Email: `admin@maritime-procurement.com`
     - Password: `AdminPass123!`

## 📱 Supported Platforms

- **Web** - Progressive Web App (PWA)
- **Windows** - Desktop application
- **Linux** - Desktop application
- **Android** - Mobile application
- **macOS** - Desktop application (future)
- **iOS** - Mobile application (future)

## 🎯 Demo Credentials

```
Email: admin@maritime-procurement.com
Password: AdminPass123!
```

## 🏗️ Architecture

### Project Structure
```
lib/
├── constants/          # App constants and themes
├── services/           # Business logic and API services
├── screens/            # UI screens
│   ├── auth/          # Authentication screens
│   ├── dashboard/     # Dashboard and analytics
│   ├── users/         # User management
│   ├── tenants/       # Multi-tenant management
│   ├── settings/      # System settings
│   └── main/          # Main layout and navigation
├── widgets/            # Reusable UI components
│   ├── auth/          # Authentication widgets
│   ├── dashboard/     # Dashboard components
│   ├── layout/        # Layout components
│   └── common/        # Common widgets
└── main.dart          # Application entry point
```

### Key Dependencies
- **flutter_riverpod** - State management
- **google_fonts** - Typography
- **fl_chart** - Data visualization
- **material_symbols_icons** - Modern icons
- **data_table_2** - Advanced data tables
- **flutter_staggered_grid_view** - Grid layouts
- **shared_preferences** - Local storage

## 🎨 Design System

### Color Palette
- **Primary Blue**: Maritime-themed blue (#1E3A8A)
- **Secondary Blue**: Complementary blue (#3B82F6)
- **Success Green**: Positive actions (#10B981)
- **Warning Orange**: Caution states (#F59E0B)
- **Error Red**: Error states (#EF4444)
- **Info Cyan**: Information (#06B6D4)

### Typography
- **Font Family**: Poppins (Google Fonts)
- **Weights**: 400 (Regular), 500 (Medium), 600 (SemiBold), 700 (Bold)

### Spacing
- **Small**: 8px
- **Default**: 16px
- **Large**: 24px
- **Border Radius**: 12px

## 🔧 Development

### Running Tests
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze
```

### Building for Production
```bash
# Web
flutter build web

# Windows
flutter build windows

# Linux
flutter build linux
```

## 📊 Performance

- **Fast Loading** - Optimized bundle size and lazy loading
- **Smooth Animations** - 60fps animations with proper optimization
- **Memory Efficient** - Proper widget disposal and memory management
- **Responsive** - Adapts to different screen sizes seamlessly

## 🔒 Security

- **Theme Persistence** - Secure local storage for preferences
- **Input Validation** - Comprehensive form validation
- **Error Boundaries** - Graceful error handling
- **Secure Navigation** - Protected routes and authentication

## 🌟 Features Showcase

### Dashboard
- Real-time statistics with animated counters
- Interactive charts showing revenue and user growth
- Recent activity feed with live updates
- Quick action buttons for common tasks

### User Management
- Advanced data table with sorting and filtering
- User statistics cards with trend indicators
- Search functionality with real-time results
- Role-based access control visualization

### Multi-tenant Management
- Tenant overview with key metrics
- Revenue tracking per tenant
- User count and activity monitoring
- Tenant configuration management

### Settings
- Theme switching with smooth transitions
- Security settings with toggle switches
- Notification preferences
- Integration status monitoring
- System information display

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Support

For support and questions:
- Email: support@maritime-procurement.com
- Documentation: [Wiki](https://github.com/your-org/maritime-procurement-erp/wiki)
- Issues: [GitHub Issues](https://github.com/your-org/maritime-procurement-erp/issues)

---

Built with ❤️ for the maritime industry using Flutter
