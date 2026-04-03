const express = require('express');
const bcryptjs = require('bcryptjs');
const jwt = require('jsonwebtoken');

const User = require('../models/user');
const auth = require('../middleware/auth');

const authRouter = express.Router();

/**
 * =====================================================
 * @route   POST /api/signup
 * @desc    Register a new user
 * @access  Public
 * =====================================================
 */
authRouter.post('/api/signup', async (req, res) => {
    try {
        const { name, email, password } = req.body;

        // Check if user already exists
        const existingUser = await User.findOne({ email });
        if (existingUser) {
            return res.status(400).json({
                message: 'User with same email already exists!',
            });
        }

        // Hash password
        const hashedPassword = await bcryptjs.hash(password, 8);

        // Create & save user
        let user = new User({
            name,
            email,
            password: hashedPassword,
        });

        user = await user.save();

        return res.json(user);
    } catch (e) {
        return res.status(500).json({
            message: e.message,
        });
    }
});

/**
 * =====================================================
 * @route   POST /api/login
 * @desc    Login user & return JWT token
 * @access  Public
 * =====================================================
 */
authRouter.post('/api/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        // Check if user exists
        const existingUser = await User.findOne({ email });
        if (!existingUser) {
            return res.status(400).json({
                message: "User with this email don't exist!",
            });
        }

        // Compare password
        const isMatch = await bcryptjs.compare(
            password,
            existingUser.password
        );

        if (!isMatch) {
            return res.status(400).json({
                message: 'Password wrong please try again',
            });
        }

        // Generate JWT token
        const token = jwt.sign(
            { id: existingUser._id },
            'passwordKey'
        );

        return res.json({
            token,
            ...existingUser._doc,
        });
    } catch (e) {
        return res.status(500).json({
            message: e.message,
        });
    }
});

/**
 * =====================================================
 * @route   POST /isTokenValid
 * @desc    Validate JWT token
 * @access  Public
 * =====================================================
 */
authRouter.post('/api/isTokenValid', async (req, res) => {
    try {
        const token = req.header('x-auth-token');

        if (!token) return res.json(false);

        const verified = jwt.verify(token, 'passwordKey');
        if (!verified) return res.json(false);

        const user = await User.findById(verified.id);
        if (!user) return res.json(false);

        return res.json(true);
    } catch (e) {
        return res.status(500).json({
            message: e.message,
        });
    }
});

/**
 * =====================================================
 * @route   GET /
 * @desc    Get logged-in user data
 * @access  Private
 * =====================================================
 */
authRouter.get('/api/', auth, async (req, res) => {
    try {
        // Correct: get user id from req.user (set by auth middleware)
        const user = await User.findById(req.user);

        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        return res.json({
            ...user._doc,
            token: req.token,
        });
    } catch (e) {
        return res.status(500).json({ message: e.message });
    }
});


module.exports = authRouter;
