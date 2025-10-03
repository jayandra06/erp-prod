# Maritime Procurement ERP

A comprehensive SaaS maritime procurement ERP system built with Node.js, Express, MongoDB, and Flutter.

## 🚢 Overview

Maritime Procurement ERP is a multi-tenant SaaS platform designed specifically for maritime companies to manage their procurement processes, from RFQ creation to quote management and order fulfillment.

## 🏗️ Architecture

### Backend
- **Node.js + Express.js** - RESTful API server
- **MongoDB Atlas** - Primary database with multi-tenant support
- **JWT + HttpOnly Cookies** - Secure authentication with SSO
- **Casbin** - Role-Based Access Control (RBAC) with multi-tenant support
- **Docker** - Containerized deployment
- **Swagger** - API documentation

### Frontend
- **Flutter** - Cross-platform mobile and web applications
- **BLoC + Riverpod** - Hybrid state management
- **GoRouter** - Navigation and routing
- **Shared UI Package** - Reusable components and themes

### Multi-Portal Architecture
- **Technical Portal** - System administration and user management
- **Admin Portal** - Tenant management and system configuration
- **Customer Portal** - RFQ creation and order management
- **Vendor Portal** - Quote submission and order fulfillment

## 🚀 Quick Start

### Prerequisites
- Node.js 18+
- Flutter 3.10+
- MongoDB Atlas account
- Docker (optional)

### Backend Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd maritime-procurement-erp
   ```

2. **Install dependencies**
   ```bash
   cd backend
   npm install
   ```

3. **Environment configuration**
   ```bash
   cp env.example .env
   # Edit .env with your MongoDB Atlas connection string and other settings
   ```

4. **Start the backend**
   ```bash
   npm run dev
   ```

   The API will be available at `http://localhost:5000`
   API documentation: `http://localhost:5000/api-docs`

### Frontend Setup

1. **Install Flutter dependencies**
   ```bash
   cd apps/tech_app
   flutter pub get
   ```

2. **Run the technical portal**
   ```bash
   flutter run -d chrome --web-port=8085
   ```

3. **Access the application**
   - Technical Portal: `http://localhost:8085`
   - Demo credentials: `technical@maritime-procurement.com` / `TempPassword123!`

## 📁 Project Structure

```
maritime-procurement-erp/
├── backend/                 # Node.js API server
│   ├── src/
│   │   ├── config/         # Database, logging, RBAC configuration
│   │   ├── controllers/    # API route handlers
│   │   ├── middleware/     # Authentication, RBAC, error handling
│   │   ├── models/         # MongoDB schemas
│   │   ├── routes/         # API routes
│   │   └── services/       # Business logic
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── package.json
├── packages/
│   └── shared_ui/          # Shared Flutter components
├── apps/
│   ├── tech_app/           # Technical Portal
│   ├── admin_app/          # Admin Portal
│   ├── customer_app/       # Customer Portal
│   └── vendor_app/         # Vendor Portal
├── .github/
│   └── workflows/          # CI/CD pipelines
└── README.md
```

## 🔐 Authentication & Authorization

### Multi-Tenant RBAC
- **Platform Roles**: Platform admin, tenant admin
- **User Roles**: Technical, customer, vendor
- **Tenant Isolation**: Complete data separation between tenants
- **Permission System**: Granular permissions for each resource

### Security Features
- JWT tokens with refresh mechanism
- HttpOnly cookies for web security
- Rate limiting and CORS protection
- Input validation and sanitization
- Helmet.js security headers

## 🐳 Docker Deployment

### Development
```bash
cd backend
docker-compose up -d
```

### Production
```bash
cd backend
docker-compose -f docker-compose.prod.yml up -d
```

## 🧪 Testing

### Backend Tests
```bash
cd backend
npm test
npm run test:coverage
```

### Frontend Tests
```bash
cd apps/tech_app
flutter test
flutter test --coverage
```

## 📊 Monitoring & Logging

- **Winston** - Structured logging with daily rotation
- **Health Checks** - System health monitoring
- **Jira Integration** - Automatic issue creation for errors
- **Performance Metrics** - Response time and error rate tracking

## 🔄 CI/CD Pipeline

The project includes a comprehensive GitHub Actions workflow:

- **Backend Testing** - Unit tests, linting, coverage
- **Frontend Testing** - Flutter tests, analysis, builds
- **Security Scanning** - Trivy vulnerability scanning
- **Docker Build** - Multi-platform container builds
- **Deployment** - Automated staging and production deployment

## 🌐 API Documentation

Interactive API documentation is available at:
- Development: `http://localhost:5000/api-docs`
- Production: `https://api.maritime-procurement.com/api-docs`

## 📱 Mobile & Web Support

All Flutter applications support:
- **Web** - Progressive Web App (PWA)
- **Windows** - Desktop application
- **Android** - Mobile application
- **iOS** - Mobile application (future)

## 🚢 Maritime-Specific Features

- **Vessel Management** - Support for different vessel types
- **Port Integration** - Port and route management
- **Weather Integration** - Weather data for route planning
- **Compliance Tracking** - Maritime regulation compliance
- **Fuel Optimization** - Fuel consumption tracking
- **Maintenance Scheduling** - Vessel maintenance management

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For support and questions:
- Email: support@maritime-procurement.com
- Documentation: [Wiki](https://github.com/your-org/maritime-procurement-erp/wiki)
- Issues: [GitHub Issues](https://github.com/your-org/maritime-procurement-erp/issues)

## 🗺️ Roadmap

- [ ] Advanced analytics and reporting
- [ ] Mobile app for iOS
- [ ] Real-time notifications
- [ ] Advanced workflow automation
- [ ] Third-party integrations (ERP systems)
- [ ] Machine learning for demand forecasting
- [ ] Blockchain integration for supply chain transparency

---

Built with ❤️ for the maritime industry
# erp-prod
