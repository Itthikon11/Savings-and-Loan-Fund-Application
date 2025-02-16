const express = require('express');
const bodyParser = require('body-parser');
const db = require('./db');

const app = express();
app.use(express.json());
app.use(bodyParser.json());

app.patch('/users/:id_user/phone', (req, res) => {
    const id_user = req.params.id_user;
    const { phone_number } = req.body;

    if (!phone_number) {
        return res.status(400).json({ message: "กรุณาใส่เบอร์โทรที่ต้องการอัปเดต" });
    }

    const phoneRegex = /^0[689]\d{8}$/;
    if(!phoneRegex.test(phone_number)){
        return res.status(400).json({message : "รูปแบบเบอร์โทรไม่ถูกต้อง"});
    }

    const queryCheck = 'SELECT phone_number FROM users WHERE id_user = ?';
    db.query(queryCheck, [id_user], (err, results) => {
        if (err) {
            return res.status(500).json({ message: "เกิดข้อผิดพลาดในการตรวจสอบ" });
        }

        if (results.length === 0) {
            return res.status(404).json({ message: "ไม่พบผู้ใช้งาน" });
        }
    });
});

app.post('/login', (req, res) => {
    const { id_user, phone_number, otp } = req.body;

    if (!id_user || !phone_number || !otp) {
        return res.status(400).json({ message: "กรุณาใส่ข้อมูลให้ครบถ้วน" });
    }

    const phoneRegex = /^\d{10}$/;
    if (!phoneRegex.test(phone_number)) {
        return res.status(400).json({ message: "กรุณาใส่เบอร์โทรให้ครบ 10 หลัก" });
    }

    // ตรวจสอบว่าผู้ใช้มีอยู่ในระบบหรือไม่
    const checkUserQuery = "SELECT id_user, phone_number FROM users WHERE id_user = ?";
    db.query(checkUserQuery, [id_user], (err, results) => {
        if (err) {
            return res.status(500).json({ message: "เกิดข้อผิดพลาดในการตรวจสอบผู้ใช้" });
        }
        if (results.length === 0) {
            return res.status(404).json({ message: "ไม่พบผู้ใช้งาน" });
        }

        const user = results[0];

        if (otp !== '123456') {
            return res.status(401).json({ message: "OTP ไม่ถูกต้อง" });
        }

        // ตรวจสอบว่าหมายเลขโทรศัพท์ที่ใช้ Login ตรงกับที่บันทึกไว้หรือไม่
        if (user.phone_number) {
            if (user.phone_number !== phone_number) {
                return res.status(400).json({ message: "เบอร์โทรไม่ตรงกับที่ลงทะเบียนไว้" });
            }
            return res.status(200).json({ message: "Login สำเร็จ" });
        }

        // กรณีที่บัญชียังไม่มีเบอร์โทร ตรวจสอบว่าเบอร์นี้มีการใช้งานโดยบัญชีอื่นหรือไม่
        const checkPhoneQuery = "SELECT id_user FROM users WHERE phone_number = ?";
        db.query(checkPhoneQuery, [phone_number], (phoneErr, phoneResults) => {
            if (phoneErr) {
                return res.status(500).json({ message: "เกิดข้อผิดพลาดในการตรวจสอบเบอร์โทร" });
            }

            if (phoneResults.length > 0) {
                return res.status(400).json({ message: "เบอร์โทรนี้ถูกใช้งานแล้ว" });
            }

            // อัปเดตเบอร์โทรสำหรับบัญชีที่ยังไม่มีเบอร์โทรเท่านั้น
            const updateQuery = "UPDATE users SET phone_number = ? WHERE id_user = ?";
            db.query(updateQuery, [phone_number, id_user], (updateErr) => {
                if (updateErr) {
                    return res.status(500).json({ message: "เกิดข้อผิดพลาดในการบันทึกเบอร์โทร" });
                }
                return res.status(200).json({ message: "Login สำเร็จ และบันทึกเบอร์โทรแล้ว" });
            });
        });
    });
});

app.get('/users/:id_user', (req, res) => {
    const id_user = req.params.id_user;
    const query = 'SELECT * FROM users WHERE id_user = ?';
    db.query(query, [id_user], (err, results) => {
        if (err) {
            return res.status(500).json({ message: "เกิดข้อผิดพลาดในการตรวจสอบ" });
        }
        if (results.length > 0) {
            return res.status(200).json({ message: "พบผู้ใช้งาน" });
        } else {
            return res.status(404).json({ message: "ไม่พบผู้ใช้งาน" });
        }
    });
});

