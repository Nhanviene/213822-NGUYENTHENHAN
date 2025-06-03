-- Tạo bảng DanhMuc
CREATE TABLE danhmuc (
    madm SERIAL PRIMARY KEY,
    tendm VARCHAR(255)
);

-- Tạo bảng NhaSanXuat
CREATE TABLE nhasanxuat (
    mansx SERIAL PRIMARY KEY,
    tennsx VARCHAR(255)
);

-- Tạo bảng hedeuhanh trước vì Sanpham tham chiếu đến nó
CREATE TABLE hedeuhanh (
    mahdh SERIAL PRIMARY KEY,
    tenhdh CHAR(255)
);

-- Tạo bảng vaitro trước vì taikhoan tham chiếu đến nó
CREATE TABLE vaitro (
    mavt SERIAL PRIMARY KEY,
    tenvt VARCHAR(255)
);

-- Tạo bảng taikhoan
CREATE TABLE taikhoan ( 
    adminid SERIAL PRIMARY KEY, 
    username VARCHAR(255) NOT NULL UNIQUE,  
    password BYTEA NOT NULL, 
    mavt INT NOT NULL DEFAULT 2,
    isverified BOOLEAN DEFAULT false,
    verificationtoken VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (mavt) REFERENCES vaitro(mavt)
);

-- Tạo bảng sanpham
CREATE TABLE sanpham (
    masp SERIAL PRIMARY KEY,
    tensp VARCHAR(255),
    mota VARCHAR(255),
    gia NUMERIC(18, 2),
    hinhanh TEXT,
    thesim INT,
    bonhotrong INT,
    ram INT,
    mansx INT,
    madm INT,
    mahdh INT,
    soluong INT,
    FOREIGN KEY (mansx) REFERENCES nhasanxuat(mansx),
    FOREIGN KEY (madm) REFERENCES danhmuc(madm),
    FOREIGN KEY (mahdh) REFERENCES hedeuhanh(mahdh)
);

-- Tạo bảng donhang
CREATE TABLE donhang (
    madh SERIAL PRIMARY KEY,
    ngaydat TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tongtien NUMERIC(18, 2) NOT NULL,
    trangthai INT NOT NULL DEFAULT 0, -- 0: Chờ xử lý, 1: Đã xác nhận, etc.
    thanhtoan INT NOT NULL DEFAULT 0, -- 0: Chưa thanh toán, 1: Đã thanh toán
    diachinhanhang VARCHAR(255) NOT NULL,
    adminid INT,
    tennguoinhan VARCHAR(255) NOT NULL,
    sdt VARCHAR(20) NOT NULL,
    pttt INT NOT NULL, -- Phương thức thanh toán
    FOREIGN KEY (adminid) REFERENCES taikhoan(adminid),
    FOREIGN KEY (pttt) REFERENCES paymentmethod(id)
);

