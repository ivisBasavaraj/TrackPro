# TrackPro Manufacturing Operations Management System

Complete setup guide for the TrackPro system with Node.js backend and Flutter frontend.

## System Overview

TrackPro is a comprehensive manufacturing operations management system that includes:

- **User Management**: Role-based access (Admin, Supervisor, User)
- **Incoming Inspection**: Component inspection with camera and timing
- **Finishing Operations**: Tool monitoring and process tracking
- **Quality Control**: Automated tolerance checking with measurements
- **Delivery Management**: Complete delivery tracking with proof
- **Dashboard Analytics**: Real-time statistics and reporting

## Backend Setup (Node.js + Express + MongoDB)

### Prerequisites
- Node.js (v16 or higher)
- MongoDB (v5.0 or higher)
- npm or yarn

### Installation Steps

1. **Navigate to backend directory:**
```bash
cd "d:\Knowvia\PRC Application\backend"
```

2. **Install dependencies:**
```bash
npm install
```

3. **Set up environment variables:**
```bash
# Copy and edit .env file
cp .env .env.local
# Edit .env with your MongoDB connection string
```

4. **Start MongoDB service:**
```bash
# Windows (if MongoDB is installed as service)
net start MongoDB

# Or start manually
mongod --dbpath "C:\data\db"
```

5. **Seed the database with sample data:**
```bash
node scripts/seed.js
```

6. **Start the backend server:**
```bash
# Development mode
npm run dev

# Production mode
npm start
```

The backend will be available at `http://localhost:3000`

### Sample Login Credentials
- **Admin**: username: `admin`, password: `1234`
- **Supervisor**: username: `supervisor`, password: `1234`
- **User**: username: `user`, password: `1234`

## Frontend Setup (Flutter)

### Prerequisites
- Flutter SDK (v3.0 or higher)
- Android Studio / VS Code
- Android SDK / iOS SDK (for mobile development)

### Installation Steps

1. **Navigate to Flutter project directory:**
```bash
cd "d:\Knowvia\PRC Application\trackpro"
```

2. **Install Flutter dependencies:**
```bash
flutter pub get
```

3. **Update API base URL (if needed):**
Edit `lib/services/api_service.dart` and update the `baseUrl` if your backend is running on a different address:
```dart
static const String baseUrl = 'http://your-backend-url:3000/api';
```

4. **Run the Flutter app:**
```bash
# For development
flutter run

# For specific platform
flutter run -d chrome  # Web
flutter run -d android # Android
flutter run -d ios     # iOS
```

## API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/register` - Register new user (Admin only)

### Users Management
- `GET /api/users` - Get all users (Admin only)
- `PUT /api/users/:id/assign-task` - Assign task to user
- `PUT /api/users/:id/unassign-task` - Unassign task from user

### Operations
- `POST /api/inspections` - Create inspection record
- `POST /api/finishing` - Create finishing record
- `POST /api/quality` - Create quality control record
- `POST /api/delivery` - Create delivery record

### Dashboard & Reports
- `GET /api/dashboard/admin` - Admin dashboard data
- `GET /api/dashboard/supervisor` - Supervisor dashboard data
- `GET /api/dashboard/user` - User dashboard data
- `GET /api/dashboard/reports/:type` - Generate reports

## Features Mapping

### Frontend to Backend Integration

1. **Login Screen** → `/api/auth/login`
2. **Admin Dashboard** → `/api/dashboard/admin`
3. **Supervisor Dashboard** → `/api/dashboard/supervisor`
4. **User Dashboard** → `/api/dashboard/user`
5. **Manage Users** → `/api/users/*`
6. **Incoming Inspection** → `/api/inspections`
7. **Finishing Operations** → `/api/finishing`
8. **Quality Control** → `/api/quality`
9. **Delivery Management** → `/api/delivery`
10. **Assign Users** → `/api/users/:id/assign-task`

## Database Schema

### Collections
- **users**: User accounts and roles
- **inspections**: Incoming inspection records
- **finishings**: Finishing operation records
- **qualitycontrols**: QC measurements and results
- **deliveries**: Delivery tracking records

## Security Features

- JWT token authentication
- Role-based access control
- Input validation and sanitization
- File upload restrictions
- Rate limiting
- Security headers (Helmet)

## File Uploads

The system supports image uploads for:
- Inspection photos (with timestamp watermark)
- QC inspector signatures
- Delivery proof images

Files are stored in `/backend/uploads/` directory.

## Development Workflow

1. **Backend Development:**
   - Make changes to backend code
   - Server auto-restarts with nodemon
   - Test API endpoints with Postman/Thunder Client

2. **Frontend Development:**
   - Make changes to Flutter code
   - Hot reload available during development
   - Test on emulator/device

3. **Database Changes:**
   - Update models in `/backend/models/`
   - Run seed script to reset test data
   - Update API endpoints accordingly

## Production Deployment

### Backend Deployment
1. Set production environment variables
2. Use PM2 or similar process manager
3. Set up reverse proxy (nginx)
4. Configure SSL certificates
5. Set up MongoDB Atlas or production database

### Frontend Deployment
1. Build for production: `flutter build web/apk/ios`
2. Deploy web version to hosting service
3. Publish mobile apps to app stores

## Troubleshooting

### Common Issues

1. **MongoDB Connection Error:**
   - Ensure MongoDB service is running
   - Check connection string in .env file

2. **Flutter Dependencies Error:**
   - Run `flutter clean && flutter pub get`
   - Check Flutter SDK version

3. **API Connection Error:**
   - Verify backend server is running
   - Check API base URL in Flutter app
   - Ensure CORS is properly configured

4. **Image Upload Issues:**
   - Check file permissions on uploads directory
   - Verify multer configuration
   - Check file size limits

### Logs and Debugging

- Backend logs: Check console output
- Flutter logs: Use `flutter logs`
- Database logs: Check MongoDB logs
- Network requests: Use browser dev tools or Flutter inspector

## Support

For technical support or questions about the system, refer to:
- Backend API documentation in `/backend/README.md`
- Flutter app documentation
- MongoDB documentation
- Express.js documentation