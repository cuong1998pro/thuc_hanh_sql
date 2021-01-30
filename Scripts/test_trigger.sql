--CREATE TRIGGER trg_ThemChiTietHoaDon ON dbo.ChiTietHoaDon AFTER	INSERT 
--AS
--BEGIN
--	UPDATE dbo.HoaDon
--	SET	TongTien = TongTien +
--	(
--		SELECT (Inserted.SoLuong* Inserted.DonGia) 
--		FROM Inserted WHERE Inserted.SoHD = hoadon.SoHD
--	)
--	FROM dbo.HoaDon 
--	JOIN Inserted ON Inserted.SoHD = HoaDon.SoHD

--END


--CREATE TRIGGER trg_XoaChiTietHoaDon ON ChiTietHoaDon FOR DELETE AS 
--BEGIN
--	UPDATE dbo.HoaDon 
--	SET TongTien = TongTien- 
--	(
--	SELECT Deleted.SoLuong* Deleted.DonGia  
--	FROM Deleted WHERE Deleted.SoHD = HoaDon.SoHD
--	)
--	FROM Deleted 
--	INNER JOIN dbo.HoaDon ON	HoaDon.SoHD = Deleted.SoHD
--END

ALTER TRIGGER trg_CapNhatChiTietHoaDon ON dbo.ChiTietHoaDon AFTER UPDATE AS
BEGIN
	UPDATE HoaDon
	SET	 TongTien = TongTien + (SELECT SoLuong * DonGia FROM Inserted WHERE SoHD = HoaDon.SoHD) 
	- (SELECT SoLuong * DonGia FROM Deleted WHERE SoHD = HoaDon.SoHD)
	FROM Hoadon JOIN Inserted ON HoaDon.SoHD = Inserted.SoHD
	JOIN	Deleted ON Deleted.SoHD = HoaDon.SoHD
END
