const jwt = require('jsonwebtoken');

/**
 * =====================================================
 * Auth Middleware
 * -----------------------------------------------------
 * - Reads token from `x-auth-token` header
 * - Verifies JWT token
 * - Attaches user id & token to request
 * =====================================================
 */
const auth = async (req, res, next) => {
    try {
        const token = req.header('x-auth-token');

        // Check token existence
        if (!token) {
            return res.status(401).json({
                message: 'No auth token, access denied',
            });
        }

        // Verify token
        const verified = jwt.verify(token, 'passwordKey');
        if (!verified) {
            return res.status(401).json({
                message: 'Token verification failed, auth denied',
            });
        }

        // Attach data to request
        req.user = verified.id;
        req.token = token;

        next();
    } catch (e) {
        return res.status(500).json({
            message: e.message,
        });
    }
};

module.exports = auth;