// **API: ตรวจสอบว่า User มี PIN หรือไม่**
app.get('/get_pin/:idUser', (req, res) => {
  const { idUser } = req.params;
  const sql = "SELECT pin_user FROM pin_users WHERE id_user = ?";

  db.query(sql, [idUser], (err, result) => {
    if (err) {
      console.error({ message: "เกิดข้อผิดพลาดในการเรียก PIN: ", err });
      return res.status(500).json({ message: "ข้อผิดพลาดของฐานข้อมูล" });
    }
    if (result.length > 0) {
      res.json(result[0]);
    } else {
      res.status(404).json({ message: "ผู้ใช้งานไม่มี PIN" });
    }
  });
});

// **API: บันทึก PIN ใหม่**
app.post('/save_pin', (req, res) => {
  const { id_user, pin_user } = req.body;

  if (!id_user || !pin_user) {
    return res.status(400).json({ message: "ไม่มีช่องที่ต้องกรอก" });
  }

  const sql = "INSERT INTO pin_users (id_user, pin_user) VALUES (?, ?) ON DUPLICATE KEY UPDATE pin_user = VALUES(pin_user)";

  db.query(sql, [id_user, pin_user], (err, result) => {
    if (err) {
      console.error({ message: "เกิดข้อผิดพลาดในการบันทึก PIN: ", err });
      return res.status(500).json({ message: "ข้อผิดพลาดของฐานข้อมูล" });
    }
    res.json({ message: "บันทึก PIN เรียบร้อยแล้ว" });
  });
});

// **API: ตรวจสอบ PIN**
app.post('/verify_pin', (req, res) => {
  const { id_user, pin_user } = req.body;

  const sql = "SELECT pin_user FROM pin_users WHERE id_user = ?";
  db.query(sql, [id_user], (err, result) => {
    if (err) {
      console.error({ message: "เกิดข้อผิดพลาดในการตรวจสอบ PIN: ", err });
      return res.status(500).json({ message: "ข้อผิดพลาดของฐานข้อมูล" });
    }
    if (result.length > 0 && result[0].pin_user === pin_user) {
      res.json({ success: true, message: "PIN ถูกต้อง" });
    } else {
      res.status(401).json({ success: false, message: "รหัส PIN ไม่ถูกต้อง" });
    }
  });
});

app.post('/reset_pin', (req, res) => {
    const { id_user, pin_user } = req.body;

    if (!id_user || !pin_user) {
        return res.status(400).json({ error: "กรุณากรอกข้อมูลให้ครบถ้วน" });
    }

    db.query("SELECT * FROM pin_users WHERE id_user = ?", [id_user], (err, results) => {
        if (err) {
            console.error("ข้อผิดพลาดของฐานข้อมูล:", err);
            return res.status(500).json({ error: "เกิดข้อผิดพลาดระหว่างตรวจสอบข้อมูล" });
        }

        if (results.length === 0) {
            return res.status(404).json({ error: "ไม่พบผู้ใช้งาน" });
        }

        db.query("UPDATE pin_users SET pin_user = ? WHERE id_user = ?", [pin_user, id_user], (err, updateResult) => {
            if (err) {
                console.error("ข้อผิดพลาดของฐานข้อมูล:", err);
                return res.status(500).json({ error: "เกิดข้อผิดพลาดระหว่างอัปเดต PIN" });
            }

            if (updateResult.affectedRows > 0) {
                res.status(200).json({ message: "อัปเดต PIN สำเร็จแล้ว" });
            } else {
                res.status(500).json({ error: "อัปเดต PIN ไม่สำเร็จ" });
            }
        });
    });
});

app.post('/check_phone', (req, res) => {
    const { phone_number, otp } = req.body;

    if (!phone_number) {
        return res.status(400).json({ error: "กรุณากรอกเบอร์โทรศัพท์" });
    }

    const phoneRegex = /^[0-9]{10}$/;
    if (!phoneRegex.test(phone_number)) {
        return res.status(400).json({ error: "รูปแบบเบอร์โทรศัพท์ไม่ถูกต้อง" });
    }

    if (!otp || otp !== '123456') {
        return res.status(401).json({ message: "OTP ไม่ถูกต้อง" });
    }456

    db.query("SELECT id_user FROM users WHERE phone_number = ?", [phone_number], (err, results) => {
        if (err) {
            console.error("ข้อผิดพลาดของฐานข้อมูล:", err);
            return res.status(500).json({ error: "เกิดข้อผิดพลาดในการตรวจสอบเบอร์โทร" });
        }

        if (results.length === 0) {
            console.log("ไม่พบเบอร์โทรศัพท์ในระบบ");
            return res.status(404).json({ error: "ไม่พบเบอร์โทรศัพท์ในระบบ" });
        }

        res.status(200).json({ id_user: results[0].id_user });
    });
});

