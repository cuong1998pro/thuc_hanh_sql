ALTER PROC Gen_ID
@TenBang NVARCHAR(100), @Pre NVARCHAR(10), @TenCotID NVARCHAR(20),  @Return NVARCHAR(10) OUTPUT
AS 
BEGIN
	DECLARE @paramDef NVARCHAR(MAX) = '@result nvarchar(100) output'
	DECLARE @sql NVARCHAR(MAX) = '
		DECLARE @lastID int
		set @lastID  = (select top(1) 
			CONVERT(int, SUBSTRING('+@TenCotID+', 3, len('+@TenCotID+'))) IDEN from '+@TenBang+' order by IDEN desc)
		SELECT @result = N'''+ @Pre + ''' + FORMAT(@lastID + 1, ''D3'')
	'
	EXECUTE sys.sp_executesql @sql, @paramDef, @result = @Return OUTPUT
END


---THU TUC TU TANG MA
	create proc Test_Insert
	@Name nvarchar(50)
	as
	begin

		declare @lastID int, @nextID nvarchar(10)
		set @lastID  = (select top(1) 
		CONVERT(int, SUBSTRING(ID, 3, len(ID))) IDEN from Test order by IDEN desc)
		set @nextID = N'SV' + FORMAT(@lastID + 1, 'D3')


		INSERT INTO Test 
				   (ID
				   ,[Name])
			 VALUES
				  (@nextID, @Name)
	end

	Test_Insert 'cuongdz'

--Sql Server Profiler
/*
Cach dung Sql Server Profiler
- Tac dung: 
	Xem query nao duoc chay, het bao nhieu thoi gian
	Toi uu phan mem
- Cach su dung:
	Vao tool -> sql profiler -> save as table

*/

	select * from demoSqlprofiler 
	where textData like N'%Select%'

---PIVOT SQL
/*
Xoay cac hang thanh cac cot
VD: SV01 - Pham Cuong - 8.4
*/

SELECT A.MaSV, A.TenSV, A.[17200], B.[17200], A.[17200], B.[17300] FROM	
(
	SELECT * FROM	(
		SELECT DT.MaMon, DT.MaSV, SV.TenSV,  DT.Diem  
		FROM dbo.Diem AS DT
		INNER JOIN dbo.SinhVien SV ON SV.MaSV = DT.MaSV
	) AS Temp
	PIVOT(AVG(Diem) FOR MaMon IN([17200], [17300])) AS PivotDemo
)A INNER JOIN 
(
	SELECT * FROM	(
	SELECT MaMon, MaSV, Phach FROM dbo.Diem) AS Temp2
	PIVOT (MIN(Phach) FOR MaMon IN([17200], [17300])) AS PivotDemo2
)B ON A.MaSV = B.MaSV


---Pivot Dynamic
-- Lay tham so dang [17200], [17300]
SELECT STUFF(
	(SELECT DISTINCT ', ' +  QUOTENAME( CONVERT(NVARCHAR(20), MaMon)) FROM dbo.Diem FOR XML PATH (''))
	, 1
	, 2
	, ''
)

-- Goi truy van pivot dong V_DiemThi
ALTER PROC	V_DiemThi
AS
BEGIN
	DECLARE @ListColumn NVARCHAR(MAX)
	SET @ListColumn = STUFF((SELECT DISTINCT ', ' +  QUOTENAME( CONVERT(NVARCHAR(20), MaMon)) FROM dbo.Diem FOR XML PATH ('')), 1, 2, '')

	DECLARE @SQL NVARCHAR(MAX) = '
		SELECT * FROM	(
			SELECT SV.MaSV, SV.TenSV, SV.NgaySinh, Diem.MaMon, Diem.Diem 
			FROM dbo.SinhVien SV 
			INNER JOIN	dbo.Diem ON Diem.MaSV = SV.MaSV
			INNER JOIN	dbo.MonHoc ON MonHoc.MaMon = Diem.MaMon)
			AS TblDiem 
			PIVOT(AVG(Diem) FOR	MaMon IN ('+ @ListColumn +') ) AS PivotDemo'
	EXECUTE(@SQL)