-- Tạo bảng chitietdonhang
CREATE TABLE chitietdonhang (
    id SERIAL PRIMARY KEY,
    madh INT NOT NULL,
    masp INT NOT NULL,
    soluong INT NOT NULL CHECK (soluong > 0),
    gia NUMERIC(18, 2) NOT NULL,
    thanhtien NUMERIC(18, 2) NOT NULL GENERATED ALWAYS AS ((gia * (soluong)::numeric)) STORED,
    payment_method_id INT,
    CONSTRAINT chitietdonhang_madh_fkey FOREIGN KEY (madh)
        REFERENCES donhang(madh) ON DELETE CASCADE,
    CONSTRAINT chitietdonhang_masp_fkey FOREIGN KEY (masp)
        REFERENCES sanpham(masp),
    CONSTRAINT chitietdonhang_payment_method_id_fkey FOREIGN KEY (payment_method_id)
        REFERENCES paymentmethod(id)
);
CREATE TABLE paymentmethod (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Tạo bảng khohang
CREATE TABLE khohang (
    makho SERIAL PRIMARY KEY,
    tenkho VARCHAR(255) NOT NULL,
    diachi VARCHAR(255),
    sdt VARCHAR(20),
    soluong INT,
    mansx INT,
    FOREIGN KEY (mansx) REFERENCES nhasanxuat(mansx)
);

-- Tạo bảng nhanvien
CREATE TABLE nhanvien (
    manhanvien SERIAL PRIMARY KEY, 
    hoten VARCHAR(255) NOT NULL,             
    ngaysinh DATE NOT NULL,                   
    gioitinh VARCHAR(10) NOT NULL,           
    sodienthoai VARCHAR(15) NOT NULL,        
    diachi VARCHAR(255) NOT NULL,            
    adminid INT,                          
    FOREIGN KEY (adminid) REFERENCES taikhoan(adminid) 
);

-- Tạo bảng nhapxuatkho
CREATE TABLE nhapxuatkho (
    manxk SERIAL PRIMARY KEY, 
    masp INT NOT NULL, 
    ngaynhap DATE,  
    ngayxuat DATE, 
    soluong INT NOT NULL, 
    makho INT,
    mansx INT,  
    FOREIGN KEY (masp) REFERENCES sanpham(masp),
    FOREIGN KEY (makho) REFERENCES khohang(makho), 
    FOREIGN KEY (masp) REFERENCES Sanpham(masp),
    FOREIGN KEY (makho) REFERENCES KhoHang(makho), 
    FOREIGN KEY (mansx) REFERENCES NhaSanXuat(mansx)
);
CREATE TABLE giohang (
    magh SERIAL PRIMARY KEY,
    adminid INT NOT NULL,
    masp INT NOT NULL,
    soluong INT NOT NULL DEFAULT 1 CHECK (soluong > 0),
    ngaythem TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    gia NUMERIC(18,2) NOT NULL,
    thanhtien NUMERIC(18,2) GENERATED ALWAYS AS (soluong * gia) STORED,  -- Đổi thành chữ thường
    FOREIGN KEY (adminid) REFERENCES taikhoan(adminid) ON DELETE CASCADE,
    FOREIGN KEY (masp) REFERENCES sanpham(masp) ON DELETE CASCADE,
    CONSTRAINT unique_giohang_item UNIQUE (adminid, masp)
);
INSERT INTO vaitro (mavt, tenvt) VALUES
(1, 'Admin'),
(2, 'User'),
(3, 'Manager');
INSERT INTO danhmuc (tendm) VALUES 
('Điện thoại'),
('Phụ kiện');

INSERT INTO nhasanxuat (tennsx) VALUES 
('Apple'),
('Samsung'),
('Xiaomi'),
('Oppo');

-- Thêm dữ liệu mẫu cho bảng hedeuhanh
INSERT INTO hedeuhanh (tenhdh) VALUES 
('iOS'),
('Android'),
('HarmonyOS');

INSERT INTO khohang (tenkho, diachi, sdt, soluong, mansx) VALUES
('Kho Hà Nội', '123 Đường Láng, Hà Nội', '0987654321', 1000, 1),
('Kho TP.HCM', '456 Đường Nguyễn Văn Linh, TP.HCM', '0912345678', 1500, 2),
('Kho Đà Nẵng', '789 Đường Hải Phòng, Đà Nẵng', '0909123456', 800, 3),
('Kho Cần Thơ', '101 Đường 3/2, Cần Thơ', '0978123456', 700, 1),
('Kho Hải Phòng', '202 Đường Lê Lợi, Hải Phòng', '0967123456', 600, 2);

INSERT INTO nhapxuatkho (masp, ngaynhap, ngayxuat, soluong, makho, mansx) VALUES

(7, '2023-10-03', '2023-10-10', 50, 6, 2),  -- Nhập và xuất kho
(7, '2023-10-05', '2023-10-15', 80, 7, 2);  -- Nhập và xuất kho

INSERT INTO paymentmethod (id, name) VALUES
(1, 'Tiền mặt'),
(2, 'Chuyển khoản ngân hàng'),
(3, 'Ví điện tử'),
(4, 'Thẻ tín dụng');

-- Cập nhật vai trò Admin cho tài khoản ID 1
UPDATE taikhoan 
SET mavt = 1 
WHERE adminid = 1;