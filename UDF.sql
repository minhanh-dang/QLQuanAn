--1f Hiển thị danh sách khách hàng đã mua hàng trong một ngày bất kỳ\\
CREATE FUNCTION NgayMuaHang (@Ngay date)
RETURNS TABLE
AS
	RETURN (SELECT MaKH FROM DONHANG WHERE NgayDat = @Ngay)
GO

--2f Danh sách nhân viên có tuổi lớn hơn 18
CREATE FUNCTION TuoiNV ()
RETURNS TABLE AS
RETURN (SELECT MaNV, HoTen, YEAR(CURRENT_TIMESTAMP) - YEAR(NgaySinh) AS N'Tuổi'
FROM NHANVIEN
WHERE YEAR(CURRENT_TIMESTAMP) - YEAR(NgaySinh) > 18)
GO

--3f In ra danh sách sản phẩm với số lượng nhập vào là 30
CREATE FUNCTION SLuong_Nhap ()
RETURNS TABLE
AS
	RETURN (SELECT a.MaMatHang, Ten
	FROM MATHANG a, CTNHAP b
	WHERE a.MaMatHang = b.MaMatHang AND SoLuong = 30)
GO

--4f In ra sản phẩm đặt từ nhà cung cấp trong một ngày cho trước
CREATE FUNCTION SanPham (@Ngay date)
RETURNS TABLE
AS
	RETURN (SELECT MaMatHang FROM DONDH a, CTCUNGCAP b WHERE a.MaNhaCc = b.MaNhaCc AND NgayDat = @Ngay)
GO

--5f In ra danh sách khách hàng được nhân viên NV002 phục vụ vào ngày cho trước
CREATE FUNCTION PhucVu (@Ngay date)
RETURNS TABLE
AS
	RETURN (SELECT MaKH FROM DONHANG WHERE MaNV = 'NV002' AND NgayDat = @Ngay)
GO

--6f In ra danh sách 5 mặt hàng có giá nhập cao nhất
CREATE FUNCTION GiaCaoNhat ()
RETURNS TABLE
AS
	RETURN (SELECT TOP 5 MaNhaCc, MaMatHang FROM CTCUNGCAP ORDER BY Gia DESC)
GO

--7f Liệt kê 3 đồ ăn có lượng bán cao nhất
CREATE FUNCTION LuongBanCao ()
RETURNS TABLE
AS
	RETURN (SELECT TOP 3 a.MaDoAn, Ten, COUNT(SoLuong) AS SLuong
	FROM DOAN a, CTDONHANG b
	WHERE a.MaDoAn = b.MaDoAn
	GROUP BY a.MaDoAn, Ten
	ORDER BY SLuong DESC)
GO

-- 8f In ra danh sách khách hàng đặt trước trong ngày 1/5/2021
CREATE FUNCTION DatTruoc()
RETURNS TABLE
AS
	RETURN (SELECT MaKH FROM DATBAN WHERE Ngay = '2021/5/1')
GO

--9f In ra sản phẩm không còn trong kho
CREATE FUNCTION KiemKho()
RETURNS TABLE
AS
	RETURN (SELECT MaMatHang, Ten FROM MATHANG WHERE TongSLuong = 0)
GO

--10f In ra danh sách 10 món ăn có giá bán cao nhất
CREATE FUNCTION GiaCao()
RETURNS TABLE AS
RETURN (SELECT TOP 10 MaDoAn, Ten FROM DOAN ORDER BY Gia DESC)
GO

--11f In ra thâm niên làm việc của một nhân viên bất kỳ
CREATE FUNCTION ThamNien (@MaNV char(5))
RETURNS INT
AS
BEGIN
	IF EXISTS (SELECT MaNV FROM NHANVIEN WHERE MaNV = @MaNV)
	BEGIN
		DECLARE @SoThang INT, @NgayVaoLam DATE
		SET @NgayVaoLam = (SELECT NgayVaoLam FROM NHANVIEN WHERE MaNV = @MaNV)
		SET @SoThang = DATEDIFF(MONTH, @NgayVaoLam, GETDATE())
	END
	RETURN @SoThang
END
GO

--12f In ra tổng tiền hoá đơn cho trước
ALTER FUNCTION TongHoaDon (@MaDH char(4))
RETURNS MONEY
AS
BEGIN
	IF EXISTS (SELECT MaDH FROM DONHANG WHERE MaDH = @MaDH)
	BEGIN
	DECLARE @TongHoaDon MONEY
	SET @TongHoaDon = (SELECT SUM(SoLuong * Gia)*(1 - Giam / 100) AS TongHoaDon
						FROM DOAN a, DONHANG b, CTDONHANG c
						WHERE b.MaDH = c.MaDH AND c.MaDoAn = a. MaDoAn
						GROUP BY b.MaDH, Giam)
	END
	RETURN @TongHoaDon
END
GO