END


----Try catch

CREATE PROC Demo_TryCatch
AS
BEGIN
    BEGIN TRY
        SELECT 123 / 0 AS Demo;
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS ErrorMessage,
               ERROR_LINE() AS ErrorLine;
    END CATCH;
END;

--Cac Loai Join
/*
7 loai join:
- inner join 
- left join
- right join
- full join
- cac loai join dieu kien
*/

SELECT * FROM dbo.SinhVien SV 
INNER JOIN dbo.Diem DT ON SV.MaSV = DT.MaSV

SELECT * FROM dbo.SinhVien SV
LEFT JOIN dbo.Diem DT ON SV.MaSV = DT.MaSV

SELECT * FROM dbo.SinhVien SV
RIGHT JOIN dbo.Diem DT ON SV.MaSV = DT.MaSV

SELECT * FROM dbo.SinhVien SV
FULL OUTER JOIN dbo.Diem DT ON SV.MaSV = DT.MaSV

--A co B khong co
SELECT * FROM dbo.SinhVien SV
LEFT JOIN dbo.Diem DT ON SV.MaSV = DT.MaSV
WHERE DT.MaSV IS NULL

--B co A khong co
SELECT * FROM dbo.SinhVien SV
RIGHT JOIN dbo.Diem DT ON SV.MaSV = DT.MaSV
WHERE SV.MaSV IS NULL

--Bo di phan dl 2 ben cung co
SELECT * FROM dbo.SinhVien SV
FULL OUTER JOIN dbo.Diem DT ON SV.MaSV = DT.MaSV
WHERE SV.MaSV IS NULL OR DT.MaSV IS NULL




----Tao Function tra ve table: SELECT * FROM fn_GetInfo ('012')
CREATE FUNCTION fn_GetInfo
(@ID VARCHAR(20))
RETURNS @Result TABLE (MaSV VARCHAR(20), TenSV NVARCHAR(50), DiaChi VARCHAR(250))
AS 
BEGIN
	INSERT INTO @Result
	(
		MaSV,
		TenSV,
		DiaChi
	)
	SELECT SV.MaSV, SV.TenSV, SV.DiaChi FROM dbo.SinhVien SV
	
	RETURN
END

---Dung cau Lenh Cross Apply nhan cheo du lieu: Select * from fn_GetStudentInfo('abc')
ALTER FUNCTION fn_GetStudentInfo(@MaSV VARCHAR(10))
RETURNS @result TABLE (MaSV varchar(10), MaMon nvarchar(50), Diem float)
AS
BEGIN
	INSERT INTO	@result (MaSV, MaMon, Diem)
	SELECT MaSV, MaMon, Diem FROM dbo.Diem
	RETURN
END

SELECT * FROM(
	SELECT MaSV, TenSV, DiaChi FROM dbo.SinhVien
)SinhVien CROSS APPLY  fn_GetStudentInfo('abc')
ORDER BY SinhVien.MaSV

---Lay gia tri tu truy van dong: GetValue
CREATE PROC GetValue
AS
BEGIN	
	DECLARE @sum FLOAT, @SQL NVARCHAR(max)
	SET @SQL = '
		SELECT TOP(1) @RSum = Diem FROM dbo.Diem
		ORDER BY Diem DESC
	'
	DECLARE @ParamDef NVARCHAR(200) = '@RSum bigint output'
	EXECUTE sys.sp_executesql @SQL, @ParamDef, @Rsum = @sum output
	SELECT @sum Tong
END

--kieu 2
CREATE PROC GetValueDynamic
(@query NVARCHAR(max), @returnValue INT OUTPUT)
AS
BEGIN
	DECLARE @paramDef NVARCHAR(200) = '@Rsum int output'
	EXECUTE sys.sp_executesql @query, @ParamDef, @Rsum = @returnValue OUTPUT
    PRINT @returnValue
