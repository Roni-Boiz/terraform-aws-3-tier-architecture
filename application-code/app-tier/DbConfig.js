module.exports = Object.freeze({
    DB_HOST : process.env.DB_HOST || 'localhost', // Your database host
    DB_PORT : process.env.DB_PORT || '3306', // Your database port (3306 for MySQL)
    DB_USER : process.env.DB_USER || 'root', // Your database username
    DB_PWD : process.env.DB_PASSWORD || '', // Your database password
    DB_DATABASE : process.env.DB_NAME // Change to your database name
});