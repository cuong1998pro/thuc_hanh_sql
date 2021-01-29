---THU TUC TU TANG MA
create proc Test_Insert
@Name nvarchar(50)
as
begin

	declare @lastID int, @nextID nvarchar(10)
	set @lastID  = (select top(1) 
	CONVERT(int, SUBSTRING(ID, 3, len(ID))) IDEN from Test order by IDEN desc)
	set @nextID = 'SV' + FORMAT(@lastID + 1, 'D3')


	INSERT INTO Test 
			   (ID
			   ,[Name])
		 VALUES
			  (@nextID, @Name)
end

Test_Insert 'cuongdz'

