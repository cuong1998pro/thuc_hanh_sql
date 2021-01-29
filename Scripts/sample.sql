-- select distinct, between, and
	select distinct MaSV, TenSV, NgaySinh, DiaChi, DVHT
	from SinhVien
	where DVHT between '2' and '4' and DiaChi = N'Hải Phòng'
	order by MaSV asc

-- chen neu chua xuat hien
	if(not exists (select MaSV from SinhVien where MaSV = '69509'))
	insert into SinhVien(MaSV, TenSV, DiaChi, NgaySinh, DVHT)
	values ('69509', N'Phạm Quang Cường', N'Hải Phòng', '1998/1/1', '2')

-- update sinh vien
	UPDATE [dbo].[SinhVien]
	   SET [MaSV] = '69543'
		  ,[TenSV] = N'Trần Bá Tùng'
		  ,[NgaySinh] = '1998/1/1'
		  ,[DiaChi] = N'Hải Phòng'
		  ,[DVHT] = '4'
	 WHERE [MaSV] = '69543'

 -- update tu hai phong sang lao cai, neu bi loi thi copy ca ? de update
	 update SinhVien 
	 set DiaChi = N'Lào Cai'
	 where DiaChi = N'Hải Phòng'

 -- xoa ban ghi
	 delete from SinhVien 
	 where MaSV = '69509'

-- dem so hang
	select 
	count(DVHT) --dem so hang khac null
	--count(*)
	as 'SoHang' from SinhVien

--max min 
	select AVG(DVHT) as 'TBDonViHoctrinh', 
	MAX(DVHT) as 'MinDVHT',
	MIN(DVHT) as 'MaxDVHT'
	from SinhVien

--convert
	select MaSV, 
	TenSV, 
	CONVERT(char(10), NgaySinh, 103) as NgaySinh, -- kieu ngay thang nam 103, thang ngay nam 101,
	DiaChi,
	DVHT
	from SinhVien

--lay thoi gian hien tai getdate()
	select getdate() as ThoiGian

--chuyen ve ngay thang nam 
	select convert(char(10), getdate(), 103) as ThoiGian

--cac ham lay thoi gian
	select 
	day(getdate()) as Ngay, 
	month(getdate()) as Thang, 
	year(getdate()) as Nam,
	DATEPART(HOUR, getdate()) as Gio,
	DATEPART(MINUTE, getdate()) as Phut,
	DATEPART(SECOND, getdate()) as Giay

--tru ngay thang, date2 - date1
	select *
	from SinhVien
	where DATEDIFF(MONTH, '1998/11/1', NgaySinh) = 0 

--group by
	select 
	DiaChi,
	count(*) as 'SoSinhVien'
	from SinhVien
	group by DiaChi

--truy van con
	select 
	MaSV,
	(select TenSV from SinhVien where MaSV = Diem.MaSV) as TenSV,
	sum(Diem) as TongDiem
	from Diem 
	group by MaSV
	order by TongDiem asc

--select top, having
	select top(1) 
	MaSV, 
	(select TenSV from SinhVien where MaSV = diem.MaSV) as TenSV,
	sum(Diem) as TongDiem
	from Diem
	group by MaSV
	having sum(Diem) < 13

	

--Insert ket hop voi select, khong co values
	insert into Diem
	(MaMon, MaSV) 
	--lay sinh vien chua co ban ghi diem
	select MaSV, MaMon from SinhVien, MonHoc 
	where (select count(*) from Diem where MaSV = SinhVien.MaSV and MaMon = MonHoc.MaMon) = 0

--THU TUC SQL
/*
	Khi chay cau lenh Sql
	1. Kiem tra cau truc cau lenh co bi sai khong?
	2. Thuc thi cau lenh.
	Giai phap: dung thu tuc Procedure 
	=> Tranh sql injection vi khong co dau nhay don; 
	=> Khong phai kiem tra lenh.
	=> De su dung, goi nhieu lan, luu tru duoc trong SQL.
	=> Trong thu tuc co the goi thu tuc khac
*/

	MonHoc_Insert '17500', N'Hoá học'
	MonHoc_SelectAll 
	MonHoc_Update '17200', N'Triết học'

--LAP TRINH SQL
	declare @index int
	set @index = 0
	while @index < 10
	begin
		print @index
		set @index = @index + 1
	end