END
--dung thu tuc
DECLARE @sql NVARCHAR(MAX), @result INT
SET @sql = '
		SELECT TOP(1) @RSum = Diem FROM dbo.Diem
		ORDER BY Diem DESC' 
EXECUTE GetValueDynamic @sql, @result OUTPUT
SELECT @result KQ

----********************************THEM DL TU FILE JSON*******************************************
DECLARE @jsonInput NVARCHAR(MAX) = N'
	[
		{
			"MaSV" :  "69509",
			"TenSV": "Phạm Quang Cường"
		}
	]
'
INSERT INTO dbo.SinhVien
(
    MaSV,
    TenSV
)
SELECT  MaSV,
		TenSV	
FROM OPENJSON(@jsonInput)
WITH(MaSV NVARCHAR(20), TenSV NVARCHAR(50))

---Xuat du lieu tu table ra json
SELECT MaSV,
       TenSV,
       NgaySinh,
       DiaChi,
       DVHT 
FROM dbo.SinhVien
FOR JSON PATH, ROOT('data')

---Chuyen co dau thanh khong dau

--SELECT MaHang,
--       dbo.fChuyenCoDauThanhKhongDau( TenHang),
--       DVT,
--       MaLoai,
--       MaNhaSX FROM dbo.HangHoa

    CREATE FUNCTION [dbo].[fChuyenCoDauThanhKhongDau](@inputVar NVARCHAR(MAX) )
    RETURNS NVARCHAR(MAX)
    AS
    BEGIN    
        IF (@inputVar IS NULL OR @inputVar = '')  RETURN ''
       
        DECLARE @RT NVARCHAR(MAX)
        DECLARE @SIGN_CHARS NCHAR(256)
        DECLARE @UNSIGN_CHARS NCHAR (256)
     
        SET @SIGN_CHARS = N'ăâđêôơưàảãạáằẳẵặắầẩẫậấèẻẽẹéềểễệếìỉĩịíòỏõọóồổỗộốờởỡợớùủũụúừửữựứỳỷỹỵýĂÂĐÊÔƠƯÀẢÃẠÁẰẲẴẶẮẦẨẪẬẤÈẺẼẸÉỀỂỄỆẾÌỈĨỊÍÒỎÕỌÓỒỔỖỘỐỜỞỠỢỚÙỦŨỤÚỪỬỮỰỨỲỶỸỴÝ' + NCHAR(272) + NCHAR(208)
        SET @UNSIGN_CHARS = N'aadeoouaaaaaaaaaaaaaaaeeeeeeeeeeiiiiiooooooooooooooouuuuuuuuuuyyyyyAADEOOUAAAAAAAAAAAAAAAEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOUUUUUUUUUUYYYYYDD'
     
        DECLARE @COUNTER int
        DECLARE @COUNTER1 int
       
        SET @COUNTER = 1
        WHILE (@COUNTER <= LEN(@inputVar))
        BEGIN  
            SET @COUNTER1 = 1
            WHILE (@COUNTER1 <= LEN(@SIGN_CHARS) + 1)
            BEGIN
                IF UNICODE(SUBSTRING(@SIGN_CHARS, @COUNTER1,1)) = UNICODE(SUBSTRING(@inputVar,@COUNTER ,1))
                BEGIN          
                    IF @COUNTER = 1
                        SET @inputVar = SUBSTRING(@UNSIGN_CHARS, @COUNTER1,1) + SUBSTRING(@inputVar, @COUNTER+1,LEN(@inputVar)-1)      
                    ELSE
                        SET @inputVar = SUBSTRING(@inputVar, 1, @COUNTER-1) +SUBSTRING(@UNSIGN_CHARS, @COUNTER1,1) + SUBSTRING(@inputVar, @COUNTER+1,LEN(@inputVar)- @COUNTER)
                    BREAK
                END
                SET @COUNTER1 = @COUNTER1 +1
            END
            SET @COUNTER = @COUNTER +1
        END
        -- SET @inputVar = replace(@inputVar,' ','-')
        RETURN @inputVar
    END
