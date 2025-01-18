const express = require('express');
const bodyParser = require('body-parser');
const db = require('./db');

const app = express();
app.use(bodyParser.json());

const PORT = 3000;

// ฟังก์ชันตรวจสอบว่าผู้ใช้มีอยู่ในฐานข้อมูลหรือไม่
function checkUserExists(id_user, callback) {
    const query = 'SELECT * FROM users WHERE id_user = ?';
    db.query(query, [id_user], (err, results) => {
        if (err) {
            console.error('เกิดข้อผิดพลาดในการตรวจสอบ:', err);
            return callback(err, null);
        }
        callback(null, results);
    });
}

// ฟังก์ชันอัปเดตหมายเลขโทรศัพท์ในฐานข้อมูล
function updatePhoneNumber(id_user, phone_number, callback) {
    const query = 'UPDATE users SET phone_number = ? WHERE id_user = ?';
    db.query(query, [phone_number, id_user], (err, results) => {
        if (err) {
            console.error('เกิดข้อผิดพลาดในการบันทึกเบอร์โทร:', err);
            return callback(err, null);
        }
        callback(null, results);
    });
}

// Route สำหรับอัปเดตเบอร์โทรโดยใช้ PATCH
app.patch('/users/:id_user/phone', (req, res) => {
    const id_user = req.params.id_user;
    const { phone_number } = req.body;

    // ตรวจสอบว่ามีเบอร์โทรที่ต้องการอัปเดตหรือไม่
    if (!phone_number) {
        return res.status(400).json({ message: 'กรุณาใส่เบอร์โทรที่ต้องการอัปเดต' });
    }

    // ตรวจสอบว่าผู้ใช้มีอยู่หรือไม่
    checkUserExists(id_user, (err, results) => {
        if (err) {
            return res.status(500).json({ message: 'เกิดข้อผิดพลาดในการตรวจสอบ' });
        }

        if (results.length > 0) {
            // อัปเดตเบอร์โทรศัพท์
            updatePhoneNumber(id_user, phone_number, (updateErr, updateResult) => {
                if (updateErr) {
                    return res.status(500).json({ message: 'เกิดข้อผิดพลาดในการบันทึกเบอร์โทร' });
                }

                return res.status(200).json({ message: 'อัปเดตเบอร์โทรสำเร็จ' });
            });
        } else {
            return res.status(404).json({ message: 'ไม่พบ id_user' });
        }
    });
});

// Route สำหรับการ Login
app.post('/login', (req, res) => {
    const { id_user, phone_number, otp } = req.body;

    if (!id_user || !phone_number || !otp) {
        return res.status(400).json({ message: 'กรุณาใส่ข้อมูลให้ครบถ้วน' });
    }

    checkUserExists(id_user, (err, results) => {
        if (err) {
            return res.status(500).json({ message: 'เกิดข้อผิดพลาดในการตรวจสอบ' });
        }

        if (results.length > 0) {
            const user = results[0];

            if (otp !== '123456') {
                return res.status(401).json({ message: 'OTP ไม่ถูกต้อง' });
            }

            if (user.phone_number) {
                return res.status(200).json({ message: 'Login สำเร็จ (เบอร์โทรมีอยู่แล้ว)' });
            }

            updatePhoneNumber(id_user, phone_number, (updateErr, updateResult) => {
                if (updateErr) {
                    return res.status(500).json({ message: 'เกิดข้อผิดพลาดในการบันทึกเบอร์โทร' });
                }

                return res.status(200).json({ message: 'Login สำเร็จ และบันทึกเบอร์โทรแล้ว' });
            });
        } else {
            return res.status(404).json({ message: 'ไม่พบ id_user' });
        }
    });
});

app.get('/users/:id_user', (req, res) => {
    const id_user = req.params.id_user;
    const query = 'SELECT * FROM users WHERE id_user = ?';
    db.query(query, [id_user], (err, results) => {
        if (err) {
            return res.status(500).json({ message: 'เกิดข้อผิดพลาดในการตรวจสอบ' });
        }
        if (results.length > 0) {
            return res.status(200).json({ message: 'พบผู้ใช้' });
        } else {
            return res.status(404).json({ message: 'ไม่พบผู้ใช้' });
        }
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
