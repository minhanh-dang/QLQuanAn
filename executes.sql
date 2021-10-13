--SP
exec tong_khachhang @NgayDat = '2021/05/01' --6
exec KiemTra_TK @TenTk = 'nv001', @MatKhau = '123456' --"Thông tin đăng nhập đúng"
exec KiemTra_TK @TenTk = 'nv001', @MatKhau = '12345' -- "Thông tin đăng nhập sai"
exec ChucVu @MaNV = 'NV003' --"Không phải là đầu bếp
exec ChucVu @MaNV = 'NV001' --"Là đầu bếp"
exec ChucVu @MaNV = 'NV011' -- Không tồn tại mã nhân viên
exec kiemtra_thongtin @MaNV = 'NV009' --"Tồn tại người dùng"
exec kiemtra_thongtin @MaNV = 'NV011' --"Không tồn tại người dùng"
exec Diachi_NV @MaNV = 'NV005' -- "Hoàng Mai, Hà Nội"
exec Diachi_NV @MaNV = 'NV011' -- "Không tồn tại nhân viên"
exec LuongNV @MaNV = "NV011", @Thang = '2021/5/1'
exec LuongNV @MaNV = "NV001", @Thang = '2021/5/1'
exec LuongNV @MaNV = "NV001", @Thang = '2021/12/1'
exec LuongNV @MaNV = "NV002", @Thang = '2021/5/1'
exec DoanhThu @NgayDat = '2021/5/1' 
exec SoLuong_Nhap @MaNV = 'NV011' -- "0"
exec SoLuong_Nhap @MaNV = 'NV002' -- Sai, ra kết quả là "0"
exec CungCap @MaNhaCc = 'C001', @MaMH = 'D001' --"Có cung cấp"
exec CungCap @MaNhaCc = 'C001', @MaMH = 'D003' --"Không cung cấp"
exec Tim_Sdt @MaKH = 'K006' --"982487263"

--UDF
select * from NgayMuaHang('2021/5/1')
select * from TuoiNV()
select * from SLuong_Nhap()
select * from SanPham ('2021/5/9')
select * from SanPham ('2021/9/5')
select * from PhucVu ('2021/5/3')
select * from PhucVu ('2021/5/14')
select * from GiaCaoNhat()
select * from LuongBanCao()
select * from DatTruoc() -- có thể đổi thành 1 ngày bất kỳ
select * from KiemKho()
select * from GiaCao()
print dbo.ThamNien('NV001')
print dbo.ThamNien('NV002')


