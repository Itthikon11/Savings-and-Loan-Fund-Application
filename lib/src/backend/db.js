const mysql = require('mysql2');

const db = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: '2541',
    database: 'deposit_fund',
    port: 3306,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

db.getConnection((err, connection) => {
    if (err) {
        console.error('ไม่สามารถเชื่อมต่อฐานข้อมูล:', err.code);
        console.error(err.message);
    } else {
        console.log('เชื่อมต่อ MySQL สำเร็จ!');
        connection.release();
    }
});

module.exports = db;