app.get("/deposit/:id_user", (req, res) => {
  const { id_user } = req.params;

  if (!id_user) {
    return res.status(400).json({ error: "กรุณาระบุรหัสผู้ใช้" });
  }

  const sqlUser = `
    SELECT u.id_user, u.first_name, u.last_name, d.date_deposit, d.Deposit_amount
    FROM users u
    LEFT JOIN deposit d ON u.id_user = d.id_user
    WHERE u.id_user = ?
    ORDER BY d.date_deposit DESC
    LIMIT 1
  `;

  const sqlDepositAmount = `
    SELECT id_DepositAm, amount_Deposit
    FROM Deposit_Amount
    WHERE id_user = ?
    ORDER BY id_DepositAm DESC
  `;

  db.query(sqlUser, [id_user], (err, userResult) => {
    if (err) {
      console.error("Database error (user query):", err);
      return res.status(500).json({ error: "ข้อผิดพลาดของฐานข้อมูล" });
    }

    if (userResult.length === 0) {
      return res.json({
        id_user,
        first_name: null,
        last_name: null,
        date_deposit: null,
        deposit_amount: null,
        deposits: [],
      });
    }

    let userData = {
      id_user: userResult[0].id_user,
      first_name: userResult[0].first_name,
      last_name: userResult[0].last_name,
      date_deposit: userResult[0].date_deposit || null,
      deposit_amount: userResult[0].Deposit_amount ? parseFloat(userResult[0].Deposit_amount) : null,
      deposits: [],
    };

    db.query(sqlDepositAmount, [id_user], (err, depositResult) => {
      if (err) {
        console.error("Database error (deposit amount query):", err);
        return res.status(500).json({ error: "ข้อผิดพลาดของฐานข้อมูล" });
      }

      userData.deposits = depositResult.map((row) => ({
        id_DepositAm: row.id_DepositAm,
        amount_Deposit: parseFloat(row.amount_Deposit),
      }));

      res.json(userData);
    });
  });
});


app.post('/deposit/DepositMonth', (req, res) => {
    const { idDepositAm } = req.body;

        if (!idDepositAm) {
            return res.status(400).json({ error: 'กรุณาส่ง idDepositAm มาใน body' });
        }

        const sql = `SELECT Deposit_month FROM Deposit_Amount WHERE id_DepositAm = ?`;
        db.query(sql, [idDepositAm], (err, result) => {
            if (err) {
                console.error("SQL Error:", err);
                return res.status(500).json({ error: 'เกิดข้อผิดพลาดภายในเซิร์ฟเวอร์', details: err.message });
            }
            if (result.length === 0) {
                return res.status(404).json({ message: 'ไม่พบข้อมูล' });
            }
            res.json(result[0]);
        });
});

app.post('/deposit', (req, res) => {
    const { id_user, deposit_month } = req.body;

    if (!id_user || !deposit_month || !Array.isArray(deposit_month)) {
        return res.status(400).json({ error: 'Invalid input data' });
    }

    const totalAmount = deposit_month.reduce((sum, item) => sum + item.amount, 0);

    const sql = `INSERT INTO deposit_amount (id_user, date_deposit, Deposit_month, amount_Deposit) VALUES (?, NOW(), ?, ?)`;
    db.query(sql, [id_user, JSON.stringify(deposit_month), totalAmount], (err, result) => {
        if (err) {
            console.error(err);
            return res.status(500).json({ error: 'Database error' });
        }
        res.status(201).json({ message: 'Deposit saved successfully', depositId: result.insertId });
    });
});

app.get('/getslips', (req, res) => {
    let sql = `
        SELECT
            s.id_slip,
            u.first_name,
            u.last_name,
            DATE(s.date) AS slip_date,
            TIME(s.date) AS slip_time,
            s.id_status
        FROM slip_deposit s
        LEFT JOIN users u ON s.id_user = u.id_user
        ORDER BY s.date DESC
    `;

    console.log("📡 Fetching all slips...");

    db.query(sql, (err, results) => {
        if (err) {
            console.error("❌ Error fetching slip data:", err);
            return res.status(500).json({ error: err.message });
        }
        console.log("✅ Query Success! Total Slips:", results.length);
        res.json(results);
    });
});

