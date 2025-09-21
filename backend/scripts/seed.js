const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const User = require('../models/User');

// Sample users for testing
const sampleUsers = [
  {
    name: 'Admin User',
    username: 'admin',
    password: '1234',
    role: 'Admin',
    isActive: true
  },
  {
    name: 'John Supervisor',
    username: 'supervisor',
    password: '1234',
    role: 'Supervisor',
    isActive: true
  },
  {
    name: 'Jane Worker',
    username: 'user',
    password: '1234',
    role: 'User',
    isActive: true,
    assignedTask: 'Incoming Inspection',
    completedToday: 8,
    totalAssigned: 12
  },
  {
    name: 'Mike Johnson',
    username: 'mike.johnson',
    password: '1234',
    role: 'User',
    isActive: true,
    assignedTask: 'Quality Control',
    completedToday: 6,
    totalAssigned: 10
  },
  {
    name: 'Sarah Davis',
    username: 'sarah.davis',
    password: '1234',
    role: 'User',
    isActive: true,
    assignedTask: 'Finishing',
    completedToday: 5,
    totalAssigned: 8
  }
];

async function seedDatabase() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    // Clear existing users
    await User.deleteMany({});
    console.log('Cleared existing users');

    // Create sample users
    for (const userData of sampleUsers) {
      const hashedPassword = await bcrypt.hash(userData.password, 12);
      const user = new User({
        ...userData,
        password: hashedPassword
      });
      await user.save();
      console.log(`Created user: ${userData.name} (${userData.role})`);
    }

    console.log('Database seeded successfully!');
    console.log('\nSample login credentials:');
    console.log('Admin: admin / 1234');
    console.log('Supervisor: supervisor / 1234');
    console.log('User: user / 1234');
    
    process.exit(0);
  } catch (error) {
    console.error('Error seeding database:', error);
    process.exit(1);
  }
}

seedDatabase();