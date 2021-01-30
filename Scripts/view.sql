 --Truong hop can su dung View
 /*
 Tao mot bang ao de luu thong tin tuy bien 
 => Query ngan gon 
 => Select, tim kiem de
 */
	 use QLBH
	 go
 
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

--Phan Trang (Chi tiet hoa don)
	CREATE PROC ChiTietHoaDon_SelectAll
	@pageIndex int, @pageSize int
	AS
	BEGIN
		DECLARE @fromIndex INT, @toIndex INT
		SET @fromIndex = (@pageIndex - 1) * @pageSize +1
		SET @toIndex = @pageIndex * @pageSize

		SELECT * FROM 
		(
			SELECT HD.SoHD, HD.NgayHD, HH.TenHang, HH.DVT, CT.SoLuong, CT.DonGia, CT.ThanhTien, 
			ROW_NUMBER() OVER(ORDER BY CT.ThanhTien DESC) RowIndex	
			FROM ChiTietHoaDon CT
			INNER JOIN HoaDon HD ON Hd.SoHD = CT.SoHD
			INNER JOIN HangHoa HH ON HH.MaHang = CT.MaHang
		) 
		AS TBL_DEMO
		WHERE RowIndex BETWEEN @fromIndex AND @toIndex
	END

	ChiTietHoaDon_SelectAll 2,2

--Phan Trang dung CTE (Common Table Expression) -- bang ao luu tru ket qua dung 1 lan
	CREATE PROC ChiTietHoaDon_SelectAllPagingCTE
	@pageIndex int, @pageSize int
	AS
	BEGIN
		DECLARE @fromIndex INT, @toIndex INT
		SET @fromIndex = (@pageIndex - 1) * @pageSize +1
		SET @toIndex = @pageIndex * @pageSize

		;WITH CTE_ChiTiet
		AS
		(
			SELECT HD.SoHD, HD.NgayHD, HH.TenHang, HH.DVT, CT.SoLuong, CT.DonGia, CT.ThanhTien, 
			ROW_NUMBER() OVER(ORDER BY CT.ThanhTien DESC) RowIndex	
			FROM ChiTietHoaDon CT
			INNER JOIN HoaDon HD ON Hd.SoHD = CT.SoHD
			INNER JOIN HangHoa HH ON HH.MaHang = CT.MaHang
		)
		SELECT * FROM CTE_ChiTiet 
		WHERE CTE_ChiTiet.RowIndex BETWEEN @fromIndex AND @toIndex
	END

	ChiTietHoaDon_SelectAllPagingCTE 2, 4

--Phan trang OFFSET, FETCH (Ap dung tu ban 2012)
	CREATE PROC ChiTietHoaDon_SelectAllPaging
	@pageIndex int, @pageSize int
	AS
	BEGIN
		DECLARE @fromIndex INT, @toIndex INT
		SET @fromIndex = (@pageIndex - 1) * @pageSize --khong cong them 1
		SET @toIndex = @pageIndex * @pageSize

		SELECT HD.SoHD, HD.NgayHD, HH.TenHang, HH.DVT, CT.SoLuong, CT.DonGia, CT.ThanhTien, 
		ROW_NUMBER() OVER(ORDER BY CT.ThanhTien DESC) RowIndex	
		FROM ChiTietHoaDon CT
		INNER JOIN HoaDon HD ON Hd.SoHD = CT.SoHD
		INNER JOIN HangHoa HH ON HH.MaHang = CT.MaHang
		ORDER BY CT.ThanhTien DESC 
		OFFSET @fromIndex ROWS
		FETCH NEXT @pageSize ROWS ONLY
	END

ChiTietHoaDon_SelectAllPaging 2,4

--Truy van dong (Thuc thi chuoi)
	ALTER PROC ChiTietHoaDon_SelectAllPagingDynamicQuery
	@pageIndex int, @pageSize int, @orderBy varchar(50)
	AS
	BEGIN
		DECLARE @fromIndex INT, @toIndex INT
		SET @fromIndex = (@pageIndex - 1) * @pageSize --khong cong them 1
		SET @toIndex = @pageIndex * @pageSize

		DECLARE @sql nvarchar(max) = 
			'SELECT HD.SoHD, HD.NgayHD, HH.TenHang, HH.DVT, CT.SoLuong, CT.DonGia, CT.ThanhTien, 
			ROW_NUMBER() OVER(ORDER BY ' + @orderBy + ' DESC) RowIndex	
			FROM ChiTietHoaDon CT
			INNER JOIN HoaDon HD ON Hd.SoHD = CT.SoHD
			INNER JOIN HangHoa HH ON HH.MaHang = CT.MaHang
			ORDER BY ' + @orderBy + ' DESC 
			OFFSET ' + CONVERT(varchar(20), @fromIndex) + ' ROWS
			FETCH NEXT ' + CONVERT(varchar(20), @pageSize) + ' ROWS ONLY'
		PRINT @sql
		EXECUTE(@sql)
		--EXCUTE sp_executesql @Sql --output
	END

	ChiTietHoaDon_SelectAllPagingDynamicQuery 1,4, 'TenHang'

--Cach dung con tro SQL
/*
 Muc dich
 Hien thi du lieu duoi dang KH01 - PhamCuong - 09883232 - HaiPhong
 => Phai duyet tung hang, xu ly tung hang
 B1. Khai bao con tro.
 B2. Khai bao cac bien de luu du lieu tung cot.
 B3. Mo con tro.
 B4. Lay du lieu.
 B5. Dong con tro.
 B6. Giai phong con tro.
*/

	DECLARE @MaKhach varchar(50), 
			@TenKhach nvarchar(50),
			@DienThoai varchar(50)

	DECLARE CurKH CURSOR
	FOR 
		SELECT MaKhach, TenKhach, DienThoai
		FROM KhachHang
	OPEN CurKH
	FETCH NEXT FROM curKH into @MaKhach, @TenKhach, @DienThoai

	DECLARE @result nvarchar(max) = 'Danh sach hhach hang: '

	WHILE(@@FETCH_STATUS = 0) -- trang thai cua con tro hien tai: 0 thanh cong; -1, -2 bi loi; -9 thieu
	BEGIN
		SET @result = @result + @MaKhach + ' - ' + @TenKhach + ' - ' + @DienThoai + '\n'
		FETCH NEXT FROM curKH into @MaKhach, @TenKhach, @DienThoai
	END

	CLOSE CurKH
	DEALLOCATE CurKH

	PRINT @result

---Tinh tong kem dieu kien
SELECT * FROM KhachHang

