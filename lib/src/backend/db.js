const mysql = require('mysql2');

const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '2541',
    database: 'deposit_fund',
    port: 3306
});

db.connect(err => {
    if (err) {
        console.error('ไม่สามารถเชื่อมต่อฐานข้อมูล:', err);
        return;
    }
    console.log('เชื่อมต่อ MySQL สำเร็จ');
});

module.exports = db;
