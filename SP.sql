--1p: Tính tổng khách hàng trong một ngày cụ thể
CREATE PROC tong_khachhang @NgayDat date
AS
BEGIN
	DECLARE @TongSo int
	SELECT @TongSo = (SELECT COUNT(MaKH) FROM DONHANG WHERE NgayDat = @NgayDat)
	PRINT @TongSo
END
GO

--2p: Kiểm tra tên tài khoản và mật khẩu đăng nhập
CREATE PROC KiemTra_TK (@TenTk char(5), @MatKhau nvarchar(50))
AS
	BEGIN
	IF (EXISTS (SELECT * FROM HETHONG WHERE TenTk = @TenTk AND MatKhau = @MatKhau))
	PRINT N'Thông tin đăng nhập đúng'
	ELSE PRINT N'Thông tin đăng nhập sai'
END
GO

--3p: Kiểm tra xem chức vụ của nhân viên đó có phải là đầu bếp không
CREATE PROC ChucVu (@MaNV char(5))
AS
BEGIN
	IF (EXISTS (SELECT * FROM NHANVIEN WHERE ChucVu = N'Đầu bếp' AND MaNV = @MaNV))
	PRINT N'Là đầu bếp'
	ELSE IF (NOT EXISTS(SELECT * FROM NHANVIEN WHERE MaNV = @MaNV))
	PRINT N'Không tồn tại mã nhân viên'
	ELSE PRINT N'Không phải là đầu bếp'
END
GO

--4p Kiểm tra xem một nhân viên có trong danh sách đăng nhập không với mã nhân viên cho trước
CREATE PROC kiemtra_thongtin (@MaNV char(5))
AS
BEGIN
	IF(EXISTS (SELECT * FROM HETHONG WHERE MaNV = @MaNV))
	PRINT N'Tồn tại người dùng'
	ELSE PRINT N'Không tồn tại người dùng'
END
GO

--5p Hiển thị địa chỉ của một nhân viên cho trước
CREATE PROC Diachi_NV (@MaNV char(5))
AS
BEGIN
	IF(EXISTS (SELECT * FROM NHANVIEN WHERE MaNV = @MaNV))
	BEGIN
		DECLARE @DiaChi nvarchar(255)
		SELECT @DiaChi = (SELECT DiaChi FROM NHANVIEN WHERE MaNV = @MaNV)
		PRINT @DiaChi
	END
	ELSE PRINT N'Không tồn tại nhân viên'
END
GO

--6p Tính lương của một nhân viên với mã nhân viên và tháng cho trước
ALTER PROC LuongNV (@MaNV char(5), @Thang date)
AS
	BEGIN
	IF (NOT EXISTS (SELECT Thang FROM CTLUONG WHERE @Thang = Thang))
		BEGIN
		PRINT N'Không tồn tại tháng'
		END
	ELSE IF(EXISTS (SELECT MaNV FROM NHANVIEN WHERE MaNV = @MaNV AND ChucVu = N'Đầu bếp'))
		BEGIN
		DECLARE @Luong1 money
		SELECT @Luong1 = (SELECT (CaThuong * 120000 + CaLe * 240000 + Thuong - Phat)
				AS Luong
		FROM CTLUONG
		WHERE MaNV = @MaNV AND Thang = @Thang
		GROUP BY MaNV, Thang, CaThuong, CaLe, Thuong, Phat)
		PRINT @Luong1
		END
	ELSE IF (EXISTS (SELECT MaNV FROM NHANVIEN WHERE MaNV = @MaNV AND ChucVu = N'NV phục vụ'))
		BEGIN
		DECLARE @Luong2 money
		SELECT @Luong2 = (SELECT (CaThuong * 90000 + CaLe * 180000 + Thuong - Phat)
				AS Luong
		FROM CTLUONG
		WHERE MaNV = @MaNV AND Thang = @Thang
		GROUP BY MaNV, Thang, CaThuong, CaLe, Thuong, Phat)
		PRINT @Luong2
		END
	ELSE IF (EXISTS (SELECT MaNV FROM NHANVIEN WHERE MaNV = @MaNV AND ChucVu = N'Quản lý'))
		BEGIN
		PRINT N'Là quản lý'
		END
	ELSE
		BEGIN
		PRINT N'Không tồn tại mã nhân viên'
		END
	END
