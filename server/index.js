const express = require('express');
const mongoose = require('mongoose');
const authRouter = require('./routes/auth');

// ======================================
// App Configuration
// ======================================
const app = express();
const PORT = process.env.PORT || 3000;

// ======================================
// Middleware
// ======================================
app.use(express.json());        // Parse JSON requests
app.use(authRouter);            // Auth routes

// ======================================
// MongoDB Connection
// ======================================
const MONGO_URI =
    'mongodb+srv://uername:password@cluster0.ryixdjc.mongodb.net/?appName=Cluster0';

mongoose
    .connect(MONGO_URI)
    .then(() => {
        console.log('✅ MongoDB connected');
    })
    .catch((error) => {
        console.error('❌ MongoDB connection failed');
        console.error(error);
    });

// ======================================
// Server Listener
// ======================================
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Server running on port ${PORT}`);
});