app.get('/searchslips', (req, res) => {
    const { search } = req.query;

    if (!search) {
        return res.status(400).json({ error: "กรุณาระบุคำค้นหา (search)" });
    }

    let sql = `
        SELECT
            s.id_slip,
            u.first_name,
            u.last_name,
            DATE(s.date) AS slip_date,
            TIME(s.date) AS slip_time,
            s.id_status
        FROM slip_deposit s
        LEFT JOIN users u ON s.id_user = u.id_user
        WHERE u.first_name LIKE ? OR u.last_name LIKE ?
        ORDER BY s.date DESC
    `;

    let params = [`%${search}%`, `%${search}%`];

    console.log("🔍 Searching for:", search);

    db.query(sql, params, (err, results) => {
        if (err) {
            console.error("❌ Error searching slip data:", err);
            return res.status(500).json({ error: err.message });
        }
        console.log("✅ Search Success! Found:", results.length);
        res.json(results);
    });
});

app.get('/getslipdetails', (req, res) => {
    const { id_slip } = req.query;

    if (!id_slip) {
        return res.status(400).json({ error: "id_slip is required" });
    }

    let sql = `
        SELECT
            s.id_slip,
            s.date,
            s.image_slip,
            s.slip_number,
            s.amount_slip,
            s.data_slip,
            s.id_status,
            u.first_name,
            u.last_name
        FROM slip_deposit s
        LEFT JOIN users u ON s.id_user = u.id_user
        WHERE s.id_slip = ?
    `;

    db.query(sql, [id_slip], (err, results) => {
        if (err) {
            console.error("Error fetching slip details:", err);
            return res.status(500).json({ error: err.message });
        }

        if (results.length === 0) {
            return res.status(404).json({ error: "Slip not found" });
        }

        res.json(results[0]);
    });
});

app.put("/updateSlipStatus/:id_slip", (req, res) => {
  const { id_slip } = req.params;
  const { id_status } = req.body;

  const checkStatusSql = "SELECT * FROM status WHERE id_status = ?";
  db.query(checkStatusSql, [id_status], (err, result) => {
    if (err) {
      res.status(500).json({ error: "Database error", details: err });
      return;
    }
    if (result.length === 0) {
      res.status(400).json({ message: "ไม่พบสถานะที่ระบุ" });
      return;
    }

    const updateSql = "UPDATE slip_deposit SET id_status = ? WHERE id_slip = ?";
    db.query(updateSql, [id_status, id_slip], (err, updateResult) => {
      if (err) {
        res.status(500).json({ error: "Database error", details: err });
        return;
      }

      res.json({
        message: "อัปเดตสถานะสำเร็จ",
        id_slip: id_slip,
        new_status: id_status,
      });
    });
  });
});

app.get("/Profile/users/:id", (req, res) => {
  const userId = req.params.id;
  const sql = `
    SELECT
      u.id_user,
      p.preName AS pre_name,
      u.first_name,
      u.last_name,
      u.address,
      u.phone_number,
      u.role,
      pu.pin_user
    FROM users u
    LEFT JOIN pre_name p ON u.pre_name = p.id_preName
    LEFT JOIN pin_users pu ON u.id_user = pu.id_user
    WHERE u.id_user = ?`;

  db.query(sql, [userId], (err, result) => {
    if (err) {
      res.status(500).json({ error: "ข้อผิดพลาดของฐานข้อมูล", details: err });
      return;
    }
    if (result.length === 0) {
      res.status(404).json({ message: "ไม่พบผู้ใช้" });
      return;
    }

    res.json({
      message: "พบผู้ใช้งาน",
      data: result[0]
    });
  });
});

app.get("/loanRequests/:id_user", (req, res) => {
  const userId = req.params.id_user;
  const sql = `
    SELECT
      lr.id_loanReq,
      lr.loan_amount,
      u.id_user,
      u.first_name,
      u.last_name,
      u.address
    FROM loan_requests lr
    LEFT JOIN users u ON lr.id_user = u.id_user
    WHERE lr.id_user = ?`;

  db.query(sql, [userId], (err, result) => {
    if (err) {
      res.status(500).json({ error: "Database error", details: err });
      return;
    }
    if (result.length === 0) {
      res.status(404).json({ message: "ไม่พบข้อมูลการกู้เงิน" });
      return;
    }
    res.json(result);
  });
});

const PORT = 3001;
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on http://localhost:${PORT}`);
});