GO

--7p Doanh thu của quán trong một ngày cho trước
ALTER PROC DoanhThu (@NgayDat date)
AS
BEGIN
	BEGIN
		DECLARE @DT money
		SELECT b.MaDH, SUM(SoLuong * Gia)*(1 - Giam / 100) AS TongHoaDon INTO #table1
			FROM DOAN a, DONHANG b, CTDONHANG c
			WHERE b.MaDH = c.MaDH AND c.MaDoAn = a. MaDoAn
			GROUP BY b.MaDH, Giam
		SELECT NgayDat, SUM(TongHoaDon) as doanhthu INTO #table2
			FROM #table1, DONHANG
			GROUP BY NgayDat
			HAVING NgayDat = @NgayDat
		SELECT @DT = (SELECT doanhthu FROM #table2)
		PRINT @DT
		END
	END
GO

--8p Hiển thị số mặt hàng nhập vào ngày 1/5/2021 bởi một nhân viên cho trước
ALTER PROC SoLuong_Nhap @MaNV char(5)
AS
BEGIN
	DECLARE @Tong int
	SELECT @Tong = (SELECT COUNT(MaMatHang) FROM CTNHAP a, PHIEUNHAP b
	WHERE a.SoPhieu = b.SoPhieu AND NgayNhap = '2021/5/1' AND MaNV = @MaNV)
	PRINT @Tong
END
GO

--9p Kiểm tra nhà cung cấp có cung cấp một mặt hàng cho trước hay không
CREATE PROC CungCap @MaNhaCc char(4), @MaMH char(4)
AS
BEGIN
	IF(EXISTS (SELECT * FROM CTCUNGCAP WHERE MaNhaCc = @MaNhaCc AND MaMatHang = @MaMH))
	PRINT N'Có cung cấp'
	ELSE PRINT N'Không cung cấp'
END
GO

--10p Tìm số điện thoại của một khách hàng cho trước
CREATE PROC Tim_Sdt (@MaKH char(4))
AS
BEGIN
	DECLARE @SDT nvarchar(20)
	SELECT @SDT = (SELECT Sdt FROM KHACHHANG WHERE MaKH = @MaKH)
	PRINT @SDT
END
GO
--11p Hiển thị tên nhà cung cấp và giá của sản phẩm người đó cung cấp
alter PROC GiaSanPham
AS
BEGIN
	 SELECT HoTen, c.MaMatHang, m.Ten, Gia
	 FROM NHACC n inner join CTCUNGCAP c ON c.MaNhaCc = n.MaNhaCc inner join MATHANG m on m.MaMatHang = c.MaMatHang
 END
 GO
 --12p Hiện thị chi tiết danh sách đặt hàng của khách hàng có điểm tích luỹ cao nhất
ALter PROC DonHang_KH_VIP
AS
BEGIN
	DECLARE @Tong MONEY, @MaDH char(4)
	SET @MaDH = (SELECT MaDH FROM KHACHHANG k INNER JOIN DONHANG d ON k.MaKH = d.MaKH
				WHERE Diem = (SELECT MAX(Diem) FROM KHACHHANG))
	SET @Tong = dbo.QLQuanAn2.TongHoaDon(@MaDH)
	SELECT k.MaKH, MaDH, @Tong = [dbo].[TongHoaDon](MaDH)
		FROM KHACHHANG k INNER JOIN DONHANG d ON k.MaKH = d.MaKH
		WHERE Diem = (SELECT MAX(Diem) FROM KHACHHANG)
END
GO


 EXEC GiaSanPham 
 exec DonHang_KH_VIP
