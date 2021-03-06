USE [master]
GO
/****** Object:  Database [QLQuanAn2]    Script Date: 6/30/2021 1:46:02 PM ******/
CREATE DATABASE [QLQuanAn2]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'QLQuanAn2', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\QLQuanAn2.mdf' , SIZE = 29696KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'QLQuanAn2_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL11.MSSQLSERVER\MSSQL\DATA\QLQuanAn2_log.ldf' , SIZE = 2304KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [QLQuanAn2] SET COMPATIBILITY_LEVEL = 110
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [QLQuanAn2].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [QLQuanAn2] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [QLQuanAn2] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [QLQuanAn2] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [QLQuanAn2] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [QLQuanAn2] SET ARITHABORT OFF 
GO
ALTER DATABASE [QLQuanAn2] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [QLQuanAn2] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [QLQuanAn2] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [QLQuanAn2] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [QLQuanAn2] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [QLQuanAn2] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [QLQuanAn2] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [QLQuanAn2] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [QLQuanAn2] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [QLQuanAn2] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [QLQuanAn2] SET  DISABLE_BROKER 
GO
ALTER DATABASE [QLQuanAn2] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [QLQuanAn2] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [QLQuanAn2] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [QLQuanAn2] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [QLQuanAn2] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [QLQuanAn2] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [QLQuanAn2] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [QLQuanAn2] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [QLQuanAn2] SET  MULTI_USER 
GO
ALTER DATABASE [QLQuanAn2] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [QLQuanAn2] SET DB_CHAINING OFF 
GO
ALTER DATABASE [QLQuanAn2] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [QLQuanAn2] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [QLQuanAn2]
GO
/****** Object:  StoredProcedure [dbo].[ChucVu]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--3p: Kiểm tra xem chức vụ của nhân viên đó có phải là đầu bếp không
CREATE PROC [dbo].[ChucVu] (@MaNV char(5))
AS
BEGIN
IF (EXISTS (SELECT * FROM NHANVIEN WHERE ChucVu = N'Đầu bếp' AND MaNV = @MaNV))
PRINT N'Là đầu bếp'
ELSE IF (NOT EXISTS(SELECT * FROM NHANVIEN WHERE MaNV = @MaNV))
PRINT N'Không tồn tại mã nhân viên'
ELSE PRINT N'Không phải là đầu bếp'
END

GO
/****** Object:  StoredProcedure [dbo].[CungCap]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--9p Kiểm tra nhà cung cấp có cung cấp một mặt hàng cho trước hay không
CREATE PROC [dbo].[CungCap] @MaNhaCc char(4), @MaMH char(4)
AS
BEGIN
IF(EXISTS (SELECT * FROM CTCUNGCAP WHERE MaNhaCc = @MaNhaCc AND MaMatHang = @MaMH))
PRINT N'Có cung cấp'
ELSE PRINT N'Không cung cấp'
END

GO
/****** Object:  StoredProcedure [dbo].[Diachi_NV]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--5p Hiển thị địa chỉ của một nhân viên cho trước\\
CREATE PROC [dbo].[Diachi_NV] (@MaNV char(5))
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
/****** Object:  StoredProcedure [dbo].[DoanhThu]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--7p Doanh thu của quán trong một ngày cho trước
CREATE PROC [dbo].[DoanhThu] (@NgayDat date)
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
/****** Object:  StoredProcedure [dbo].[kiemtra_thongtin]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--4p Kiểm tra xem một nhân viên có trong danh sách đăng nhập không với mã nhân viên cho trước
CREATE PROC [dbo].[kiemtra_thongtin] (@MaNV char(5))
AS
BEGIN
IF(EXISTS (SELECT * FROM HETHONG WHERE MaNV = @MaNV))
PRINT N'Tồn tại người dùng'
ELSE PRINT N'Không tồn tại người dùng'
END

GO
/****** Object:  StoredProcedure [dbo].[KiemTra_TK]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--2p: kiem tra ten tai khoan va mat khau dang nhap he thong
CREATE PROC [dbo].[KiemTra_TK] @TenTk char(5), @MatKhau nvarchar(50)
AS
BEGIN
IF (EXISTS (SELECT *FROM HETHONG WHERE TenTk = @TenTk AND MatKhau = @MatKhau))
PRINT N'Thông tin đăng nhập đúng'
ELSE PRINT N'Thông tin đăng nhập sai'
END

GO
/****** Object:  StoredProcedure [dbo].[LuongNV]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[LuongNV] (@MaNV char(5), @Thang date)
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
/****** Object:  StoredProcedure [dbo].[SoLuong_Nhap]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--8p Hiển thị số mặt hàng nhập vào ngày 1/5/2021 bởi một nhân viên cho trước
CREATE PROC [dbo].[SoLuong_Nhap] @MaNV char(5)
AS
BEGIN
DECLARE @Tong int
IF NOT EXISTS (SELECT MaNV FROM NHANVIEN WHERE MaNV = @MaNV)
PRINT N'Mã nhân viên không tồn tại'
ELSE
SELECT @Tong = (SELECT COUNT(MaMatHang) FROM CTNHAP a, PHIEUNHAP b
WHERE a.SoPhieu = b.SoPhieu AND NgayNhap = '2021/5/1' AND MaNV = @MaNV)
PRINT @Tong
END

GO
/****** Object:  StoredProcedure [dbo].[Tim_Sdt]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--10p Tìm số điện thoại của một khách hàng cho trước
CREATE PROC [dbo].[Tim_Sdt] (@MaKH char(4))
AS
BEGIN
DECLARE @SDT nvarchar(20)
SELECT @SDT = (SELECT Sdt FROM KHACHHANG WHERE MaKH = @MaKH)
PRINT @SDT
END

GO
/****** Object:  StoredProcedure [dbo].[tong_khachhang]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--1p: tinh tong khach hang trong mot ngay cu the
CREATE PROC [dbo].[tong_khachhang] @NgayDat date
AS
BEGIN
DECLARE @TongSo int
SELECT @TongSo = (SELECT COUNT(MaKH) FROM DONHANG WHERE NgayDat = @NgayDat)
PRINT @TongSo
END

GO
/****** Object:  UserDefinedFunction [dbo].[ThamNien]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--11f In ra thâm niên làm việc của một nhân viên bất k
CREATE FUNCTION [dbo].[ThamNien] (@MaNV char(5))
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
/****** Object:  Table [dbo].[BAN]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BAN](
	[MaBan] [char](4) NOT NULL,
	[SoGhe] [int] NOT NULL,
 CONSTRAINT [PK_BAN] PRIMARY KEY CLUSTERED 
(
	[MaBan] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CALAMVIEC]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CALAMVIEC](
	[Ngay] [date] NOT NULL,
	[LoaiNgay] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_CALAMVIEC] PRIMARY KEY CLUSTERED 
(
	[Ngay] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[CAPNHATBAN]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CAPNHATBAN](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[MaBan] [char](4) NULL,
	[MaNV] [char](5) NULL,
	[TinhTrang] [nvarchar](200) NULL,
	[TGianCapNhat] [datetime] NULL,
 CONSTRAINT [PK_CAPNHATBAN] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CTBAN]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CTBAN](
	[MaBan] [char](4) NOT NULL,
	[MaDH] [char](4) NOT NULL,
	[TGian] [datetime] NULL,
 CONSTRAINT [PK_CTBAN] PRIMARY KEY CLUSTERED 
(
	[MaBan] ASC,
	[MaDH] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CTCALAM]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CTCALAM](
	[MaNV] [char](5) NOT NULL,
	[Ngay] [date] NOT NULL,
	[SoCa] [int] NOT NULL,
 CONSTRAINT [PK_CTCALAM] PRIMARY KEY CLUSTERED 
(
	[MaNV] ASC,
	[Ngay] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CTCUNGCAP]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CTCUNGCAP](
	[MaNhaCc] [char](4) NOT NULL,
	[MaMatHang] [char](4) NOT NULL,
	[Gia] [money] NULL,
 CONSTRAINT [PK_CTCUNGCAP] PRIMARY KEY CLUSTERED 
(
	[MaNhaCc] ASC,
	[MaMatHang] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CTDOAN]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CTDOAN](
	[MaDoAn] [char](4) NOT NULL,
	[MaMatHang] [char](4) NOT NULL,
	[SoLuong] [float] NOT NULL,
 CONSTRAINT [PK_CTDOAN] PRIMARY KEY CLUSTERED 
(
	[MaDoAn] ASC,
	[MaMatHang] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CTDONDAT]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CTDONDAT](
	[MaDonDat] [char](4) NOT NULL,
	[MaMatHang] [char](4) NOT NULL,
	[SoLuong] [float] NULL,
 CONSTRAINT [PK_CTDONDAT] PRIMARY KEY CLUSTERED 
(
	[MaDonDat] ASC,
	[MaMatHang] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CTDONHANG]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CTDONHANG](
	[MaDH] [char](4) NOT NULL,
	[MaDoAn] [char](4) NOT NULL,
	[SoLuong] [float] NOT NULL,
 CONSTRAINT [PK_CTDONHANG] PRIMARY KEY CLUSTERED 
(
	[MaDH] ASC,
	[MaDoAn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CTLUONG]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CTLUONG](
	[Thang] [date] NOT NULL,
	[MaNV] [char](5) NOT NULL,
	[CaThuong] [int] NOT NULL,
	[CaLe] [int] NOT NULL,
	[Thuong] [money] NOT NULL,
	[Phat] [money] NOT NULL,
 CONSTRAINT [PK_CTLUONG] PRIMARY KEY CLUSTERED 
(
	[Thang] ASC,
	[MaNV] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CTNHAP]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CTNHAP](
	[SoPhieu] [char](4) NOT NULL,
	[MaMatHang] [char](4) NOT NULL,
	[SoLuong] [float] NULL,
 CONSTRAINT [PK_CTNHAP] PRIMARY KEY CLUSTERED 
(
	[SoPhieu] ASC,
	[MaMatHang] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[CTTHANHTOAN]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[CTTHANHTOAN](
	[SoPhieu] [char](4) NOT NULL,
	[MaDonDat] [char](4) NOT NULL,
	[SoTienTra] [money] NOT NULL,
	[ConLai] [money] NULL,
 CONSTRAINT [PK_CTTHANHTOAN] PRIMARY KEY CLUSTERED 
(
	[SoPhieu] ASC,
	[MaDonDat] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DATBAN]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DATBAN](
	[SoPhieu] [char](4) NOT NULL,
	[MaKH] [char](4) NOT NULL,
	[Ngay] [date] NOT NULL,
	[Gio] [time](7) NOT NULL,
	[SoKH] [int] NOT NULL,
 CONSTRAINT [PK_DATBAN_1] PRIMARY KEY CLUSTERED 
(
	[SoPhieu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DOAN]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DOAN](
	[MaDoAn] [char](4) NOT NULL,
	[Ten] [nvarchar](200) NOT NULL,
	[Gia] [money] NOT NULL,
	[DonVi] [nvarchar](200) NOT NULL,
	[MoTa] [nvarchar](255) NULL,
 CONSTRAINT [PK_DOAN] PRIMARY KEY CLUSTERED 
(
	[MaDoAn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DONDH]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DONDH](
	[MaDonDat] [char](4) NOT NULL,
	[NgayDat] [date] NOT NULL,
	[PThucTToan] [nvarchar](200) NOT NULL,
	[MaNhaCc] [char](4) NOT NULL,
	[MaNV] [char](5) NOT NULL,
 CONSTRAINT [PK_DONDH] PRIMARY KEY CLUSTERED 
(
	[MaDonDat] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[DONHANG]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[DONHANG](
	[MaDH] [char](4) NOT NULL,
	[NgayDat] [date] NOT NULL,
	[MaNV] [char](5) NOT NULL,
	[MaKH] [char](4) NOT NULL,
	[Giam] [real] NOT NULL,
 CONSTRAINT [PK_DONHANG] PRIMARY KEY CLUSTERED 
(
	[MaDH] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[HETHONG]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[HETHONG](
	[TenTk] [char](5) NOT NULL,
	[MatKhau] [nvarchar](50) NOT NULL,
	[MaNV] [char](5) NOT NULL,
 CONSTRAINT [PK_HETHONG] PRIMARY KEY CLUSTERED 
(
	[TenTk] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[KHACHHANG]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[KHACHHANG](
	[MaKH] [char](4) NOT NULL,
	[HoTen] [nvarchar](100) NOT NULL,
	[Sdt] [nvarchar](20) NOT NULL,
	[DiaChi] [nvarchar](255) NULL,
	[Diem] [int] NULL,
 CONSTRAINT [PK_KHACHHANG] PRIMARY KEY CLUSTERED 
(
	[MaKH] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LUONG]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LUONG](
	[Thang] [date] NOT NULL,
	[SoDipLe] [int] NULL,
 CONSTRAINT [PK_LUONG_1] PRIMARY KEY CLUSTERED 
(
	[Thang] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[MATHANG]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MATHANG](
	[MaMatHang] [char](4) NOT NULL,
	[Ten] [nvarchar](200) NOT NULL,
	[TongSLuong] [float] NOT NULL,
	[DonVi] [nvarchar](50) NOT NULL,
 CONSTRAINT [PK_MATHANG] PRIMARY KEY CLUSTERED 
(
	[MaMatHang] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[NHACC]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NHACC](
	[MaNhaCc] [char](4) NOT NULL,
	[HoTen] [nvarchar](100) NOT NULL,
	[Sdt] [nvarchar](20) NOT NULL,
	[DiaChi] [nvarchar](200) NOT NULL,
 CONSTRAINT [PK_NHACC] PRIMARY KEY CLUSTERED 
(
	[MaNhaCc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[NHANVIEN]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[NHANVIEN](
	[MaNV] [char](5) NOT NULL,
	[HoTen] [nvarchar](100) NOT NULL,
	[Sdt] [nvarchar](20) NOT NULL,
	[DiaChi] [nvarchar](255) NULL,
	[GioiTinh] [nvarchar](50) NOT NULL,
	[ChucVu] [nvarchar](50) NOT NULL,
	[NgaySinh] [date] NOT NULL,
	[NgayVaoLam] [date] NULL,
	[CCCD] [nvarchar](20) NOT NULL,
	[QuanLy] [char](5) NULL,
 CONSTRAINT [PK_NHANVIEN] PRIMARY KEY CLUSTERED 
(
	[MaNV] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PHIEUDANHGIA]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PHIEUDANHGIA](
	[SoPhieu] [char](4) NOT NULL,
	[MaDH] [char](4) NOT NULL,
	[MaKH] [char](4) NOT NULL,
	[DoAn] [int] NOT NULL,
	[PhucVu] [int] NOT NULL,
	[Gia] [int] NOT NULL,
	[CSVC] [int] NOT NULL,
	[NXet] [nvarchar](255) NULL,
 CONSTRAINT [PK_PHIEUDANHGIA] PRIMARY KEY CLUSTERED 
(
	[SoPhieu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PHIEUNHAP]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PHIEUNHAP](
	[SoPhieu] [char](4) NOT NULL,
	[NgayNhap] [date] NULL,
	[MaDonDat] [char](4) NOT NULL,
	[MaNV] [char](5) NOT NULL,
 CONSTRAINT [PK_PHIEUNHAP] PRIMARY KEY CLUSTERED 
(
	[SoPhieu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[THANHTOAN]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[THANHTOAN](
	[SoPhieu] [char](4) NOT NULL,
	[MaNhaCc] [char](4) NOT NULL,
	[MaNV] [char](5) NOT NULL,
	[NgayThanhToan] [date] NULL,
 CONSTRAINT [PK_THANHTOAN] PRIMARY KEY CLUSTERED 
(
	[SoPhieu] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  UserDefinedFunction [dbo].[DatTruoc]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- 8fIn ra danh sách khách hàng đặt trước trong ngày 1/5/2021
CREATE FUNCTION [dbo].[DatTruoc]()
RETURNS TABLE AS
RETURN (SELECT MaKH FROM DATBAN WHERE Ngay = '2021/5/1')

GO
/****** Object:  UserDefinedFunction [dbo].[GiaCao]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--10f In ra danh sách 10 món ăn có giá bán cao nhất
CREATE FUNCTION [dbo].[GiaCao]()
RETURNS TABLE AS
RETURN (SELECT TOP 10 MaDoAn, Ten FROM DOAN ORDER BY Gia DESC)

GO
/****** Object:  UserDefinedFunction [dbo].[GiaCaoNhat]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--6f In ra danh sách 5 mặt hàng có giá nhập cao nhất
CREATE FUNCTION [dbo].[GiaCaoNhat] ()
RETURNS TABLE AS
RETURN (SELECT TOP 5 MaNhaCc, MaMatHang FROM CTCUNGCAP ORDER BY Gia DESC)

GO
/****** Object:  UserDefinedFunction [dbo].[KiemKho]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--9f In ra sản phẩm không còn trong kho
CREATE FUNCTION [dbo].[KiemKho]()
RETURNS TABLE AS
RETURN (SELECT MaMatHang, Ten FROM MATHANG WHERE TongSLuong = 0)

GO
/****** Object:  UserDefinedFunction [dbo].[LuongBanCao]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--7f Liệt kê 3 đồ ăn có lượng bán cao nhất
CREATE FUNCTION [dbo].[LuongBanCao] ()
RETURNS TABLE AS
RETURN (SELECT TOP 3 a.MaDoAn, Ten, COUNT(SoLuong) AS SLuong
FROM DOAN a, CTDONHANG b
WHERE a.MaDoAn = b.MaDoAn
GROUP BY a.MaDoAn, Ten
ORDER BY SLuong DESC)

GO
/****** Object:  UserDefinedFunction [dbo].[NgayMuaHang]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--1f Hiển thị danh sách khách hàng đã mua hàng trong một ngày bất kỳ\\
CREATE FUNCTION [dbo].[NgayMuaHang] (@Ngay date)
RETURNS TABLE AS
RETURN (SELECT MaKH FROM DONHANG WHERE NgayDat = @Ngay)

GO
/****** Object:  UserDefinedFunction [dbo].[PhucVu]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--5f In ra danh sách khách hàng được nhân viên NV002 phục vụ vào ngày cho trước
CREATE FUNCTION [dbo].[PhucVu] (@Ngay date)
RETURNS TABLE AS
RETURN (SELECT MaKH FROM DONHANG WHERE MaNV = 'NV002' AND NgayDat = @Ngay)

GO
/****** Object:  UserDefinedFunction [dbo].[SanPham]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--4f In ra sản phẩm đặt từ nhà cung cấp trong một ngày cho trước
CREATE FUNCTION [dbo].[SanPham] (@Ngay date)
RETURNS TABLE AS
RETURN (SELECT MaMatHang FROM DONDH a, CTCUNGCAP b WHERE a.MaNhaCc = b.MaNhaCc AND NgayDat = @Ngay)

GO
/****** Object:  UserDefinedFunction [dbo].[SLuong_Nhap]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--3f In ra danh sách sản phẩm với số lượng nhập vào là 30
CREATE FUNCTION [dbo].[SLuong_Nhap] ()
RETURNS TABLE AS
RETURN (SELECT a.MaMatHang, Ten
FROM MATHANG a, CTNHAP b
WHERE a.MaMatHang = b.MaMatHang AND SoLuong = 30)

GO
/****** Object:  UserDefinedFunction [dbo].[TuoiNV]    Script Date: 6/30/2021 1:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--2f Danh sách nhân viên có tuổi lớn hơn 18
CREATE FUNCTION [dbo].[TuoiNV] ()
RETURNS TABLE AS
RETURN (SELECT MaNV, HoTen, YEAR(CURRENT_TIMESTAMP) - YEAR(NgaySinh) AS N'Tuổi'
FROM NHANVIEN
WHERE YEAR(CURRENT_TIMESTAMP) - YEAR(NgaySinh) > 18)

GO
INSERT [dbo].[BAN] ([MaBan], [SoGhe]) VALUES (N'B001', 4)
INSERT [dbo].[BAN] ([MaBan], [SoGhe]) VALUES (N'B002', 4)
INSERT [dbo].[BAN] ([MaBan], [SoGhe]) VALUES (N'B003', 4)
INSERT [dbo].[BAN] ([MaBan], [SoGhe]) VALUES (N'B004', 4)
INSERT [dbo].[BAN] ([MaBan], [SoGhe]) VALUES (N'B005', 6)
INSERT [dbo].[BAN] ([MaBan], [SoGhe]) VALUES (N'B006', 6)
INSERT [dbo].[BAN] ([MaBan], [SoGhe]) VALUES (N'B007', 6)
INSERT [dbo].[BAN] ([MaBan], [SoGhe]) VALUES (N'B008', 6)
INSERT [dbo].[BAN] ([MaBan], [SoGhe]) VALUES (N'B009', 8)
INSERT [dbo].[BAN] ([MaBan], [SoGhe]) VALUES (N'B010', 8)
INSERT [dbo].[BAN] ([MaBan], [SoGhe]) VALUES (N'B011', 8)
INSERT [dbo].[BAN] ([MaBan], [SoGhe]) VALUES (N'B012', 8)
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-01' AS Date), N'Lễ')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-02' AS Date), N'Lễ')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-03' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-04' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-05' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-06' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-07' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-08' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-09' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-10' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-11' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-12' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-13' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-14' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-15' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-16' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-17' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-18' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-19' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-20' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-21' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-22' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-23' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-24' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-25' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-26' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-27' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-28' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-29' AS Date), N'Thường')
INSERT [dbo].[CALAMVIEC] ([Ngay], [LoaiNgay]) VALUES (CAST(N'2021-05-30' AS Date), N'Thường')
SET IDENTITY_INSERT [dbo].[CAPNHATBAN] ON 

INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (1, N'B004', N'NV006', N'Đặt trước', CAST(N'2021-05-01 10:00:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (2, N'B005', N'NV006', N'Đặt trước', CAST(N'2021-05-01 10:00:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (3, N'B009', N'NV006', N'Đặt trước', CAST(N'2021-05-01 10:00:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (4, N'B010', N'NV006', N'Đặt trước', CAST(N'2021-05-01 10:00:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (5, N'B003', N'NV005', N'Đầy', CAST(N'2021-05-01 10:52:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (6, N'B001', N'NV002', N'Đầy', CAST(N'2021-05-01 11:00:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (7, N'B002', N'NV002', N'Đầy', CAST(N'2021-05-01 11:00:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (8, N'B007', N'NV005', N'Đầy', CAST(N'2021-05-01 11:05:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (9, N'B006', N'NV005', N'Đầy', CAST(N'2021-05-01 11:12:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (10, N'B008', N'NV005', N'Đầy', CAST(N'2021-05-01 11:12:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (11, N'B002', N'NV002', N'Trống', CAST(N'2021-05-01 12:45:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (12, N'B001', N'NV002', N'Trống', CAST(N'2021-05-01 13:02:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (13, N'B004', N'NV006', N'Trống', CAST(N'2021-05-01 13:24:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (14, N'B005', N'NV006', N'Trống', CAST(N'2021-05-01 13:24:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (15, N'B009', N'NV006', N'Trống', CAST(N'2021-05-01 13:34:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (16, N'B010', N'NV006', N'Trống', CAST(N'2021-05-01 13:34:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (17, N'B003', N'NV005', N'Trống', CAST(N'2021-05-01 13:36:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (18, N'B007', N'NV005', N'Trống', CAST(N'2021-05-01 13:40:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (19, N'B006', N'NV005', N'Trống', CAST(N'2021-05-01 13:42:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (20, N'B008', N'NV005', N'Trống', CAST(N'2021-05-01 13:50:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (21, N'B005', N'NV007', N'Đặt trước', CAST(N'2021-05-01 15:30:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (22, N'B002', N'NV007', N'Đặt trước', CAST(N'2021-05-01 17:00:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (23, N'B006', N'NV008', N'Đặt trước', CAST(N'2021-05-01 17:00:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (24, N'B008', N'NV008', N'Đặt trước', CAST(N'2021-05-01 17:00:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (25, N'B009', N'NV008', N'Đặt trước', CAST(N'2021-05-01 17:00:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (26, N'B003', N'NV007', N'Đầy', CAST(N'2021-05-01 18:23:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (27, N'B005', N'NV007', N'Trống', CAST(N'2021-05-01 18:30:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (28, N'B002', N'NV007', N'Trống', CAST(N'2021-05-01 18:45:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (29, N'B006', N'NV008', N'Trống', CAST(N'2021-05-01 18:56:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (30, N'B008', N'NV008', N'Trống', CAST(N'2021-05-01 19:15:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (31, N'B009', N'NV008', N'Trống', CAST(N'2021-05-01 19:32:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (32, N'B003', N'NV007', N'Trống', CAST(N'2021-05-01 19:42:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (33, N'B006', N'NV010', N'Đầy', CAST(N'2021-05-01 20:12:00.000' AS DateTime))
INSERT [dbo].[CAPNHATBAN] ([ID], [MaBan], [MaNV], [TinhTrang], [TGianCapNhat]) VALUES (34, N'B006', N'NV010', N'Trống', CAST(N'2021-05-01 21:43:00.000' AS DateTime))
SET IDENTITY_INSERT [dbo].[CAPNHATBAN] OFF
INSERT [dbo].[CTBAN] ([MaBan], [MaDH], [TGian]) VALUES (N'B001', N'H002', CAST(N'2021-05-01 11:00:00.000' AS DateTime))
INSERT [dbo].[CTBAN] ([MaBan], [MaDH], [TGian]) VALUES (N'B002', N'H003', CAST(N'2021-05-01 11:00:00.000' AS DateTime))
INSERT [dbo].[CTBAN] ([MaBan], [MaDH], [TGian]) VALUES (N'B003', N'H001', CAST(N'2021-05-01 10:52:00.000' AS DateTime))
INSERT [dbo].[CTBAN] ([MaBan], [MaDH], [TGian]) VALUES (N'B003', N'H006', CAST(N'2021-05-01 18:23:00.000' AS DateTime))
INSERT [dbo].[CTBAN] ([MaBan], [MaDH], [TGian]) VALUES (N'B006', N'H005', CAST(N'2021-05-01 11:12:00.000' AS DateTime))
INSERT [dbo].[CTBAN] ([MaBan], [MaDH], [TGian]) VALUES (N'B007', N'H004', CAST(N'2021-05-01 11:05:00.000' AS DateTime))
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-01' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-02' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-03' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-04' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-05' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-06' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-07' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-08' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-09' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-10' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-11' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-12' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-13' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-14' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-15' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-16' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-17' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-18' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-19' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-20' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-21' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-22' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-23' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-24' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-25' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-26' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-27' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-28' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV001', CAST(N'2021-05-29' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-01' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-02' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-03' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-04' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-05' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-06' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-07' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-08' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-09' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-10' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-11' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-12' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-13' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-14' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-15' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-16' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-17' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-18' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-19' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-20' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-21' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-22' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-23' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-24' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-25' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-26' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-27' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-28' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV002', CAST(N'2021-05-29' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-01' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-02' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-03' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-04' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-05' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-06' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-07' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-08' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-09' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-10' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-11' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-12' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-13' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-14' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-15' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-16' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-17' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-18' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-19' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-20' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-21' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-22' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-23' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-24' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-25' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-26' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-27' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-28' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV005', CAST(N'2021-05-29' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-01' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-02' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-03' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-04' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-05' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-06' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-07' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-08' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-09' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-10' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-11' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-12' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-13' AS Date), 3)
GO
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-14' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-15' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-16' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-17' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-18' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-19' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-20' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-21' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-22' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-23' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-24' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-25' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-26' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-27' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-28' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV006', CAST(N'2021-05-29' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-01' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-02' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-03' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-04' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-05' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-06' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-07' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-08' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-09' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-10' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-11' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-12' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-13' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-14' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-15' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-16' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-17' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-18' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-19' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-20' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-21' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-22' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-23' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-24' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-25' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-26' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-27' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-28' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV007', CAST(N'2021-05-29' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-01' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-02' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-03' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-04' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-05' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-06' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-07' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-08' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-09' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-10' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-11' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-12' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-13' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-14' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-15' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-16' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-17' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-18' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-19' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-20' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-21' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-22' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-23' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-24' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-25' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-26' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-27' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-28' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV008', CAST(N'2021-05-29' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-01' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-02' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-03' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-04' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-05' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-06' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-07' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-08' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-09' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-10' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-11' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-12' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-13' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-14' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-15' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-16' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-17' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-18' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-19' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-20' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-21' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-22' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-23' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-24' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-25' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-26' AS Date), 3)
GO
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-27' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-28' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV009', CAST(N'2021-05-29' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-01' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-02' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-03' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-04' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-05' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-06' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-07' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-08' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-09' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-10' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-11' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-12' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-13' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-14' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-15' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-16' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-17' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-18' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-19' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-20' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-21' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-22' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-23' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-24' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-25' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-26' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-27' AS Date), 2)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-28' AS Date), 3)
INSERT [dbo].[CTCALAM] ([MaNV], [Ngay], [SoCa]) VALUES (N'NV010', CAST(N'2021-05-29' AS Date), 3)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C001', N'D001', 4000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C001', N'D002', 4000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C001', N'D004', 5000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C001', N'D005', 4000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C001', N'D006', 4000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C001', N'D007', 4000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C001', N'D008', 4000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C001', N'D009', 10000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C001', N'D010', 4000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C002', N'D001', 4500.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C002', N'D002', 4000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C002', N'D004', 4500.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C002', N'D005', 4500.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C002', N'D006', 3500.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C002', N'D007', 3500.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C002', N'D008', 5000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C002', N'D009', 11000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C002', N'D010', 4500.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C003', N'N001', 35000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C003', N'N002', 100000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C003', N'N003', 100000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C003', N'N004', 150000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C003', N'N005', 50000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C003', N'N006', 150000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C004', N'N001', 35000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C004', N'N002', 100000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C004', N'N003', 100000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C004', N'N004', 150000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C004', N'N005', 50000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C004', N'N006', 150000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C005', N'N007', 20000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C005', N'N008', 10000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C005', N'N009', 60000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C005', N'N010', 50000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C005', N'N011', 50000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C006', N'N007', 18000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C006', N'N008', 10000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C006', N'N009', 62000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C006', N'N010', 48000.0000)
INSERT [dbo].[CTCUNGCAP] ([MaNhaCc], [MaMatHang], [Gia]) VALUES (N'C006', N'N011', 50000.0000)
INSERT [dbo].[CTDOAN] ([MaDoAn], [MaMatHang], [SoLuong]) VALUES (N'M008', N'N012', 0.5)
INSERT [dbo].[CTDOAN] ([MaDoAn], [MaMatHang], [SoLuong]) VALUES (N'M008', N'N014', 0.3)
INSERT [dbo].[CTDOAN] ([MaDoAn], [MaMatHang], [SoLuong]) VALUES (N'M009', N'N002', 0.3)
INSERT [dbo].[CTDOAN] ([MaDoAn], [MaMatHang], [SoLuong]) VALUES (N'M010', N'N003', 0.3)
INSERT [dbo].[CTDOAN] ([MaDoAn], [MaMatHang], [SoLuong]) VALUES (N'M011', N'N004', 0.3)
INSERT [dbo].[CTDOAN] ([MaDoAn], [MaMatHang], [SoLuong]) VALUES (N'M011', N'N010', 10)
INSERT [dbo].[CTDOAN] ([MaDoAn], [MaMatHang], [SoLuong]) VALUES (N'M012', N'N005', 6)
INSERT [dbo].[CTDOAN] ([MaDoAn], [MaMatHang], [SoLuong]) VALUES (N'M012', N'N011', 10)
INSERT [dbo].[CTDOAN] ([MaDoAn], [MaMatHang], [SoLuong]) VALUES (N'M013', N'N006', 0.3)
INSERT [dbo].[CTDOAN] ([MaDoAn], [MaMatHang], [SoLuong]) VALUES (N'M013', N'N013', 0.1)
INSERT [dbo].[CTDONDAT] ([MaDonDat], [MaMatHang], [SoLuong]) VALUES (N'D001', N'D001', 30)
INSERT [dbo].[CTDONDAT] ([MaDonDat], [MaMatHang], [SoLuong]) VALUES (N'D001', N'D002', 30)
INSERT [dbo].[CTDONDAT] ([MaDonDat], [MaMatHang], [SoLuong]) VALUES (N'D001', N'D004', 25)
INSERT [dbo].[CTDONDAT] ([MaDonDat], [MaMatHang], [SoLuong]) VALUES (N'D002', N'D006', 30)
INSERT [dbo].[CTDONDAT] ([MaDonDat], [MaMatHang], [SoLuong]) VALUES (N'D002', N'D007', 30)
INSERT [dbo].[CTDONDAT] ([MaDonDat], [MaMatHang], [SoLuong]) VALUES (N'D002', N'D008', 35)
INSERT [dbo].[CTDONDAT] ([MaDonDat], [MaMatHang], [SoLuong]) VALUES (N'D003', N'N001', 5)
INSERT [dbo].[CTDONDAT] ([MaDonDat], [MaMatHang], [SoLuong]) VALUES (N'D003', N'N002', 15)
INSERT [dbo].[CTDONHANG] ([MaDH], [MaDoAn], [SoLuong]) VALUES (N'H001', N'D002', 4)
INSERT [dbo].[CTDONHANG] ([MaDH], [MaDoAn], [SoLuong]) VALUES (N'H001', N'M001', 1)
INSERT [dbo].[CTDONHANG] ([MaDH], [MaDoAn], [SoLuong]) VALUES (N'H001', N'M002', 2)
INSERT [dbo].[CTDONHANG] ([MaDH], [MaDoAn], [SoLuong]) VALUES (N'H001', N'M003', 2)
INSERT [dbo].[CTDONHANG] ([MaDH], [MaDoAn], [SoLuong]) VALUES (N'H001', N'M008', 2)
INSERT [dbo].[CTDONHANG] ([MaDH], [MaDoAn], [SoLuong]) VALUES (N'H001', N'M009', 2)
INSERT [dbo].[CTDONHANG] ([MaDH], [MaDoAn], [SoLuong]) VALUES (N'H001', N'M010', 2)
INSERT [dbo].[CTDONHANG] ([MaDH], [MaDoAn], [SoLuong]) VALUES (N'H001', N'M026', 2)
INSERT [dbo].[CTDONHANG] ([MaDH], [MaDoAn], [SoLuong]) VALUES (N'H002', N'D002', 7)
INSERT [dbo].[CTDONHANG] ([MaDH], [MaDoAn], [SoLuong]) VALUES (N'H002', N'D009', 3)
INSERT [dbo].[CTDONHANG] ([MaDH], [MaDoAn], [SoLuong]) VALUES (N'H002', N'M001', 3)
INSERT [dbo].[CTDONHANG] ([MaDH], [MaDoAn], [SoLuong]) VALUES (N'H002', N'M002', 4)
INSERT [dbo].[CTDONHANG] ([MaDH], [MaDoAn], [SoLuong]) VALUES (N'H002', N'M003', 4)
INSERT [dbo].[CTDONHANG] ([MaDH], [MaDoAn], [SoLuong]) VALUES (N'H002', N'M008', 4)
INSERT [dbo].[CTDONHANG] ([MaDH], [MaDoAn], [SoLuong]) VALUES (N'H002', N'M009', 4)
INSERT [dbo].[CTDONHANG] ([MaDH], [MaDoAn], [SoLuong]) VALUES (N'H002', N'M010', 4)
INSERT [dbo].[CTDONHANG] ([MaDH], [MaDoAn], [SoLuong]) VALUES (N'H002', N'M025', 3)
INSERT [dbo].[CTDONHANG] ([MaDH], [MaDoAn], [SoLuong]) VALUES (N'H002', N'M026', 4)
INSERT [dbo].[CTDONHANG] ([MaDH], [MaDoAn], [SoLuong]) VALUES (N'H002', N'M027', 2)
INSERT [dbo].[CTDONHANG] ([MaDH], [MaDoAn], [SoLuong]) VALUES (N'H002', N'M028', 1)
INSERT [dbo].[CTDONHANG] ([MaDH], [MaDoAn], [SoLuong]) VALUES (N'H002', N'M029', 1)
INSERT [dbo].[CTDONHANG] ([MaDH], [MaDoAn], [SoLuong]) VALUES (N'H002', N'M030', 6)
INSERT [dbo].[CTDONHANG] ([MaDH], [MaDoAn], [SoLuong]) VALUES (N'H002', N'N001', 7)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-01-01' AS Date), N'NV001', 81, 6, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-01-01' AS Date), N'NV002', 60, 3, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-01-01' AS Date), N'NV005', 81, 6, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-01-01' AS Date), N'NV006', 60, 3, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-01-01' AS Date), N'NV007', 60, 3, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-01-01' AS Date), N'NV008', 60, 3, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-01-01' AS Date), N'NV009', 81, 6, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-01-01' AS Date), N'NV010', 68, 4, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-02-01' AS Date), N'NV001', 68, 4, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-02-01' AS Date), N'NV002', 52, 2, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-02-01' AS Date), N'NV005', 68, 4, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-02-01' AS Date), N'NV006', 52, 2, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-02-01' AS Date), N'NV007', 52, 2, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-02-01' AS Date), N'NV008', 52, 2, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-02-01' AS Date), N'NV009', 68, 4, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-02-01' AS Date), N'NV010', 51, 2, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-03-01' AS Date), N'NV001', 87, 0, 0.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-03-01' AS Date), N'NV002', 62, 0, 0.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-03-01' AS Date), N'NV005', 87, 0, 0.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-03-01' AS Date), N'NV006', 62, 0, 0.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-03-01' AS Date), N'NV007', 62, 0, 0.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-03-01' AS Date), N'NV008', 62, 0, 0.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-03-01' AS Date), N'NV009', 87, 0, 0.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-03-01' AS Date), N'NV010', 74, 0, 0.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-04-01' AS Date), N'NV001', 81, 6, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-04-01' AS Date), N'NV002', 60, 4, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-04-01' AS Date), N'NV005', 81, 6, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-04-01' AS Date), N'NV006', 60, 4, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-04-01' AS Date), N'NV007', 60, 4, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-04-01' AS Date), N'NV008', 60, 4, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-04-01' AS Date), N'NV009', 81, 6, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-04-01' AS Date), N'NV010', 70, 6, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-05-01' AS Date), N'NV001', 81, 6, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-05-01' AS Date), N'NV002', 64, 4, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-05-01' AS Date), N'NV005', 81, 6, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-05-01' AS Date), N'NV006', 64, 4, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-05-01' AS Date), N'NV007', 64, 4, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-05-01' AS Date), N'NV008', 64, 4, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-05-01' AS Date), N'NV009', 81, 6, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-05-01' AS Date), N'NV010', 70, 5, 300000.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-06-01' AS Date), N'NV001', 87, 0, 0.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-06-01' AS Date), N'NV002', 64, 0, 0.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-06-01' AS Date), N'NV005', 87, 0, 0.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-06-01' AS Date), N'NV006', 65, 0, 0.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-06-01' AS Date), N'NV007', 63, 0, 0.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-06-01' AS Date), N'NV008', 62, 0, 0.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-06-01' AS Date), N'NV009', 87, 0, 0.0000, 0.0000)
INSERT [dbo].[CTLUONG] ([Thang], [MaNV], [CaThuong], [CaLe], [Thuong], [Phat]) VALUES (CAST(N'2021-06-01' AS Date), N'NV010', 76, 0, 0.0000, 0.0000)
INSERT [dbo].[CTNHAP] ([SoPhieu], [MaMatHang], [SoLuong]) VALUES (N'P001', N'D001', 30)
INSERT [dbo].[CTNHAP] ([SoPhieu], [MaMatHang], [SoLuong]) VALUES (N'P001', N'D002', 30)
INSERT [dbo].[CTNHAP] ([SoPhieu], [MaMatHang], [SoLuong]) VALUES (N'P001', N'D004', 25)
INSERT [dbo].[CTNHAP] ([SoPhieu], [MaMatHang], [SoLuong]) VALUES (N'P002', N'D006', 30)
INSERT [dbo].[CTNHAP] ([SoPhieu], [MaMatHang], [SoLuong]) VALUES (N'P002', N'D007', 30)
INSERT [dbo].[CTNHAP] ([SoPhieu], [MaMatHang], [SoLuong]) VALUES (N'P002', N'D008', 35)
INSERT [dbo].[CTNHAP] ([SoPhieu], [MaMatHang], [SoLuong]) VALUES (N'P003', N'N001', 5)
INSERT [dbo].[CTNHAP] ([SoPhieu], [MaMatHang], [SoLuong]) VALUES (N'P003', N'N002', 15)
INSERT [dbo].[CTTHANHTOAN] ([SoPhieu], [MaDonDat], [SoTienTra], [ConLai]) VALUES (N'P001', N'D001', 1000000.0000, 0.0000)
INSERT [dbo].[CTTHANHTOAN] ([SoPhieu], [MaDonDat], [SoTienTra], [ConLai]) VALUES (N'P002', N'D002', 960000.0000, 0.0000)
INSERT [dbo].[CTTHANHTOAN] ([SoPhieu], [MaDonDat], [SoTienTra], [ConLai]) VALUES (N'P003', N'D003', 580000.0000, 0.0000)
INSERT [dbo].[CTTHANHTOAN] ([SoPhieu], [MaDonDat], [SoTienTra], [ConLai]) VALUES (N'P004', N'D004', 1000000.0000, 500000.0000)
INSERT [dbo].[CTTHANHTOAN] ([SoPhieu], [MaDonDat], [SoTienTra], [ConLai]) VALUES (N'P004', N'D005', 500000.0000, 0.0000)
INSERT [dbo].[CTTHANHTOAN] ([SoPhieu], [MaDonDat], [SoTienTra], [ConLai]) VALUES (N'P005', N'D006', 700000.0000, 500000.0000)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P001', N'K001', CAST(N'2021-05-01' AS Date), CAST(N'18:00:00' AS Time), 4)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P002', N'K002', CAST(N'2021-05-01' AS Date), CAST(N'18:00:00' AS Time), 7)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P003', N'K003', CAST(N'2021-05-01' AS Date), CAST(N'11:00:00' AS Time), 8)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P004', N'K004', CAST(N'2021-05-01' AS Date), CAST(N'18:00:00' AS Time), 15)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P005', N'K005', CAST(N'2021-05-01' AS Date), CAST(N'11:00:00' AS Time), 17)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P006', N'K006', CAST(N'2021-05-01' AS Date), CAST(N'16:30:00' AS Time), 5)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P007', N'K007', CAST(N'2021-05-09' AS Date), CAST(N'18:00:00' AS Time), 5)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P008', N'K008', CAST(N'2021-05-09' AS Date), CAST(N'16:30:00' AS Time), 3)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P009', N'K009', CAST(N'2021-05-09' AS Date), CAST(N'11:00:00' AS Time), 4)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P010', N'K010', CAST(N'2021-05-10' AS Date), CAST(N'18:00:00' AS Time), 7)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P011', N'K011', CAST(N'2021-05-14' AS Date), CAST(N'19:00:00' AS Time), 8)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P012', N'K012', CAST(N'2021-05-14' AS Date), CAST(N'18:00:00' AS Time), 9)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P013', N'K013', CAST(N'2021-05-14' AS Date), CAST(N'16:30:00' AS Time), 10)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P014', N'K014', CAST(N'2021-05-14' AS Date), CAST(N'18:00:00' AS Time), 11)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P015', N'K015', CAST(N'2021-05-15' AS Date), CAST(N'11:00:00' AS Time), 5)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P016', N'K004', CAST(N'2021-05-16' AS Date), CAST(N'18:00:00' AS Time), 8)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P017', N'K005', CAST(N'2021-05-20' AS Date), CAST(N'16:30:00' AS Time), 6)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P018', N'K006', CAST(N'2021-05-20' AS Date), CAST(N'18:00:00' AS Time), 3)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P019', N'K007', CAST(N'2021-05-20' AS Date), CAST(N'18:00:00' AS Time), 5)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P020', N'K008', CAST(N'2021-05-20' AS Date), CAST(N'16:30:00' AS Time), 5)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P021', N'K021', CAST(N'2021-05-21' AS Date), CAST(N'11:00:00' AS Time), 13)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P022', N'K022', CAST(N'2021-05-26' AS Date), CAST(N'18:00:00' AS Time), 15)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P023', N'K023', CAST(N'2021-05-26' AS Date), CAST(N'18:00:00' AS Time), 11)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P024', N'K009', CAST(N'2021-05-26' AS Date), CAST(N'16:30:00' AS Time), 9)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P025', N'K010', CAST(N'2021-05-26' AS Date), CAST(N'18:00:00' AS Time), 8)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P026', N'K011', CAST(N'2021-05-28' AS Date), CAST(N'11:00:00' AS Time), 5)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P027', N'K012', CAST(N'2021-05-28' AS Date), CAST(N'18:00:00' AS Time), 8)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P028', N'K005', CAST(N'2021-05-28' AS Date), CAST(N'18:00:00' AS Time), 3)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P029', N'K006', CAST(N'2021-05-29' AS Date), CAST(N'16:30:00' AS Time), 6)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P030', N'K007', CAST(N'2021-05-30' AS Date), CAST(N'18:00:00' AS Time), 4)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P031', N'K008', CAST(N'2021-05-30' AS Date), CAST(N'11:00:00' AS Time), 2)
INSERT [dbo].[DATBAN] ([SoPhieu], [MaKH], [Ngay], [Gio], [SoKH]) VALUES (N'P032', N'K009', CAST(N'2021-05-30' AS Date), CAST(N'11:00:00' AS Time), 2)
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'D001', N'Bia Hà Nội', 20000.0000, N'Lon', N'Bia')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'D002', N'Coca', 15000.0000, N'Lon', N'Nước ngọt')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'D003', N'Bò Húc', 20000.0000, N'Lon', N'Nước ngọt')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'D004', N'Laive', 10000.0000, N'Chai', N'Nước khoáng')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'D005', N'Chanh muối', 15000.0000, N'Chai', N'Nước ngọt')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'D006', N'Strongbow', 25000.0000, N'Chai', N'Rượu hoa quả')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'D007', N'Rượu táo mèo', 50000.0000, N'Chai', N'Rượu')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'D008', N'Rượu mơ', 50000.0000, N'Chai', N'Rượu')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'D009', N'Rượu nếp Cái', 50000.0000, N'Chai', N'Rượu')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'D010', N'Âu sâm dứa', 20000.0000, N'Âu', N'Nước ngọt')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'D011', N'Trà sâm dứa', 5000.0000, N'Cốc', N'Trà')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M001', N'Nướng lai rai', 100000.0000, N'suất', N'Món chính')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M002', N'Kim chi Hàn Quốc', 20000.0000, N'Bát', N'Đồ ăn kèm')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M003', N'Nấm kim châm', 20000.0000, N'Đĩa', N'Đồ ăn kèm')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M004', N'Fomai rắc', 20000.0000, N'Đĩa', N'Đồ ăn kèm')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M005', N'Trứng gà', 5000.0000, N'quả', N'Đồ ăn kèm')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M006', N'Các loại Viên', 10000.0000, N'Viên', N'Đồ ăn kèm')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M007', N'Combo Viên', 80000.0000, N'10 Viên', N'Đồ ăn kèm')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M008', N'Bò Mỹ cuộn nấm', 100000.0000, N'Đĩa', N'Món chính')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M009', N'Ba chỉ bò Mỹ', 100000.0000, N'Đĩa', N'Món chính')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M010', N'Sườn sụn', 100000.0000, N'Đĩa', N'Món chính')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M011', N'Bạch tuộc sốt Hàn', 130000.0000, N'Đĩa', N'Món chính')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M012', N'Chân gà sốt Tứ Xuyên', 100000.0000, N'Đĩa', N'Món chính')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M013', N'Mực sốt sa tế', 150000.0000, N'Đĩa', N'Món chính')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M014', N'Lẩu Thái size S', 300000.0000, N'Nồi', N'Món chính')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M015', N'Lẩu Thái size M', 400000.0000, N'Nồi', N'Món chính')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M016', N'Lẩu Thái size L', 500000.0000, N'Nồi', N'Món chính')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M017', N'Lẩu cà chua size S', 350000.0000, N'Nồi', N'Món chính')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M018', N'Lẩu cà chua size M', 450000.0000, N'Nồi', N'Món chính')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M019', N'Lẩu cà chua size L', 550000.0000, N'Nồi', N'Món chính')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M020', N'Nem chua rán', 60000.0000, N'Đĩa', N'Đồ ăn nhanh')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M021', N'Khoai tây chiên', 35000.0000, N'Đĩa', N'Đồ ăn nhanh')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M022', N'Khoai tây chiên fomai', 45000.0000, N'Đĩa', N'Đồ ăn nhanh')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M023', N'Khoai tây chiên bơ tỏi', 45000.0000, N'Đĩa', N'Đồ ăn nhanh')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M024', N'Khoai lang kén', 30000.0000, N'Đĩa', N'Đồ ăn nhanh')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M025', N'Khoai lang kén fomai', 45000.0000, N'Đĩa', N'Đồ ăn nhanh')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M026', N'Ngô chiên', 40000.0000, N'Đĩa', N'Đồ ăn nhanh')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M027', N'Chân gà sả ớt', 70000.0000, N'Bát', N'Đồ ăn nhanh')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M028', N'Mực chiên bơ tỏi', 220000.0000, N'Đĩa', N'Đồ ăn nhanh')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M029', N'Bạch tuộc bơ tỏi', 180000.0000, N'Đĩa', N'Đồ ăn nhanh')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'M030', N'Dưa chuột, củ đậu', 20000.0000, N'Đĩa', N'Đồ ăn nhanh')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'N001', N'Bánh mì', 5000.0000, N'Cái', N'Đồ ăn nhẹ')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'N002', N'Mì tôm', 5000.0000, N'Gói', N'Đồ ăn kèm')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'N003', N'Váng đậu', 10000.0000, N'Đĩa', N'Đồ ăn kèm')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'N004', N'Đậu phụ', 10000.0000, N'Đĩa', N'Đồ ăn kèm')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'N005', N'Rau lẩu', 20000.0000, N'rổ', N'Đồ ăn kèm')
INSERT [dbo].[DOAN] ([MaDoAn], [Ten], [Gia], [DonVi], [MoTa]) VALUES (N'N006', N'Bơ', 10000.0000, N'Hộp', N'Đồ ăn kèm')
INSERT [dbo].[DONDH] ([MaDonDat], [NgayDat], [PThucTToan], [MaNhaCc], [MaNV]) VALUES (N'D001', CAST(N'2021-01-05' AS Date), N'Tiền mặt', N'C001', N'NV003')
INSERT [dbo].[DONDH] ([MaDonDat], [NgayDat], [PThucTToan], [MaNhaCc], [MaNV]) VALUES (N'D002', CAST(N'2002-05-06' AS Date), N'Tiền mặt', N'C002', N'NV003')
INSERT [dbo].[DONDH] ([MaDonDat], [NgayDat], [PThucTToan], [MaNhaCc], [MaNV]) VALUES (N'D003', CAST(N'2021-05-09' AS Date), N'Tiền mặt', N'C003', N'NV004')
INSERT [dbo].[DONDH] ([MaDonDat], [NgayDat], [PThucTToan], [MaNhaCc], [MaNV]) VALUES (N'D004', CAST(N'2021-05-15' AS Date), N'Chuyển khoản', N'C004', N'NV004')
INSERT [dbo].[DONDH] ([MaDonDat], [NgayDat], [PThucTToan], [MaNhaCc], [MaNV]) VALUES (N'D005', CAST(N'2021-05-20' AS Date), N'Tiền mặt', N'C005', N'NV004')
INSERT [dbo].[DONDH] ([MaDonDat], [NgayDat], [PThucTToan], [MaNhaCc], [MaNV]) VALUES (N'D006', CAST(N'2021-05-25' AS Date), N'Tiền mặt', N'C006', N'NV003')
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H001', CAST(N'2021-05-01' AS Date), N'NV008', N'K001', 10)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H002', CAST(N'2021-05-01' AS Date), N'NV008', N'K002', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H003', CAST(N'2021-05-01' AS Date), N'NV006', N'K003', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H004', CAST(N'2021-05-01' AS Date), N'NV008', N'K004', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H005', CAST(N'2021-05-01' AS Date), N'NV006', N'K005', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H006', CAST(N'2021-05-01' AS Date), N'NV007', N'K006', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H007', CAST(N'2021-05-09' AS Date), N'NV002', N'K007', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H008', CAST(N'2021-05-09' AS Date), N'NV007', N'K008', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H009', CAST(N'2021-05-09' AS Date), N'NV006', N'K009', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H010', CAST(N'2021-05-10' AS Date), N'NV002', N'K010', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H011', CAST(N'2021-05-14' AS Date), N'NV002', N'K011', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H012', CAST(N'2021-05-14' AS Date), N'NV005', N'K012', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H013', CAST(N'2021-05-14' AS Date), N'NV005', N'K013', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H014', CAST(N'2021-05-14' AS Date), N'NV010', N'K014', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H015', CAST(N'2021-05-15' AS Date), N'NV010', N'K015', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H016', CAST(N'2021-05-16' AS Date), N'NV002', N'K004', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H017', CAST(N'2021-05-20' AS Date), N'NV008', N'K005', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H018', CAST(N'2021-05-20' AS Date), N'NV008', N'K006', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H019', CAST(N'2021-05-20' AS Date), N'NV006', N'K007', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H020', CAST(N'2021-05-20' AS Date), N'NV008', N'K008', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H021', CAST(N'2021-05-21' AS Date), N'NV006', N'K021', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H022', CAST(N'2021-05-26' AS Date), N'NV007', N'K022', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H023', CAST(N'2021-05-26' AS Date), N'NV002', N'K023', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H024', CAST(N'2021-05-26' AS Date), N'NV007', N'K009', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H025', CAST(N'2021-05-26' AS Date), N'NV006', N'K010', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H026', CAST(N'2021-05-28' AS Date), N'NV002', N'K011', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H027', CAST(N'2021-05-28' AS Date), N'NV002', N'K012', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H028', CAST(N'2021-05-28' AS Date), N'NV005', N'K005', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H029', CAST(N'2021-05-29' AS Date), N'NV005', N'K006', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H030', CAST(N'2021-05-30' AS Date), N'NV010', N'K007', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H031', CAST(N'2021-05-30' AS Date), N'NV010', N'K008', 0)
INSERT [dbo].[DONHANG] ([MaDH], [NgayDat], [MaNV], [MaKH], [Giam]) VALUES (N'H032', CAST(N'2021-05-30' AS Date), N'NV002', N'K009', 0)
INSERT [dbo].[HETHONG] ([TenTk], [MatKhau], [MaNV]) VALUES (N'nv001', N'123456', N'NV001')
INSERT [dbo].[HETHONG] ([TenTk], [MatKhau], [MaNV]) VALUES (N'nv002', N'123456', N'NV002')
INSERT [dbo].[HETHONG] ([TenTk], [MatKhau], [MaNV]) VALUES (N'nv003', N'123456', N'NV003')
INSERT [dbo].[HETHONG] ([TenTk], [MatKhau], [MaNV]) VALUES (N'nv004', N'123456', N'NV004')
INSERT [dbo].[HETHONG] ([TenTk], [MatKhau], [MaNV]) VALUES (N'nv005', N'123456', N'NV005')
INSERT [dbo].[HETHONG] ([TenTk], [MatKhau], [MaNV]) VALUES (N'nv006', N'123456', N'NV006')
INSERT [dbo].[HETHONG] ([TenTk], [MatKhau], [MaNV]) VALUES (N'nv007', N'123456', N'NV007')
INSERT [dbo].[HETHONG] ([TenTk], [MatKhau], [MaNV]) VALUES (N'nv008', N'123456', N'NV008')
INSERT [dbo].[HETHONG] ([TenTk], [MatKhau], [MaNV]) VALUES (N'nv009', N'123456', N'NV009')
INSERT [dbo].[HETHONG] ([TenTk], [MatKhau], [MaNV]) VALUES (N'nv010', N'123456', N'NV010')
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K001', N'Trần Minh Long', N'915616751', N'306 Xã Đàn, Đống Đa, Hà Nội', 11)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K002', N'Lê Nhật Minh', N'983650681', N'123 Nguyễn Chí Thanh, Ba Đình, Hà Nội', 5)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K003', N'Lê Hoài Thương', N'912174015', N'24 Hồ Tùng Mậu, Cầu Giấy, Hà Nội', 7)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K004', N'Nguyễn Văn Tâm', N'914754316', N'1 Đại Cồ Việt, Hai Bà Trưng, Hà Nội', 6)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K005', N'Phan Thị Thanh', N'945895806', N'96 Hoàng Cầu, Đống Đa, Hà Nội', 8)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K006', N'Lê Hà Vinh', N'982487263', N'Khương Trung, Thanh Xuân, Hà Nội', 2)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K007', N'Nguyễn Đức Minh', N'978526488', N'Vĩnh Phúc, Quận Ba Đình - Hà Nội', 0)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K008', N'Trần Văn Nguyên', N'972603304', N'Đại Kim, Hoàng Mai, Hà Nội', 12)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K009', N'Nguyễn Văn Long', N'336592576', N'Ô Chợ Dừa, Đống Đa, Hà Nội', 5)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K010', N'Phạm Việt Hưng', N'912287516', N'Ngọc Hồi, Hoàng Liệt, Hoàng Mai, Hà Nội', 3)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K011', N'Lê Hoàng Thịnh', N'375443726', N'Ngô Gia Tự, Đức Giang, Long Biên, Hà Nội', 3)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K012', N'Nguyễn Tài Hoàng', N'974517627', N'Phường Minh Khai, Bắc Từ Liêm, Hà Nội', 2)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K013', N'Khổng Trường Thịnh', N'868125032', N'Thượng Cát, Bắc Từ Liêm, Hà Nội', 6)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K014', N'Trần Quang Diệu', N'1239262359', N'BTL Pháo Binh, Vĩnh Phúc, Ba Đình, Hà Nội', 4)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K015', N'Nguyễn Trung Kiên', N'884720904', N'P105 TT Bộ Tư pháp Cống Vị, Ba Đình, Hà Nội', 5)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K016', N'Bùi Ngọc Bách', N'946261017', N' Vĩnh Tuy, Hai Bà Trưng, Hà Nội', 0)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K017', N'Đinh Hải Năm', N'1633812869', N'Văn Chương, Đống Đa, Hà Nội', 1)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K018', N'Phùng Đăng Tùng', N'1654178466', N'Láng Hạ, Đống Đa, Hà Nội', 1)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K019', N'Nguyễn Văn Hòa', N'2886962834', N'126 Hào Nam, Ô Chợ Dừa, Đống Đa, Hà Nội', 1)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K020', N'Trần Phương Đông', N'964931967', N'235 Yên Hòa, Cầu Giấy, Hà Nội', 1)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K021', N'Lưu Bá Dũng', N'1228286115', N'Quang Tiến, Sóc Sơn, Hà Nội', 0)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K022', N'Lương Ngọc Minh', N'983953287', N'Tổ 6, Mộ Lao, Hà Đông, Hà Nội', 0)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K023', N'Nguyễn Trung Hiếu', N'3984728592', N'Số 48B A19 Nghĩa Tân, Cầu Giấy, Hà Nội', 0)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K024', N'Phạm Thế Thiện', N'979376308', N'Số 9, Khuất Duy Tiến, Thanh Xuân, Hà Nội', 2)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K025', N'Nguyễn Mai Phương', N'1692309126', N'Thụy Phương, Bắc Từ Liêm, Hà Nội', 2)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K026', N'Nguyễn Thành Nam', N'912139874', N'TDP Trung 8, Tây Tựu, Bắc Từ Liêm, Hà Nội', 4)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K027', N'Phạm Ngọc Đạt', N'2878797548', N'Thượng 4, Tây Tựu, Bắc Từ Liêm, Hà Nội', 4)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K028', N'Vũ Minh ChÂu', N'1669261070', N'41 Hoàng Hoa Thám, Ngọc Hà, Ba Đình, Hà Nội', 2)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K029', N'Nguyễn Sỹ Quân', N'1688856286', N'tổ 32, Hoàng Văn Thụ, Hoàng Mai, Hà Nội', 6)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K030', N'Võ Bá Linh', N'1253897899', N'390 Tây Mỗ, Nam Từ Liêm, Hà Nội', 4)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K031', N'Vũ Minh Hiếu', N'984440729', N'Tả Thanh Oai, Thanh Trì, Hà Nội,', 2)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K032', N'Nguyễn Đức Duy', N'987483933', N'CT12 Văn Phú, Hà Đông, Hà Nội', 4)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K033', N'Phạm Tiến Đạt', N'984454794', N'Thụy Phương, Đông Ngạc, Bắc Từ Liêm, Hà Nội', 3)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K034', N'Lê Văn Thành ', N'986314662', N'61/7 Lạc Trung, Vĩnh Tuy, Hai Bà Trưng, Hà Nội', 2)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K035', N'Phan Trọng Vĩnh', N'1649423019', N'Thôn 3, Vạn Phúc, Thanh Trì, Hà Nội', 3)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K036', N'Lê Nhật Tân', N'1667883740', N'55/38 Hoàng Hoa Thám, Ngọc Hà, Ba Đình, Hà Nội', 3)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K037', N'Lê Minh Đăng', N'1679076609', N'63 Thái Thịnh, Đống Đa, Hà Nội', 5)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K038', N'Lương Minh Hiếu', N'914611223', N'Mễ Trì Hạ, Mỹ Đình, Nam Từ Liêm, Hà Nội', 2)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K039', N'Hoàng Tuấn Tài', N'1648358664', N'1194/63 Láng, Đống Đa, Hà Nội', 2)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K040', N'Phạm Hiếu Quảng', N'1662936075', N'19 Hoàng Ngọc Phách, Láng Hạ, Đống Đa, Hà Nội', 1)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K041', N'Trần Văn Sơn', N'1273007580', N'Số 10 Mỹ Đình 2, Nam Từ Liêm, Hà Nội', 0)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K042', N'Nguyễn Tuấn Trung', N'979776207', N'397/7 Phạm Văn Đồng, Bắc Từ Liêm, Hà Nội', 0)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K043', N'Trần Vũ Quang', N'1659889157', N'32 Tây Mỗ, Nam Từ Liêm, Hà Nội', 7)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K044', N'Đặng Phương Nam', N'1697499577', N'Cáo Đỉnh 1, Xuân Đỉnh, Bắc Từ Liêm, Hà Nội', 5)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K045', N'Trần Tuấn Minh', N'936814242', N'12 Quán Thánh, Ba Đình, Hà Nội', 5)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K046', N'Lý Đức Trung', N'922728688', N'Xuân Kì, Đông Xuân, Sóc Sơn, Hà Nội', 5)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K047', N'Trần Minh Đức', N'989667507', N'45 Quán Thánh, Ba Đình, Hà Nội', 5)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K048', N'Đỗ Anh Đạt', N'1629564969', N'Tổ DP1, Văn Quán, Hà Đông, Hà Nội', 3)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K049', N'Trần Sỹ Đô', N'983098968', N'180 cụm 1, Thọ Xuân, Đan Phượng, Hà Nội', 2)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K050', N'Lê Trí Đức', N'986649566', N' Gia Vĩnh, Thanh Thùy, Thanh Oai, Hà Nội', 4)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K051', N'Nguyễn Văn Đức', N'903232432', N'Tê Quả, Tam Hưng, Thanh Oai, Hà Nội', 6)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K052', N'Trần Thị Hiền', N'913270497', N'Quang Trung, Phương Trung, Thanh Oai, Hà Nội', 2)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K053', N'Nguyễn Quang Trường', N'1682640759', N'Số 17 Thanh Mai, Thanh Oai, Hà Nội', 0)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K054', N'Lê Thị Thu Hồng', N'936964386', N'ChÂu Mai 5, Liên ChÂu, Thanh Oai, Hà Nội', 0)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K055', N'Vũ Quốc Huy', N'986634613', N'Số nhà 47, thôn Hạ, Cự Khê, Thanh Oai, Hà Nội', 1)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K056', N'Vũ Thành Huy', N'915058357', N'76 Giải Phóng, Đống Đa, Hà Nội', 3)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K057', N'Trương Ngọc Huyền', N'1636493061', N'134 Trường Chinh, Thanh Xuân, Hà Nội', 6)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K058', N'Phan Ngọc Hưng', N'965532190', N'355 Minh Khai, Hai Bà Trưng, Hà Nội', 3)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K059', N'Lữ Thị Hương', N'916856299', N'105 Cầu Giấy, Hà Nội', 5)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K060', N'Nguyễn Thế Kiên', N'1235802311', N'897 Giải Phóng, Hoàng Mai, Hà Nội', 2)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K061', N'Trần Trung Kiên', N'989116899', N'104 Hàng Buồm, Hoàn Kiếm, Hà Nội', 3)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K062', N'Lê Thị Ngọc Khánh', N'247381737', N'314 Hào Nam, Ô Chợ Dừa, Đống Đa, Hà Nội', 0)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K063', N'Nguyễn Văn Lâm', N'962055659', N'1533 Yên Hòa, Cầu Giấy, Hà Nội', 0)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K064', N'Vũ Tiến Lâm', N'977991363', N'27 Quang Tiến, Sóc Sơn, Hà Nội', 4)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K065', N'Đặng Thị Mỹ Linh', N'1677164454', N'Tổ 8, Mộ Lao, Hà Đông, Hà Nội', 2)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K066', N'Nguyễn Phương Khánh Linh', N'945849668', N'Số 48 Nghĩa Tân, Cầu Giấy, Hà Nội', 5)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K067', N'Trần Thị Gia Linh', N'1654533770', N'Số 25 Khuất Duy Tiến, Thanh Xuân, Hà Nội', 8)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K068', N'Nguyễn Hoàng Long', N'983132237', N'28 Thụy Phương, Bắc Từ Liêm, Hà Nội', 9)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K069', N'Hoàng Thanh Mai', N'1664403318', N'24 Tây Tựu, Bắc Từ Liêm, Hà Nội', 7)
INSERT [dbo].[KHACHHANG] ([MaKH], [HoTen], [Sdt], [DiaChi], [Diem]) VALUES (N'K070', N'Trần Thị Hoa Mỹ', N'2384829982', N'Thượng 8, Tây Tựu, Bắc Từ Liêm, Hà Nội', 5)
INSERT [dbo].[LUONG] ([Thang], [SoDipLe]) VALUES (CAST(N'2021-01-01' AS Date), 2)
INSERT [dbo].[LUONG] ([Thang], [SoDipLe]) VALUES (CAST(N'2021-02-01' AS Date), 3)
INSERT [dbo].[LUONG] ([Thang], [SoDipLe]) VALUES (CAST(N'2021-03-01' AS Date), 0)
INSERT [dbo].[LUONG] ([Thang], [SoDipLe]) VALUES (CAST(N'2021-04-01' AS Date), 2)
INSERT [dbo].[LUONG] ([Thang], [SoDipLe]) VALUES (CAST(N'2021-05-01' AS Date), 2)
INSERT [dbo].[LUONG] ([Thang], [SoDipLe]) VALUES (CAST(N'2021-06-01' AS Date), 0)
INSERT [dbo].[LUONG] ([Thang], [SoDipLe]) VALUES (CAST(N'2021-07-01' AS Date), 1)
INSERT [dbo].[LUONG] ([Thang], [SoDipLe]) VALUES (CAST(N'2021-08-01' AS Date), 0)
INSERT [dbo].[LUONG] ([Thang], [SoDipLe]) VALUES (CAST(N'2021-09-01' AS Date), 2)
INSERT [dbo].[LUONG] ([Thang], [SoDipLe]) VALUES (CAST(N'2021-10-01' AS Date), 1)
INSERT [dbo].[LUONG] ([Thang], [SoDipLe]) VALUES (CAST(N'2021-11-01' AS Date), 0)
INSERT [dbo].[LUONG] ([Thang], [SoDipLe]) VALUES (CAST(N'2021-12-01' AS Date), 2)
INSERT [dbo].[MATHANG] ([MaMatHang], [Ten], [TongSLuong], [DonVi]) VALUES (N'D001', N'Bia Hà Nội', 56, N'Lon')
INSERT [dbo].[MATHANG] ([MaMatHang], [Ten], [TongSLuong], [DonVi]) VALUES (N'D002', N'Bia Sài Gòn', 66, N'Lon')
INSERT [dbo].[MATHANG] ([MaMatHang], [Ten], [TongSLuong], [DonVi]) VALUES (N'D004', N'Strongbow', 40, N'Chai')
INSERT [dbo].[MATHANG] ([MaMatHang], [Ten], [TongSLuong], [DonVi]) VALUES (N'D005', N'Coca', 0, N'Chai')
INSERT [dbo].[MATHANG] ([MaMatHang], [Ten], [TongSLuong], [DonVi]) VALUES (N'D006', N'Fanta', 82, N'Chai')
INSERT [dbo].[MATHANG] ([MaMatHang], [Ten], [TongSLuong], [DonVi]) VALUES (N'D007', N'Chanh muối', 67, N'Chai')
INSERT [dbo].[MATHANG] ([MaMatHang], [Ten], [TongSLuong], [DonVi]) VALUES (N'D008', N'Bò húc', 78, N'Lon')
INSERT [dbo].[MATHANG] ([MaMatHang], [Ten], [TongSLuong], [DonVi]) VALUES (N'D009', N'Rượu', 0, N'Chai')
INSERT [dbo].[MATHANG] ([MaMatHang], [Ten], [TongSLuong], [DonVi]) VALUES (N'D010', N'Sprite', 68, N'Chai')
INSERT [dbo].[MATHANG] ([MaMatHang], [Ten], [TongSLuong], [DonVi]) VALUES (N'N001', N'Viên', 5.3, N'kg')
INSERT [dbo].[MATHANG] ([MaMatHang], [Ten], [TongSLuong], [DonVi]) VALUES (N'N002', N'Ba chỉ bò Mỹ', 6.9, N'kg')
INSERT [dbo].[MATHANG] ([MaMatHang], [Ten], [TongSLuong], [DonVi]) VALUES (N'N003', N'Sườn sụn', 10, N'kg')
INSERT [dbo].[MATHANG] ([MaMatHang], [Ten], [TongSLuong], [DonVi]) VALUES (N'N004', N'Bạch tuộc', 7.1, N'kg')
INSERT [dbo].[MATHANG] ([MaMatHang], [Ten], [TongSLuong], [DonVi]) VALUES (N'N005', N'Chân gà', 6.8, N'kg')
INSERT [dbo].[MATHANG] ([MaMatHang], [Ten], [TongSLuong], [DonVi]) VALUES (N'N006', N'Mực', 5.6, N'kg')
INSERT [dbo].[MATHANG] ([MaMatHang], [Ten], [TongSLuong], [DonVi]) VALUES (N'N007', N'Nem chua ', 0, N'kg')
INSERT [dbo].[MATHANG] ([MaMatHang], [Ten], [TongSLuong], [DonVi]) VALUES (N'N008', N'Khoai tây', 10.5, N'kg')
INSERT [dbo].[MATHANG] ([MaMatHang], [Ten], [TongSLuong], [DonVi]) VALUES (N'N009', N'Fomai', 4.8, N'kg')
INSERT [dbo].[MATHANG] ([MaMatHang], [Ten], [TongSLuong], [DonVi]) VALUES (N'N010', N'Sốt Hàn Quốc', 3600, N'ml')
INSERT [dbo].[MATHANG] ([MaMatHang], [Ten], [TongSLuong], [DonVi]) VALUES (N'N011', N'Sốt Tứ Xuyên', 4000, N'ml')
INSERT [dbo].[MATHANG] ([MaMatHang], [Ten], [TongSLuong], [DonVi]) VALUES (N'N012', N'Nấm', 20, N'Gói')
INSERT [dbo].[MATHANG] ([MaMatHang], [Ten], [TongSLuong], [DonVi]) VALUES (N'N013', N'Sa tế', 0, N'Lọ')
INSERT [dbo].[MATHANG] ([MaMatHang], [Ten], [TongSLuong], [DonVi]) VALUES (N'N014', N'Bò Mĩ', 5, N'kg')
INSERT [dbo].[NHACC] ([MaNhaCc], [HoTen], [Sdt], [DiaChi]) VALUES (N'C001', N'Lê Minh Trí', N'0123495487', N'76 Giải Phóng, Đống Đa, Hà Nội')
INSERT [dbo].[NHACC] ([MaNhaCc], [HoTen], [Sdt], [DiaChi]) VALUES (N'C002', N'Trần Minh Thạch', N'0334526738', N'134 Trường Chinh, Thanh Xuân, Hà Nội')
INSERT [dbo].[NHACC] ([MaNhaCc], [HoTen], [Sdt], [DiaChi]) VALUES (N'C003', N'Hồng Phương', N'0366456785', N'355 Minh Khai, Hai Bà Trưng, Hà Nội')
INSERT [dbo].[NHACC] ([MaNhaCc], [HoTen], [Sdt], [DiaChi]) VALUES (N'C004', N'Nhật Thắng', N'0912267834', N'105 Cầu Giấy, Hà Nội')
INSERT [dbo].[NHACC] ([MaNhaCc], [HoTen], [Sdt], [DiaChi]) VALUES (N'C005', N'Lưu Nguyệt Quế', N'0135667243', N'897 Giải Phóng, Hoàng Mai, Hà Nội')
INSERT [dbo].[NHACC] ([MaNhaCc], [HoTen], [Sdt], [DiaChi]) VALUES (N'C006', N'Cao Minh Trung', N'0924621944', N'104 Hàng Buồm, Hoàn Kiếm, Hà Nội')
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTen], [Sdt], [DiaChi], [GioiTinh], [ChucVu], [NgaySinh], [NgayVaoLam], [CCCD], [QuanLy]) VALUES (N'NV001', N'Đào T.Phương Nga', N'0978581891
', N'Đống Đa, Hà Nội', N'Nữ', N'Đầu bếp', CAST(N'1994-08-15' AS Date), CAST(N'2020-03-04' AS Date), N'33301001333', N'NV003')
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTen], [Sdt], [DiaChi], [GioiTinh], [ChucVu], [NgaySinh], [NgayVaoLam], [CCCD], [QuanLy]) VALUES (N'NV002', N'Kiều T.Kim Ngân', N'0946665089
', N'Hoàng Mai, Hà Nội', N'Nữ', N'NV phục vụ', CAST(N'1999-08-05' AS Date), CAST(N'2020-04-05' AS Date), N'32100066645', N'NV004')
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTen], [Sdt], [DiaChi], [GioiTinh], [ChucVu], [NgaySinh], [NgayVaoLam], [CCCD], [QuanLy]) VALUES (N'NV003', N'Vũ Trọng Nghĩa', N'0869984922

', N'Ba Đình, Hà Nội', N'Nam', N'Quản lý', CAST(N'1985-02-13' AS Date), NULL, N'30400023412', NULL)
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTen], [Sdt], [DiaChi], [GioiTinh], [ChucVu], [NgaySinh], [NgayVaoLam], [CCCD], [QuanLy]) VALUES (N'NV004', N'Phạm Thanh Nhã', N'0945642762
', N'Ba Đình, Hà Nội', N'Nữ', N'Quản lý', CAST(N'1986-03-15' AS Date), CAST(N'2020-06-01' AS Date), N'30500036623', NULL)
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTen], [Sdt], [DiaChi], [GioiTinh], [ChucVu], [NgaySinh], [NgayVaoLam], [CCCD], [QuanLy]) VALUES (N'NV005', N'Nguyễn Văn Quân', N'01654925127
', N'Hoàng Mai, Hà Nội', N'Nam', N'NV phục vụ', CAST(N'1999-03-25' AS Date), CAST(N'2020-08-20' AS Date), N'34938723819', N'NV004')
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTen], [Sdt], [DiaChi], [GioiTinh], [ChucVu], [NgaySinh], [NgayVaoLam], [CCCD], [QuanLy]) VALUES (N'NV006', N'Chu Hồng Quý', N'0962768166
', N'Cầu Giấy, Hà Nội', N'Nam', N'NV phục vụ', CAST(N'2000-11-23' AS Date), CAST(N'2020-04-04' AS Date), N'42939491934', N'NV004')
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTen], [Sdt], [DiaChi], [GioiTinh], [ChucVu], [NgaySinh], [NgayVaoLam], [CCCD], [QuanLy]) VALUES (N'NV007', N'Vũ Phong Quý', N'01642819540
', N'Cầu Giấy, Hà Nội', N'Nam', N'NV phục vụ', CAST(N'1999-09-20' AS Date), CAST(N'2020-04-06' AS Date), N'30049193848', N'NV004')
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTen], [Sdt], [DiaChi], [GioiTinh], [ChucVu], [NgaySinh], [NgayVaoLam], [CCCD], [QuanLy]) VALUES (N'NV008', N'Phạm Xuân Sang', N'01667257395
', N'Ba Đình, Hà Nội', N'Nam', N'NV phục vụ', CAST(N'2000-01-24' AS Date), CAST(N'2020-03-03' AS Date), N'30381934190', N'NV004')
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTen], [Sdt], [DiaChi], [GioiTinh], [ChucVu], [NgaySinh], [NgayVaoLam], [CCCD], [QuanLy]) VALUES (N'NV009', N'Vũ Mạnh Tiền', N'0969188684
', N'Ba Đình, Hà Nội', N'Nam', N'Đầu bếp', CAST(N'1993-07-31' AS Date), CAST(N'2020-03-30' AS Date), N'42039310348', N'NV003')
INSERT [dbo].[NHANVIEN] ([MaNV], [HoTen], [Sdt], [DiaChi], [GioiTinh], [ChucVu], [NgaySinh], [NgayVaoLam], [CCCD], [QuanLy]) VALUES (N'NV010', N'Nguyễn Minh Tú', N'01634949285
', N'Hai Bà Trưng, Hà Nội', N'Nam', N'NV phục vụ', CAST(N'2000-02-18' AS Date), CAST(N'2020-04-07' AS Date), N'3030310348', N'NV003')
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P001', N'H001', N'K001', 5, 5, 5, 5, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P002', N'H002', N'K002', 4, 4, 4, 4, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P003', N'H003', N'K003', 5, 5, 3, 5, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P004', N'H004', N'K004', 5, 4, 5, 5, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P005', N'H005', N'K005', 4, 2, 4, 4, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P006', N'H006', N'K006', 5, 3, 5, 5, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P007', N'H007', N'K007', 4, 5, 4, 4, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P008', N'H008', N'K008', 5, 3, 3, 5, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P009', N'H009', N'K009', 5, 4, 5, 5, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P010', N'H010', N'K010', 4, 3, 4, 4, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P011', N'H011', N'K011', 4, 5, 4, 4, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P012', N'H012', N'K012', 5, 4, 4, 5, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P013', N'H013', N'K001', 5, 3, 3, 5, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P014', N'H014', N'K002', 5, 5, 5, 5, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P015', N'H015', N'K003', 5, 4, 5, 5, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P016', N'H016', N'K004', 5, 3, 3, 5, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P017', N'H017', N'K005', 4, 4, 4, 4, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P018', N'H018', N'K006', 5, 5, 5, 5, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P019', N'H019', N'K007', 4, 4, 4, 4, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P020', N'H020', N'K008', 5, 3, 3, 5, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P021', N'H021', N'K021', 4, 4, 4, 4, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P022', N'H022', N'K022', 5, 5, 5, 5, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P023', N'H023', N'K023', 5, 3, 5, 5, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P024', N'H024', N'K024', 4, 4, 3, 4, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P025', N'H025', N'K025', 5, 5, 5, 5, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P026', N'H026', N'K026', 5, 4, 5, 5, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P027', N'H027', N'K027', 4, 3, 3, 4, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P028', N'H028', N'K028', 5, 5, 5, 5, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P029', N'H029', N'K029', 4, 4, 4, 4, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P030', N'H030', N'K030', 5, 5, 5, 5, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P031', N'H031', N'K031', 5, 4, 3, 5, NULL)
INSERT [dbo].[PHIEUDANHGIA] ([SoPhieu], [MaDH], [MaKH], [DoAn], [PhucVu], [Gia], [CSVC], [NXet]) VALUES (N'P032', N'H032', N'K032', 4, 3, 4, 4, NULL)
INSERT [dbo].[PHIEUNHAP] ([SoPhieu], [NgayNhap], [MaDonDat], [MaNV]) VALUES (N'P001', CAST(N'2021-05-01' AS Date), N'D001', N'NV002')
INSERT [dbo].[PHIEUNHAP] ([SoPhieu], [NgayNhap], [MaDonDat], [MaNV]) VALUES (N'P002', CAST(N'2021-05-05' AS Date), N'D002', N'NV002')
INSERT [dbo].[PHIEUNHAP] ([SoPhieu], [NgayNhap], [MaDonDat], [MaNV]) VALUES (N'P003', CAST(N'2021-05-09' AS Date), N'D003', N'NV005')
INSERT [dbo].[PHIEUNHAP] ([SoPhieu], [NgayNhap], [MaDonDat], [MaNV]) VALUES (N'P004', CAST(N'2021-05-15' AS Date), N'D004', N'NV007')
INSERT [dbo].[PHIEUNHAP] ([SoPhieu], [NgayNhap], [MaDonDat], [MaNV]) VALUES (N'P005', CAST(N'2021-05-20' AS Date), N'D005', N'NV008')
INSERT [dbo].[PHIEUNHAP] ([SoPhieu], [NgayNhap], [MaDonDat], [MaNV]) VALUES (N'P006', CAST(N'2021-05-25' AS Date), N'D006', N'NV005')
INSERT [dbo].[THANHTOAN] ([SoPhieu], [MaNhaCc], [MaNV], [NgayThanhToan]) VALUES (N'P001', N'C001', N'NV003', CAST(N'2021-04-30' AS Date))
INSERT [dbo].[THANHTOAN] ([SoPhieu], [MaNhaCc], [MaNV], [NgayThanhToan]) VALUES (N'P002', N'C002', N'NV003', CAST(N'2021-04-30' AS Date))
INSERT [dbo].[THANHTOAN] ([SoPhieu], [MaNhaCc], [MaNV], [NgayThanhToan]) VALUES (N'P003', N'C003', N'NV003', CAST(N'2021-05-30' AS Date))
INSERT [dbo].[THANHTOAN] ([SoPhieu], [MaNhaCc], [MaNV], [NgayThanhToan]) VALUES (N'P004', N'C004', N'NV004', CAST(N'2021-05-30' AS Date))
INSERT [dbo].[THANHTOAN] ([SoPhieu], [MaNhaCc], [MaNV], [NgayThanhToan]) VALUES (N'P005', N'C005', N'NV003', CAST(N'2021-05-30' AS Date))
INSERT [dbo].[THANHTOAN] ([SoPhieu], [MaNhaCc], [MaNV], [NgayThanhToan]) VALUES (N'P006', N'C006', N'NV004', CAST(N'2021-05-30' AS Date))
INSERT [dbo].[THANHTOAN] ([SoPhieu], [MaNhaCc], [MaNV], [NgayThanhToan]) VALUES (N'P007', N'C004', N'NV004', CAST(N'2021-05-30' AS Date))
INSERT [dbo].[THANHTOAN] ([SoPhieu], [MaNhaCc], [MaNV], [NgayThanhToan]) VALUES (N'P008', N'C005', N'NV003', CAST(N'2021-05-30' AS Date))
ALTER TABLE [dbo].[CAPNHATBAN]  WITH CHECK ADD  CONSTRAINT [FK_CAPNHATBAN_BAN] FOREIGN KEY([MaBan])
REFERENCES [dbo].[BAN] ([MaBan])
GO
ALTER TABLE [dbo].[CAPNHATBAN] CHECK CONSTRAINT [FK_CAPNHATBAN_BAN]
GO
ALTER TABLE [dbo].[CAPNHATBAN]  WITH CHECK ADD  CONSTRAINT [FK_CAPNHATBAN_NHANVIEN] FOREIGN KEY([MaNV])
REFERENCES [dbo].[NHANVIEN] ([MaNV])
GO
ALTER TABLE [dbo].[CAPNHATBAN] CHECK CONSTRAINT [FK_CAPNHATBAN_NHANVIEN]
GO
ALTER TABLE [dbo].[CTBAN]  WITH CHECK ADD  CONSTRAINT [FK_CTBAN_BAN] FOREIGN KEY([MaBan])
REFERENCES [dbo].[BAN] ([MaBan])
GO
ALTER TABLE [dbo].[CTBAN] CHECK CONSTRAINT [FK_CTBAN_BAN]
GO
ALTER TABLE [dbo].[CTBAN]  WITH CHECK ADD  CONSTRAINT [FK_CTBAN_DONHANG] FOREIGN KEY([MaDH])
REFERENCES [dbo].[DONHANG] ([MaDH])
GO
ALTER TABLE [dbo].[CTBAN] CHECK CONSTRAINT [FK_CTBAN_DONHANG]
GO
ALTER TABLE [dbo].[CTCALAM]  WITH CHECK ADD  CONSTRAINT [FK_CTCALAM_CALAMVIEC] FOREIGN KEY([Ngay])
REFERENCES [dbo].[CALAMVIEC] ([Ngay])
GO
ALTER TABLE [dbo].[CTCALAM] CHECK CONSTRAINT [FK_CTCALAM_CALAMVIEC]
GO
ALTER TABLE [dbo].[CTCALAM]  WITH CHECK ADD  CONSTRAINT [FK_CTCALAM_NHANVIEN] FOREIGN KEY([MaNV])
REFERENCES [dbo].[NHANVIEN] ([MaNV])
GO
ALTER TABLE [dbo].[CTCALAM] CHECK CONSTRAINT [FK_CTCALAM_NHANVIEN]
GO
ALTER TABLE [dbo].[CTCUNGCAP]  WITH CHECK ADD  CONSTRAINT [FK_CTCUNGCAP_MATHANG] FOREIGN KEY([MaMatHang])
REFERENCES [dbo].[MATHANG] ([MaMatHang])
GO
ALTER TABLE [dbo].[CTCUNGCAP] CHECK CONSTRAINT [FK_CTCUNGCAP_MATHANG]
GO
ALTER TABLE [dbo].[CTCUNGCAP]  WITH CHECK ADD  CONSTRAINT [FK_CTCUNGCAP_NHACC] FOREIGN KEY([MaNhaCc])
REFERENCES [dbo].[NHACC] ([MaNhaCc])
GO
ALTER TABLE [dbo].[CTCUNGCAP] CHECK CONSTRAINT [FK_CTCUNGCAP_NHACC]
GO
ALTER TABLE [dbo].[CTDOAN]  WITH CHECK ADD  CONSTRAINT [FK_CTDOAN_DOAN] FOREIGN KEY([MaDoAn])
REFERENCES [dbo].[DOAN] ([MaDoAn])
GO
ALTER TABLE [dbo].[CTDOAN] CHECK CONSTRAINT [FK_CTDOAN_DOAN]
GO
ALTER TABLE [dbo].[CTDOAN]  WITH CHECK ADD  CONSTRAINT [FK_CTDOAN_MATHANG] FOREIGN KEY([MaMatHang])
REFERENCES [dbo].[MATHANG] ([MaMatHang])
GO
ALTER TABLE [dbo].[CTDOAN] CHECK CONSTRAINT [FK_CTDOAN_MATHANG]
GO
ALTER TABLE [dbo].[CTDONDAT]  WITH CHECK ADD  CONSTRAINT [FK_CTDONDAT_DONDH] FOREIGN KEY([MaDonDat])
REFERENCES [dbo].[DONDH] ([MaDonDat])
GO
ALTER TABLE [dbo].[CTDONDAT] CHECK CONSTRAINT [FK_CTDONDAT_DONDH]
GO
ALTER TABLE [dbo].[CTDONDAT]  WITH CHECK ADD  CONSTRAINT [FK_CTDONDAT_MATHANG] FOREIGN KEY([MaMatHang])
REFERENCES [dbo].[MATHANG] ([MaMatHang])
GO
ALTER TABLE [dbo].[CTDONDAT] CHECK CONSTRAINT [FK_CTDONDAT_MATHANG]
GO
ALTER TABLE [dbo].[CTDONHANG]  WITH CHECK ADD  CONSTRAINT [FK_CTDONHANG_DOAN] FOREIGN KEY([MaDoAn])
REFERENCES [dbo].[DOAN] ([MaDoAn])
GO
ALTER TABLE [dbo].[CTDONHANG] CHECK CONSTRAINT [FK_CTDONHANG_DOAN]
GO
ALTER TABLE [dbo].[CTDONHANG]  WITH CHECK ADD  CONSTRAINT [FK_CTDONHANG_DONHANG] FOREIGN KEY([MaDH])
REFERENCES [dbo].[DONHANG] ([MaDH])
GO
ALTER TABLE [dbo].[CTDONHANG] CHECK CONSTRAINT [FK_CTDONHANG_DONHANG]
GO
ALTER TABLE [dbo].[CTLUONG]  WITH CHECK ADD  CONSTRAINT [FK_CTLUONG_LUONG] FOREIGN KEY([Thang])
REFERENCES [dbo].[LUONG] ([Thang])
GO
ALTER TABLE [dbo].[CTLUONG] CHECK CONSTRAINT [FK_CTLUONG_LUONG]
GO
ALTER TABLE [dbo].[CTLUONG]  WITH CHECK ADD  CONSTRAINT [FK_CTLUONG_NHANVIEN] FOREIGN KEY([MaNV])
REFERENCES [dbo].[NHANVIEN] ([MaNV])
GO
ALTER TABLE [dbo].[CTLUONG] CHECK CONSTRAINT [FK_CTLUONG_NHANVIEN]
GO
ALTER TABLE [dbo].[CTNHAP]  WITH CHECK ADD  CONSTRAINT [FK_CTNHAP_MATHANG] FOREIGN KEY([MaMatHang])
REFERENCES [dbo].[MATHANG] ([MaMatHang])
GO
ALTER TABLE [dbo].[CTNHAP] CHECK CONSTRAINT [FK_CTNHAP_MATHANG]
GO
ALTER TABLE [dbo].[CTNHAP]  WITH CHECK ADD  CONSTRAINT [FK_CTNHAP_PHIEUNHAP] FOREIGN KEY([SoPhieu])
REFERENCES [dbo].[PHIEUNHAP] ([SoPhieu])
GO
ALTER TABLE [dbo].[CTNHAP] CHECK CONSTRAINT [FK_CTNHAP_PHIEUNHAP]
GO
ALTER TABLE [dbo].[CTTHANHTOAN]  WITH CHECK ADD  CONSTRAINT [FK_CTTHANHTOAN_DONDH] FOREIGN KEY([MaDonDat])
REFERENCES [dbo].[DONDH] ([MaDonDat])
GO
ALTER TABLE [dbo].[CTTHANHTOAN] CHECK CONSTRAINT [FK_CTTHANHTOAN_DONDH]
GO
ALTER TABLE [dbo].[CTTHANHTOAN]  WITH CHECK ADD  CONSTRAINT [FK_CTTHANHTOAN_THANHTOAN] FOREIGN KEY([SoPhieu])
REFERENCES [dbo].[THANHTOAN] ([SoPhieu])
GO
ALTER TABLE [dbo].[CTTHANHTOAN] CHECK CONSTRAINT [FK_CTTHANHTOAN_THANHTOAN]
GO
ALTER TABLE [dbo].[DATBAN]  WITH CHECK ADD  CONSTRAINT [FK_DATBAN_KHACHHANG] FOREIGN KEY([MaKH])
REFERENCES [dbo].[KHACHHANG] ([MaKH])
GO
ALTER TABLE [dbo].[DATBAN] CHECK CONSTRAINT [FK_DATBAN_KHACHHANG]
GO
ALTER TABLE [dbo].[DONDH]  WITH CHECK ADD  CONSTRAINT [FK_DONDH_NHACC] FOREIGN KEY([MaNhaCc])
REFERENCES [dbo].[NHACC] ([MaNhaCc])
GO
ALTER TABLE [dbo].[DONDH] CHECK CONSTRAINT [FK_DONDH_NHACC]
GO
ALTER TABLE [dbo].[DONDH]  WITH CHECK ADD  CONSTRAINT [FK_DONDH_NHANVIEN] FOREIGN KEY([MaNV])
REFERENCES [dbo].[NHANVIEN] ([MaNV])
GO
ALTER TABLE [dbo].[DONDH] CHECK CONSTRAINT [FK_DONDH_NHANVIEN]
GO
ALTER TABLE [dbo].[DONHANG]  WITH CHECK ADD  CONSTRAINT [FK_DONHANG_KHACHHANG] FOREIGN KEY([MaKH])
REFERENCES [dbo].[KHACHHANG] ([MaKH])
GO
ALTER TABLE [dbo].[DONHANG] CHECK CONSTRAINT [FK_DONHANG_KHACHHANG]
GO
ALTER TABLE [dbo].[DONHANG]  WITH CHECK ADD  CONSTRAINT [FK_DONHANG_NHANVIEN] FOREIGN KEY([MaNV])
REFERENCES [dbo].[NHANVIEN] ([MaNV])
GO
ALTER TABLE [dbo].[DONHANG] CHECK CONSTRAINT [FK_DONHANG_NHANVIEN]
GO
ALTER TABLE [dbo].[HETHONG]  WITH CHECK ADD  CONSTRAINT [FK_HETHONG_NHANVIEN] FOREIGN KEY([MaNV])
REFERENCES [dbo].[NHANVIEN] ([MaNV])
GO
ALTER TABLE [dbo].[HETHONG] CHECK CONSTRAINT [FK_HETHONG_NHANVIEN]
GO
ALTER TABLE [dbo].[PHIEUDANHGIA]  WITH CHECK ADD  CONSTRAINT [FK_PHIEUDANHGIA_DONHANG1] FOREIGN KEY([MaDH])
REFERENCES [dbo].[DONHANG] ([MaDH])
GO
ALTER TABLE [dbo].[PHIEUDANHGIA] CHECK CONSTRAINT [FK_PHIEUDANHGIA_DONHANG1]
GO
ALTER TABLE [dbo].[PHIEUDANHGIA]  WITH CHECK ADD  CONSTRAINT [FK_PHIEUDANHGIA_KHACHHANG] FOREIGN KEY([MaKH])
REFERENCES [dbo].[KHACHHANG] ([MaKH])
GO
ALTER TABLE [dbo].[PHIEUDANHGIA] CHECK CONSTRAINT [FK_PHIEUDANHGIA_KHACHHANG]
GO
ALTER TABLE [dbo].[PHIEUNHAP]  WITH CHECK ADD  CONSTRAINT [FK_PHIEUNHAP_DONDH] FOREIGN KEY([MaDonDat])
REFERENCES [dbo].[DONDH] ([MaDonDat])
GO
ALTER TABLE [dbo].[PHIEUNHAP] CHECK CONSTRAINT [FK_PHIEUNHAP_DONDH]
GO
ALTER TABLE [dbo].[PHIEUNHAP]  WITH CHECK ADD  CONSTRAINT [FK_PHIEUNHAP_NHANVIEN] FOREIGN KEY([MaNV])
REFERENCES [dbo].[NHANVIEN] ([MaNV])
GO
ALTER TABLE [dbo].[PHIEUNHAP] CHECK CONSTRAINT [FK_PHIEUNHAP_NHANVIEN]
GO
ALTER TABLE [dbo].[THANHTOAN]  WITH CHECK ADD  CONSTRAINT [FK_THANHTOAN_NHACC] FOREIGN KEY([MaNhaCc])
REFERENCES [dbo].[NHACC] ([MaNhaCc])
GO
ALTER TABLE [dbo].[THANHTOAN] CHECK CONSTRAINT [FK_THANHTOAN_NHACC]
GO
ALTER TABLE [dbo].[THANHTOAN]  WITH CHECK ADD  CONSTRAINT [FK_THANHTOAN_NHANVIEN] FOREIGN KEY([MaNV])
REFERENCES [dbo].[NHANVIEN] ([MaNV])
GO
ALTER TABLE [dbo].[THANHTOAN] CHECK CONSTRAINT [FK_THANHTOAN_NHANVIEN]
GO
USE [master]
GO
ALTER DATABASE [QLQuanAn2] SET  READ_WRITE 
GO
