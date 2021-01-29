 --Truong hop can su dung View
 /*
 Tao mot bang ao de luu thong tin tuy bien 
 => Query ngan gon 
 => Select, tim kiem de
 */
 
 alter view V_ThongTinHoaDonBan
 as
 SELECT 
	 HD.SoHD,
	 KH.MaKhach,
	 KH.TenKhach,
	 KH.DienThoai,
	 KH.DiaChi,
	 HD.TongTien,
	 HD.DienGiai,
	 dbo.FN_DinhDangNgayVietNam(HD.NgayHD) NgayHD -- dinh dang ngay thang nam
 From HoaDon HD 
 inner join KhachHang KH 
 ON HD.MaKhach = KH.MaKhach

 select * from V_ThongTinHoaDonBan

 --Dung view trong thu tuc
create Proc HoaDon_TimKiemTheoKhach
@keyword nvarchar(100)
as
Select * from V_ThongTinHoaDonBan
where TenKhach like '%'+ @keyword+ '%' 
or MaKhach like '%'+ @keyword+ '%'

--goi thu tuc
exec HoaDon_TimKiemTheoKhach N'KH001'

--**********************************************************FUNCTION**********************************************************
--Khai bao cac ham thuc hien chuc nang
--tham so phai nam trong ngoac tron,
--phai co kieu tra ve returns
Create function FN_DinhDangNgayVietNam
(@InputDate datetime)
returns varchar(10)
as
	begin
		declare @result varchar(10)
		set @result = CONVERT(varchar(10), @InputDate, 103)
		return @result
	end


