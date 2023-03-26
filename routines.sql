
	CREATE FUNCTION dbo.fn_diagramobjects() 
	RETURNS int
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		declare @id_upgraddiagrams		int
		declare @id_sysdiagrams			int
		declare @id_helpdiagrams		int
		declare @id_helpdiagramdefinition	int
		declare @id_creatediagram	int
		declare @id_renamediagram	int
		declare @id_alterdiagram 	int 
		declare @id_dropdiagram		int
		declare @InstalledObjects	int

		select @InstalledObjects = 0

		select 	@id_upgraddiagrams = object_id(N'dbo.sp_upgraddiagrams'),
			@id_sysdiagrams = object_id(N'dbo.sysdiagrams'),
			@id_helpdiagrams = object_id(N'dbo.sp_helpdiagrams'),
			@id_helpdiagramdefinition = object_id(N'dbo.sp_helpdiagramdefinition'),
			@id_creatediagram = object_id(N'dbo.sp_creatediagram'),
			@id_renamediagram = object_id(N'dbo.sp_renamediagram'),
			@id_alterdiagram = object_id(N'dbo.sp_alterdiagram'), 
			@id_dropdiagram = object_id(N'dbo.sp_dropdiagram')

		if @id_upgraddiagrams is not null
			select @InstalledObjects = @InstalledObjects + 1
		if @id_sysdiagrams is not null
			select @InstalledObjects = @InstalledObjects + 2
		if @id_helpdiagrams is not null
			select @InstalledObjects = @InstalledObjects + 4
		if @id_helpdiagramdefinition is not null
			select @InstalledObjects = @InstalledObjects + 8
		if @id_creatediagram is not null
			select @InstalledObjects = @InstalledObjects + 16
		if @id_renamediagram is not null
			select @InstalledObjects = @InstalledObjects + 32
		if @id_alterdiagram  is not null
			select @InstalledObjects = @InstalledObjects + 64
		if @id_dropdiagram is not null
			select @InstalledObjects = @InstalledObjects + 128
		
		return @InstalledObjects 
	END
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'FUNCTION', 'fn_diagramobjects'
go

deny execute on fn_diagramobjects to guest
go

grant execute on fn_diagramobjects to [public]
go


	CREATE PROCEDURE dbo.sp_alterdiagram
	(
		@diagramname 	sysname,
		@owner_id	int	= null,
		@version 	int,
		@definition 	varbinary(max)
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
	
		declare @theId 			int
		declare @retval 		int
		declare @IsDbo 			int
		
		declare @UIDFound 		int
		declare @DiagId			int
		declare @ShouldChangeUID	int
	
		if(@diagramname is null)
		begin
			RAISERROR ('Invalid ARG', 16, 1)
			return -1
		end
	
		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID();	 
		select @IsDbo = IS_MEMBER(N'db_owner'); 
		if(@owner_id is null)
			select @owner_id = @theId;
		revert;
	
		select @ShouldChangeUID = 0
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname 
		
		if(@DiagId IS NULL or (@IsDbo = 0 and @theId <> @UIDFound))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1);
			return -3
		end
	
		if(@IsDbo <> 0)
		begin
			if(@UIDFound is null or USER_NAME(@UIDFound) is null) -- invalid principal_id
			begin
				select @ShouldChangeUID = 1 ;
			end
		end

		-- update dds data			
		update dbo.sysdiagrams set definition = @definition where diagram_id = @DiagId ;

		-- change owner
		if(@ShouldChangeUID = 1)
			update dbo.sysdiagrams set principal_id = @theId where diagram_id = @DiagId ;

		-- update dds version
		if(@version is not null)
			update dbo.sysdiagrams set version = @version where diagram_id = @DiagId ;

		return 0
	END
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'PROCEDURE', 'sp_alterdiagram'
go

deny execute on sp_alterdiagram to guest
go

grant execute on sp_alterdiagram to [public]
go


	CREATE PROCEDURE dbo.sp_creatediagram
	(
		@diagramname 	sysname,
		@owner_id		int	= null, 	
		@version 		int,
		@definition 	varbinary(max)
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
	
		declare @theId int
		declare @retval int
		declare @IsDbo	int
		declare @userName sysname
		if(@version is null or @diagramname is null)
		begin
			RAISERROR (N'E_INVALIDARG', 16, 1);
			return -1
		end
	
		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID(); 
		select @IsDbo = IS_MEMBER(N'db_owner');
		revert; 
		
		if @owner_id is null
		begin
			select @owner_id = @theId;
		end
		else
		begin
			if @theId <> @owner_id
			begin
				if @IsDbo = 0
				begin
					RAISERROR (N'E_INVALIDARG', 16, 1);
					return -1
				end
				select @theId = @owner_id
			end
		end
		-- next 2 line only for test, will be removed after define name unique
		if EXISTS(select diagram_id from dbo.sysdiagrams where principal_id = @theId and name = @diagramname)
		begin
			RAISERROR ('The name is already used.', 16, 1);
			return -2
		end
	
		insert into dbo.sysdiagrams(name, principal_id , version, definition)
				VALUES(@diagramname, @theId, @version, @definition) ;
		
		select @retval = @@IDENTITY 
		return @retval
	END
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'PROCEDURE', 'sp_creatediagram'
go

deny execute on sp_creatediagram to guest
go

grant execute on sp_creatediagram to [public]
go


	CREATE PROCEDURE dbo.sp_dropdiagram
	(
		@diagramname 	sysname,
		@owner_id	int	= null
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
		declare @theId 			int
		declare @IsDbo 			int
		
		declare @UIDFound 		int
		declare @DiagId			int
	
		if(@diagramname is null)
		begin
			RAISERROR ('Invalid value', 16, 1);
			return -1
		end
	
		EXECUTE AS CALLER;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner'); 
		if(@owner_id is null)
			select @owner_id = @theId;
		REVERT; 
		
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname 
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1)
			return -3
		end
	
		delete from dbo.sysdiagrams where diagram_id = @DiagId;
	
		return 0;
	END
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'PROCEDURE', 'sp_dropdiagram'
go

deny execute on sp_dropdiagram to guest
go

grant execute on sp_dropdiagram to [public]
go


	CREATE PROCEDURE dbo.sp_helpdiagramdefinition
	(
		@diagramname 	sysname,
		@owner_id	int	= null 		
	)
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		set nocount on

		declare @theId 		int
		declare @IsDbo 		int
		declare @DiagId		int
		declare @UIDFound	int
	
		if(@diagramname is null)
		begin
			RAISERROR (N'E_INVALIDARG', 16, 1);
			return -1
		end
	
		execute as caller;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner');
		if(@owner_id is null)
			select @owner_id = @theId;
		revert; 
	
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname;
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId ))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1);
			return -3
		end

		select version, definition FROM dbo.sysdiagrams where diagram_id = @DiagId ; 
		return 0
	END
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'PROCEDURE',
     'sp_helpdiagramdefinition'
go

deny execute on sp_helpdiagramdefinition to guest
go

grant execute on sp_helpdiagramdefinition to [public]
go


	CREATE PROCEDURE dbo.sp_helpdiagrams
	(
		@diagramname sysname = NULL,
		@owner_id int = NULL
	)
	WITH EXECUTE AS N'dbo'
	AS
	BEGIN
		DECLARE @user sysname
		DECLARE @dboLogin bit
		EXECUTE AS CALLER;
			SET @user = USER_NAME();
			SET @dboLogin = CONVERT(bit,IS_MEMBER('db_owner'));
		REVERT;
		SELECT
			[Database] = DB_NAME(),
			[Name] = name,
			[ID] = diagram_id,
			[Owner] = USER_NAME(principal_id),
			[OwnerID] = principal_id
		FROM
			sysdiagrams
		WHERE
			(@dboLogin = 1 OR USER_NAME(principal_id) = @user) AND
			(@diagramname IS NULL OR name = @diagramname) AND
			(@owner_id IS NULL OR principal_id = @owner_id)
		ORDER BY
			4, 5, 1
	END
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'PROCEDURE', 'sp_helpdiagrams'
go

deny execute on sp_helpdiagrams to guest
go

grant execute on sp_helpdiagrams to [public]
go


	CREATE PROCEDURE dbo.sp_renamediagram
	(
		@diagramname 		sysname,
		@owner_id		int	= null,
		@new_diagramname	sysname
	
	)
	WITH EXECUTE AS 'dbo'
	AS
	BEGIN
		set nocount on
		declare @theId 			int
		declare @IsDbo 			int
		
		declare @UIDFound 		int
		declare @DiagId			int
		declare @DiagIdTarg		int
		declare @u_name			sysname
		if((@diagramname is null) or (@new_diagramname is null))
		begin
			RAISERROR ('Invalid value', 16, 1);
			return -1
		end
	
		EXECUTE AS CALLER;
		select @theId = DATABASE_PRINCIPAL_ID();
		select @IsDbo = IS_MEMBER(N'db_owner'); 
		if(@owner_id is null)
			select @owner_id = @theId;
		REVERT;
	
		select @u_name = USER_NAME(@owner_id)
	
		select @DiagId = diagram_id, @UIDFound = principal_id from dbo.sysdiagrams where principal_id = @owner_id and name = @diagramname 
		if(@DiagId IS NULL or (@IsDbo = 0 and @UIDFound <> @theId))
		begin
			RAISERROR ('Diagram does not exist or you do not have permission.', 16, 1)
			return -3
		end
	
		-- if((@u_name is not null) and (@new_diagramname = @diagramname))	-- nothing will change
		--	return 0;
	
		if(@u_name is null)
			select @DiagIdTarg = diagram_id from dbo.sysdiagrams where principal_id = @theId and name = @new_diagramname
		else
			select @DiagIdTarg = diagram_id from dbo.sysdiagrams where principal_id = @owner_id and name = @new_diagramname
	
		if((@DiagIdTarg is not null) and  @DiagId <> @DiagIdTarg)
		begin
			RAISERROR ('The name is already used.', 16, 1);
			return -2
		end		
	
		if(@u_name is null)
			update dbo.sysdiagrams set [name] = @new_diagramname, principal_id = @theId where diagram_id = @DiagId
		else
			update dbo.sysdiagrams set [name] = @new_diagramname where diagram_id = @DiagId
		return 0
	END
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'PROCEDURE', 'sp_renamediagram'
go

deny execute on sp_renamediagram to guest
go

grant execute on sp_renamediagram to [public]
go


	CREATE PROCEDURE dbo.sp_upgraddiagrams
	AS
	BEGIN
		IF OBJECT_ID(N'dbo.sysdiagrams') IS NOT NULL
			return 0;
	
		CREATE TABLE dbo.sysdiagrams
		(
			name sysname NOT NULL,
			principal_id int NOT NULL,	-- we may change it to varbinary(85)
			diagram_id int PRIMARY KEY IDENTITY,
			version int,
	
			definition varbinary(max)
			CONSTRAINT UK_principal_name UNIQUE
			(
				principal_id,
				name
			)
		);


		/* Add this if we need to have some form of extended properties for diagrams */
		/*
		IF OBJECT_ID(N'dbo.sysdiagram_properties') IS NULL
		BEGIN
			CREATE TABLE dbo.sysdiagram_properties
			(
				diagram_id int,
				name sysname,
				value varbinary(max) NOT NULL
			)
		END
		*/

		IF OBJECT_ID(N'dbo.dtproperties') IS NOT NULL
		begin
			insert into dbo.sysdiagrams
			(
				[name],
				[principal_id],
				[version],
				[definition]
			)
			select	 
				convert(sysname, dgnm.[uvalue]),
				DATABASE_PRINCIPAL_ID(N'dbo'),			-- will change to the sid of sa
				0,							-- zero for old format, dgdef.[version],
				dgdef.[lvalue]
			from dbo.[dtproperties] dgnm
				inner join dbo.[dtproperties] dggd on dggd.[property] = 'DtgSchemaGUID' and dggd.[objectid] = dgnm.[objectid]	
				inner join dbo.[dtproperties] dgdef on dgdef.[property] = 'DtgSchemaDATA' and dgdef.[objectid] = dgnm.[objectid]
				
			where dgnm.[property] = 'DtgSchemaNAME' and dggd.[uvalue] like N'_EA3E6268-D998-11CE-9454-00AA00A3F36E_' 
			return 2;
		end
		return 1;
	END
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'PROCEDURE', 'sp_upgraddiagrams'
go

CREATE FUNCTION udfGetAvgPriceOfMenu(@MenuID int)
RETURNS money
AS
BEGIN
    RETURN (
        SELECT AVG(P.UnitPrice)
        FROM MenuDetails M
        JOIN Products P on M.ProductID = P.ProductID
        WHERE MenuID = @MenuID
    )
END
go

CREATE FUNCTION udfGetBestDiscount(@CustomerID int)
    RETURNS real AS
BEGIN
    RETURN
    (SELECT MAX(Discount)
     FROM (
     VALUES (dbo.udfGetBestEarnedDiscount (@CustomerID)),
            (dbo.udfGetBestOneTimeDiscount(@CustomerID))) AS AllDiscount(Discount))
END
go

CREATE function udfGetBestEarnedDiscount(@CustomerID int)
returns real
as begin
    return ISNULL((select top 1 max(EarnedDiscount) from dbo.vwCustomerEarnedDiscount
        where CustomerID=@CustomerID), 0)
end
go

CREATE function udfGetBestOneTimeDiscount(@CustomerID int)
returns real
as begin
    return IsNull((select top 1 max(Discount) from dbo.vwCustomerAvailableDiscount
            where @CustomerID=CustomerID), 0)
end
go

CREATE function dbo.udfGetBestProducts(@val int)
    returns table as
        return select distinct top (@val) P.ProductName, POS.SalesCount from dbo.Products P
        join dbo.vwProductsOverallSales POS on P.ProductID=POS.ProductID
        order by POS.SalesCount desc
go

create FUNCTION udfGetCustomerOrders (@CustomerID INT)
RETURNS TABLE
AS
RETURN
   SELECT * FROM vwOrderData WHERE @CustomerID = CustomerID;
go

CREATE function dbo.udfGetCustomersOrderedMoreThanXTimes(@amount int)
    returns table as
        return select CS.CustomerID, C.Firstname, C.Lastname, C.Address, C.Region, C.Phone, C.PostalCode from  dbo.vwCustomerStatistics CS
            join dbo.Customers C on C.CustomerID=CS.CustomerID
            where number_of_orders>@amount
go

CREATE  function udfGetCustomersOrderedMoreThanXValue(@val float)
    returns table as
        return select CustomerID from dbo.vwCustomerStatistics
            where value_of_orders>@val
go

CREATE function udfGetCustomersWhoOweMoreThanX(@val int)
    returns table as
    return select customer_id, orders_value from dbo.vwOwingCustomers
        where orders_value>@val
go

create function udfGetEmployeesOfCompany(@CompanyName nvarchar(40))
    returns table as
    return
    select E.Firstname,E.Lastname from dbo.Employees E
        join dbo.Companies C on E.CompanyID = C.CompanyID
        where @CompanyName=CompanyName
go

create function udfGetMaxPriceOfMenu(@MenuID int)
    returns money
as
begin
    return (select top 1 max(P.UnitPrice) from dbo.Products P
             join dbo.MenuDetails MD on MD.ProductID=P.ProductID
             join dbo.Menus M on MD.MenuID = M.MenuID
                where M.MenuID=@MenuID)
end
go

CREATE FUNCTION udfGetMealsSoldAtLeastXTimes(@input int)
    RETURNS table AS
        RETURN
        SELECT ProductName,SUM(Quantity) as [Ilość sprzedanych sztuk] FROM Products P
        JOIN OrderDetails OD on P.ProductID = OD.ProductID
        GROUP BY ProductName
        HAVING SUM(Quantity)>@input
go

CREATE FUNCTION udfGetMenuItemsByDate(@date date)
RETURNS TABLE AS
RETURN
    SELECT M.MenuID, M.AvailableFrom, M.AvailableTo, P.ProductName, P.UnitPrice
    FROM Products P
        JOIN MenuDetails MD on MD.ProductID = P.ProductID
        JOIN Menus M on M.MenuID = MD.MenuID
    WHERE @date BETWEEN M.AvailableFrom AND M.AvailableTo
go

CREATE FUNCTION udfGetMenuItemsByID(@menuId int)
RETURNS TABLE AS
RETURN
    SELECT M.MenuID, M.AvailableFrom, M.AvailableTo, P.ProductID, P.ProductName, P.UnitPrice, P.UnitsInStock
    FROM Products P
        JOIN MenuDetails MD on MD.ProductID = P.ProductID
        JOIN Menus M on M.MenuID = MD.MenuID
    WHERE (M.MenuID = @menuId)
go

CREATE FUNCTION udfGetMinPriceOfMenu(@MenuID int)
    RETURNS money
    AS
    BEGIN
        RETURN
        (SELECT MIN(P.UnitPrice)
        FROM MenuDetails M
        JOIN Products P on M.ProductID = P.ProductID and MenuID = @MenuID)
    END
go

CREATE FUNCTION udfGetOrderDiscountValue(@OrderID int)
    RETURNS real AS
BEGIN
    RETURN
    (SELECT DISTINCT Discount FROM Orders
    WHERE @OrderID=OrderID)
END
go

CREATE FUNCTION udfGetOrderValue(@id int)
    RETURNS money
AS
BEGIN
    RETURN
    ISNULL((SELECT SUM((Quantity*UnitPrice))*(1-MIN(O.Discount))
    FROM OrderDetails
    join Orders O on OrderDetails.OrderID = O.OrderID
    WHERE O.OrderID=@id
    GROUP BY O.OrderID), 0)
END
go

CREATE FUNCTION udfGetOrdersMoreExpensiveThan(@value int)
RETURNS table AS
RETURN
    SELECT OD.OrderID, OD.CustomerID, OD.OrderValue
    FROM vwOrderData OD
    WHERE OD.OrderValue > @value
go

CREATE FUNCTION udfGetProductsSoldMoreTimesThan(@salesCount int)
RETURNS table AS
RETURN
    SELECT POS.ProductName, POS.SalesCount
    FROM ProductsOverallSales POS
    WHERE POS.SalesCount > @salesCount
go

CREATE FUNCTION udfGetValueOfOrdersInMonth(@year int, @month int)
RETURNS money
AS
BEGIN
    RETURN ISNULL((
        SELECT SUM(OD.OrderValue)
        FROM vwOrderData OD
        INNER JOIN Orders O on OD.OrderID = O.OrderID
        WHERE @year = YEAR(OD.OrderDate)
        AND @month = MONTH(OD.OrderDate)
    ), 0)
END
go

CREATE FUNCTION udfGetValueOfOrdersOnDay(@date date)
    RETURNS money
AS
BEGIN
    RETURN ISNULL((
        SELECT SUM(OD.OrderValue)
        FROM vwOrderData OD
            JOIN Orders O on OD.OrderID = O.OrderID
        WHERE YEAR(@date) = YEAR(OD.OrderDate)
            AND MONTH(@date) = MONTH(OD.OrderDate)
            AND DAY(@date) = DAY(OD.OrderDate)
    ), 0)
END
go

CREATE FUNCTION udfMenuIsCorrect()
    RETURNS bit
AS
BEGIN
    DECLARE @PreviousMenuID int
    DECLARE @CurrentMenu int
    SET @CurrentMenu=(SELECT MenuID FROM Menus
    WHERE GETDATE() BETWEEN AvailableFrom AND AvailableTo)
    SET @PreviousMenuID=(SELECT MenuID FROM Menus
    WHERE DATEADD(day,-14,GETDATE()) BETWEEN AvailableFrom AND AvailableTo)
    DECLARE @sameIteams int
    SET @sameIteams=(SELECT count(*)FROM
                    (SELECT ProductID FROM MenuDetails MD
                    JOIN Menus M ON MD.MenuID = M.MenuID AND M.MenuID=@CurrentMenu
                    INTERSECT
                    SELECT ProductID FROM MenuDetails MD
                    JOIN Menus M ON MD.MenuID = M.MenuID AND M.MenuID=@PreviousMenuID) AS POD)
    DECLARE @minChange int
    SET @minChange=(SELECT COUNT(*) FROM MenuDetails WHERE MenuID=@PreviousMenuID)/2
    IF @sameIteams<=@minChange
    BEGIN
        RETURN 1
    end
    RETURN 0
END
go

CREATE PROCEDURE uspAddCategory
        @CategoryName varchar(40),
        @CategoryDescription text = ''
        AS
        BEGIN
           SET NOCOUNT ON
           BEGIN TRY
               IF EXISTS(
                   SELECT *
                   FROM Categories
                   WHERE @CategoryName = CategoryName
               )
               BEGIN
                   THROW 52000, N'Kategoria o podanej nazwie istnieje już w bazie danych', 1
               END
               INSERT INTO Categories(CategoryName, Description)
               VALUES(@CategoryName, @CategoryDescription);
           END TRY
           BEGIN CATCH
               DECLARE @msg nvarchar(2048) =
               N'Błąd podaczas dodawania kategorii: ' + ERROR_MESSAGE();
               THROW 52000, @msg, 1;
           END CATCH
        END
go

grant execute on uspAddCategory to employee
go

CREATE procedure dbo.uspAddCustomer
@FirstName nvarchar(20),
@LastName nvarchar(20),
@City nvarchar(20),
@Region nvarchar(20),
@PostalCode nvarchar(20),
@Phone nvarchar(20),
@Address nvarchar(20),
@Country nvarchar(20),
@ContactName nvarchar(40),
@CustomerType varchar(1),
@CompanyName varchar(20)
as begin
    set nocount on
        begin try
            if exists(
                select * from dbo.Customers where Phone=@Phone
                )
            begin;
            throw 52000, N'Numer telefonu znajduje się już w bazie',1
                end
            if exists(
                select * from dbo.Companies where CompanyName=@CompanyName
                )
            begin;
            throw 52000, N'Nazwa firmy znajduje się juz w bazie',1
                end
            declare @ScopeIdentity int
            if @CustomerType='I'
                insert into dbo.Customers(Lastname, Firstname, Address, City, Region, PostalCode, Country, Phone, CompanyID, EarnedDiscount)
                values (@LastName,@FirstName,@Address,@City,@Region,@PostalCode,@Country,@Phone,null,0)
            if @CustomerType='C'
                insert into dbo.Companies( CompanyName, ContactName)
                values (@CompanyName,@ContactName)
                select @ScopeIdentity=scope_identity()
                insert into dbo.Customers( Lastname, Firstname, Address, City, Region, PostalCode, Country, Phone,CompanyID, EarnedDiscount)
                values (@LastName,@FirstName,@Address,@City,@Region,@PostalCode,@Country,@Phone,@ScopeIdentity,0)
            end try
        begin catch
            declare @message nvarchar(2048)=N'Wystąpił błąd przy dodawaniu klienta: '+error_message();
            throw 52000, @message, 1
        end catch
end
go

CREATE PROCEDURE uspAddEmployee
@FirstName nvarchar(20),
@LastName nvarchar(20),
@CompanyID int
AS
BEGIN
   SET NOCOUNT ON
   BEGIN TRY
       IF NOT EXISTS(
           SELECT *
           FROM Companies
           WHERE @CompanyID = CompanyID
       )
       BEGIN
           THROW 52000, 'Firma o podanym ID nazwie nie istnieje', 1
       END
       INSERT INTO Employees(firstname, lastname, companyid)
       values (@FirstName, @LastName, @CompanyID)
   END TRY
   BEGIN CATCH
       DECLARE @msg nvarchar(2048) = 
	   N'Błąd podaczas dodawania pracownika: ' + ERROR_MESSAGE();
       THROW 52000, @msg, 1
   END CATCH
END
go

CREATE PROCEDURE uspAddEmployeeToReservation
@ReservationID int,
@EmployeeID int
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS(
            SELECT *
            FROM Reservations
            WHERE ReservationID = @ReservationID
        )
        BEGIN;
            THROW 52000, 'Podana rezerwacja nie istnieje', 1
        end
        IF NOT EXISTS(
            SELECT *
            FROM Employees
            WHERE EmployeeID=@EmployeeID
            )
        BEGIN;
            THROW 52000, 'Podany pracownik nie istnieje nie istnieje', 1
        END
        INSERT INTO EmployeesReservations(reservationid, EmployeeID)
        VALUES(@ReservationID,@EmployeeID);
        END TRY
        BEGIN CATCH
        DECLARE @errorMsg nvarchar(2048)
        =N'Błąd podczas dodania pracownika do rezerwacji: ' + ERROR_MESSAGE();
        THROW 52000, @errorMsg, 1
    END CATCH
END
go

grant execute on uspAddEmployeeToReservation to companyCustomer
go

grant execute on uspAddEmployeeToReservation to employee
go

CREATE PROCEDURE uspAddInvoice
    @OrderID int
    AS
	begin
		begin try
			if not exists(select * from dbo.Orders where OrderID=@OrderID)
				throw 52000,N'Podane zamówienie nie istnieje',1
			if not exists(select * from dbo.Orders where OrderID=@OrderID and InvoiceID is null)
				throw 52000,N'Na podane zamówienie została już utworzona faktura',1
			insert into Invoices (InvoiceDate) values(GETDATE())
			declare @InvoiceID int = SCOPE_IDENTITY();
			update Orders
				set InvoiceID = @InvoiceID
				where OrderID = @OrderID 
		end try
		begin catch
			declare @message nvarchar(2048)=N'Wystąpił błąd podczas generowania faktury: '+error_message();
			throw 52000,@message,1
		end catch
	end
go

CREATE PROCEDURE uspAddMenu
	@AvailableFrom datetime,
	@AvailableTo datetime
	AS
	BEGIN
		SET NOCOUNT ON
		BEGIN TRY
			IF EXISTS(
				SELECT *
				FROM Menus
				WHERE (not ( @AvailableTo <= AvailableFrom or AvailableTo <= @AvailableFrom )) or ( @AvailableTo = AvailableFrom and AvailableTo = @AvailableFrom )
			)
			BEGIN
				THROW 52000, N'Podane daty kolidują z obecnymi już w bazie', 1
			END
			
			IF (@AvailableFrom <= DATEADD(day, -1, GETDATE()))
			BEGIN
				THROW 52000, N'Menu musi być ustalne z conajmniej dziennym wyprzedzeniem', 1
			END


			INSERT INTO Menus(AvailableFrom, AvailableTo)
    			VALUES(@AvailableFrom, @AvailableTo);
		END TRY
		BEGIN CATCH
			DECLARE @msg nvarchar(2048) =
			N'Błąd podaczas dodawania menu: ' + ERROR_MESSAGE();
			THROW 52000, @msg, 1;
		END CATCH
	END
go

CREATE procedure dbo.uspAddOrder
@CustomerID int,
@Takeaway bit,
@PickUpDate datetime,
@Discount real
as begin
    set nocount on
    begin try
        declare @OneTimeDiscountID int
        set @OneTimeDiscountID = null
        declare @OrderDate datetime
        set @OrderDate = getdate()
--         declare @ScopeIdentity int
        if isnull(@PickUpDate,'9999-01-01')<getdate()
            begin;
                throw 52000,N'Wprowadzono niepoprawną datę odbioru zamówienia',1
            end
        if @Discount != dbo.udfGetBestOneTimeDiscount(@CustomerID)
        and @Discount != dbo.udfGetBestEarnedDiscount(@CustomerID)
            begin;
                throw 52000, N'Podana wartość zniżki nie istnieje',1
            end
        if not exists(
            select EarnedDiscount from dbo.Customers where EarnedDiscount=@Discount and CustomerID=@CustomerID
            ) and exists (
                select Discount from dbo.OneTimeDiscounts where @Discount=Discount and @CustomerID=CustomerID and ExpirationDate<getdate()
            )
            begin
                set @OneTimeDiscountID=(select OneTimeDiscountID from dbo.OneTimeDiscounts where CustomerID=@CustomerID and @Discount=Discount and ExpirationDate<getdate())
            end
        if(@Takeaway=1)
            begin
                insert into dbo.Orders(CustomerID, OrderDate, PickUpDate, InvoiceID, Discount, OneTimeDiscountID)
                values (@CustomerID,@OrderDate,@PickUpDate,null,0, @OneTimeDiscountID)
            end
        if(@Takeaway=0)
            begin
                insert into dbo.Orders(CustomerID, OrderDate, PickUpDate, InvoiceID, Discount,OneTimeDiscountID)
                values (@CustomerID,@OrderDate,null,null,@Discount,@OneTimeDiscountID)
            end
        end try
    begin catch
        declare @message nvarchar(2048)=N'Wystąpił błąd podczas tworzenia zamówienia: '+error_message();
        throw 52000,@message,1
    end catch
end
go

grant execute on uspAddOrder to companyCustomer
go

grant execute on uspAddOrder to employee
go

grant execute on uspAddOrder to notRegisteredCustomer
go

grant execute on uspAddOrder to registeredCustomer
go

CREATE PROCEDURE uspAddPayment
    @OrderID int,
    @Amount money
    AS
    BEGIN
        SET NOCOUNT ON
        BEGIN TRY
            IF NOT EXISTS(
                SELECT *
                FROM Orders
                WHERE @OrderID = OrderID
            )
            BEGIN
                THROW 52000, 'Zamówienie o podanym ID nie istnieje', 1
            END
            INSERT INTO Payments(OrderID, Amount, Date)
            values (@OrderID, @Amount, GETDATE())
        END TRY
        BEGIN CATCH
            DECLARE @msg nvarchar(2048) = N'Błąd podaczas dodawania płatności: ' + ERROR_MESSAGE();
            THROW 52000, @msg, 1
        END CATCH
    END
go

grant execute on uspAddPayment to companyCustomer
go

grant execute on uspAddPayment to employee
go

grant execute on uspAddPayment to registeredCustomer
go

CREATE PROCEDURE uspAddProduct
            @ProductName nvarchar(40),
            @CategoryID int,
            @QuantityPerUnit smallint,
            @UnitPrice money,
            @UnitsInStock int
            AS
            BEGIN
               BEGIN TRY
                   IF EXISTS(
                       SELECT *
                       FROM Products
                       WHERE @ProductName = ProductName
                   )
                   BEGIN
                       THROW 52000, N'Produkt o podanej nazwie istnieje już w bazie danych', 1;
                   END
                   IF NOT EXISTS(
                       SELECT *
                       FROM Categories
                       WHERE @CategoryID = @CategoryID
                   )
                   BEGIN
                       THROW 52000, N'Kategoria o podanym ID nie istnieje', 1
                   END
                   INSERT INTO Products(ProductName, CategoryID, QuantityPerUnit, UnitPrice, UnitsInStock)
                       VALUES (@ProductName, @CategoryID, @QuantityPerUnit, @UnitPrice, @UnitsInStock)
                END TRY
                BEGIN CATCH
                   DECLARE @msg nvarchar(2048) =
                   N'Błąd podaczas dodawania produktu: ' + ERROR_MESSAGE();      
                   THROW 52000, @msg, 1;
                END CATCH
            END
go

CREATE PROCEDURE uspAddProductToMenu
                @ProductID int,
                @MenuID int
                AS
                BEGIN
                    SET NOCOUNT ON
                    BEGIN TRY
                        IF NOT EXISTS(
                            SELECT *
                            FROM Products
                            WHERE ProductID = @ProductID
                        )
                        BEGIN
                            THROW 52000, 'Produkt o podanym ID nie istnieje', 1
                        END
                        IF NOT EXISTS(
                            SELECT *
                            FROM Menus
                            WHERE MenuID = @MenuID
                        )
                        BEGIN
                            THROW 52000, 'Menu o podanym ID nie istnieje', 1
                        END
                        INSERT INTO MenuDetails(MenuID, ProductID)
                        VALUES (@MenuID, @ProductID);
                    END TRY
                    BEGIN CATCH
                        DECLARE @msg nvarchar(2048)
                        =N'Błąd dodania produktu do menu: ' + ERROR_MESSAGE();
                        THROW 52000, @msg, 1
                    END CATCH
                END
go

grant execute on uspAddProductToMenu to employee
go

CREATE procedure dbo.uspAddProductToOrder
@OrderID int,
@Quantity int,
@ProductID int
as begin
    set nocount on
    begin try
        declare @QuantityOfProduct int
        set @QuantityOfProduct = (select UnitsInStock from dbo.Products where @ProductID=ProductID)
        if not exists(
            select * from dbo.Orders where OrderID=@OrderID
            )
        begin;
            throw 52000,N'Podane zamówienie nie istnieje',1
            end
        if not exists(
            select * from dbo.Products where ProductID=@ProductID
            )
        begin;
            throw 52000,N'Podany produkt nie instnieje',1
            end
        if not exists(
                select * from dbo.Products P
                join dbo.MenuDetails MD on P.ProductID=MD.ProductID
                join dbo.Menus M on MD.MenuID = M.MenuID where M.AvailableFrom<getdate()
                                                        and M.AvailableTo>getdate() and P.ProductID=@ProductID
            )
        begin;
            throw 52000,N'Podany produkt nie znajduje się obecnie w menu',1
            end
        if (
            @QuantityOfProduct-@Quantity<0
            )
        begin
            throw  52000,N'Podany produkt skończył się lub nie ma wystarczającej ilości aby pokryć zamówienie',1
        end
        declare @QuantityDiff int
            set @QuantityDiff=((
                select UnitsInStock
                from dbo.Products
                where ProductID=@ProductID
                )-@Quantity)
            exec dbo.uspChangeStock @ProductID=@ProductID,@NewStockValue=@QuantityDiff
        if exists(
            select *
            from OrderDetails
            where OrderID = @OrderID and ProductID = @ProductID
            )
            begin
                update OrderDetails
                    set Quantity=(
                        select max(Quantity)
                        from OrderDetails
                        where OrderID=@OrderID and ProductID=@ProductID
                    ) + @Quantity
                    where OrderID=@OrderID and ProductID=@ProductID
            end
        else
            begin
                insert into dbo.OrderDetails(ProductID, OrderID, Quantity, UnitPrice)
                values (@ProductID,@OrderID,@Quantity,(
                    select UnitPrice
                    from dbo.Products
                    where @ProductID=ProductID
                ))
            end
        end try
    begin catch
        declare @message nvarchar(2048)=N'Wystąpił błąd podczas dodawania do zamówienia: '+error_message();
        throw 52000,@message,1
    end catch
end
go

grant execute on uspAddProductToOrder to employee
go

CREATE PROCEDURE uspAddReservation
@CustomerID int,
@StartDate datetime,
@EndDate datetime,
@Accepted bit,
@OrderID int
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS(
            SELECT *
            FROM Customers
            WHERE CustomerID = @CustomerID
        )
        BEGIN;
            THROW 52000, 'Podany klient nie istnieje', 1
        END
        DECLARE @NumberOfOrders int
        SET @NumberOfOrders=(SELECT count(OrderID) FROM Orders
                            WHERE CustomerID=@CustomerID)
        IF @NumberOfOrders<(SELECT WK FROM ConfigurationVariables) OR dbo.udfGetOrderValue(@OrderID)<(SELECT WZ FROM ConfigurationVariables)
        BEGIN;
            THROW 52000, 'Nie spełniłeś warunków aby dodać rezerwacje', 1
        END
        INSERT INTO Reservations( ReservationDateStart, ReservationDateEnd, Accepted,OrderID)
        VALUES( @StartDate, @EndDate, @Accepted,@OrderID);
        END TRY
        BEGIN CATCH
        DECLARE @errorMsg nvarchar(2048)
        =N'Błąd podczas dodania rezerwacji: ' + ERROR_MESSAGE();
        THROW 52000, @errorMsg, 1
    END CATCH
END
go

CREATE procedure uspAddTable
@SeatCount int
as begin
    set nocount on
    begin try
        insert into dbo.Tables(SeatCount)
        values (@SeatCount)
    end try
    begin catch
        declare @message nvarchar(2048)=N'Wystąpił błąd przy dodawaniu stolika: '+error_message();
        throw 52000, @message, 1
    end catch
end
go

grant execute on uspAddTable to employee
go

CREATE procedure dbo.uspAddTableToReservation
@ReservationID int,
@TableID int
as begin
    set nocount on
    begin try
        declare @ReservationDateStart datetime
        declare @ReservationDateEnd datetime
        set @ReservationDateStart =(select ReservationDateStart from dbo.Reservations where ReservationID=@ReservationID)
        set @ReservationDateEnd=(select ReservationDateEnd from dbo.Reservations where ReservationID=@ReservationID)
        if exists(select TableID from dbo.TablesReservations
                join dbo.Reservations R on TablesReservations.ReservationID = R.ReservationID
                where (R.ReservationDateStart between @ReservationDateStart and @ReservationDateEnd)
                   or (R.ReservationDateEnd between @ReservationDateStart and @ReservationDateEnd)
                   or (R.ReservationDateStart  < @ReservationDateStart and R.ReservationDateEnd>@ReservationDateEnd))
            begin;
                throw 52000,N'Wybrany stolik jest już zarezerwowany w danych godzinach',1
            end
        if not exists(
            select * from dbo.Tables where TableID=@TableID
            )
        begin;
            throw 52000,'Podany stolik nie istnieje',1
        end
        if not exists(
            select * from dbo.Reservations where ReservationID=@ReservationID
            )
        begin;
            throw 52000,'Podana rezerwacja nie istnieje',1
        end
        insert into dbo.TablesReservations(ReservationID,TableID)
        values (@ReservationID,@TableID)
    end try
    begin catch
        declare @message nvarchar(2048)=N'Wystąpił błąd przy dodawaniu stolika do rezerwacji: '+error_message();
        throw 52000, @message, 1
    end catch
end
go

grant execute on uspAddTableToReservation to companyCustomer
go

CREATE PROCEDURE uspChangeReservationStatus
@ReservationID int,
@Accepted bit
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        BEGIN
            UPDATE Reservations
                SET Accepted = @Accepted
                WHERE Reservations.ReservationID=@ReservationID
        END
    END TRY
    BEGIN CATCH
        DECLARE @msg nvarchar(2048)=N'Błąd podczas edytowania rezerwacji: ' + ERROR_MESSAGE();
        THROW 52000, @msg, 1
    END CATCH
END
go

grant execute on uspChangeReservationStatus to employee
go

create PROCEDURE uspChangeStock
    @ProductID int,
    @NewStockValue smallInt
    AS
	begin
		begin try
			if not exists(select * from dbo.Products where ProductID=@ProductID)
				throw 52000,N'Podany produkt nie istnieje',1

			    UPDATE Products 
				SET 
					UnitsInStock = @NewStockValue
				WHERE
					ProductID = @ProductID;
		end try
		begin catch
			declare @message nvarchar(2048)=N'Wystąpił błąd podczas zmieniania dostępnej ilości produktów: '+error_message();
			throw 52000,@message,1
		end catch
	end
go

grant execute on uspChangeStock to employee
go

CREATE PROCEDURE uspModifyTable
@TableID int,
@SeatCount int
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
        IF NOT EXISTS(
            SELECT * FROM Tables
            WHERE TableID=@TableID
        )
        BEGIN;
            THROW 52000, 'Podany stolik nie istnieje.', 1
        END
        IF @SeatCount < 1
        BEGIN;
            THROW 52000, N'Stolik musi mieć przynajmniej 1 miejsce siedzące.', 1
        END
        IF @SeatCount IS NOT NULL
        BEGIN
            UPDATE Tables
                SET SeatCount = @SeatCount
                WHERE Tables.TableID=@TableID
        END
    END TRY
    BEGIN CATCH
        DECLARE @msg nvarchar(2048)=N'Błąd podczas edytowania stolika: ' +ERROR_MESSAGE();
        THROW 52000, @msg, 1
    END CATCH
END
go

CREATE PROCEDURE uspMonthlyInvoice
	@CusomerID int
	AS
	BEGIN
		SET NOCOUNT ON
		BEGIN TRY
			IF EXISTS(
				SELECT I.InvoiceID
				FROM Invoices I
				JOIN Orders O ON O.InvoiceID = I.InvoiceID
				WHERE O.CustomerID = @CusomerID
				GROUP BY I.InvoiceID
				HAVING COUNT(OrderID) > 1
			)
			BEGIN
				THROW 52000, N'Podany klient utworzył już fakture zbiorczą w przeciągu ostatniego miesiąca', 1;
			END
			
			INSERT Invoices (InvoiceDate) VALUES (GETDATE());
			UPDATE Orders
				SET InvoiceID = SCOPE_IDENTITY()
				WHERE InvoiceID is NULL and CustomerID = @CusomerID and DATEADD(MONTH, -1, GETDATE()) < OrderDate

		END TRY
		BEGIN CATCH
			DECLARE @msg nvarchar(2048) =
			N'Błąd podaczas tworzenia faktury zbiorczej: ' + ERROR_MESSAGE();
			THROW 52000, @msg, 1;
		END CATCH
	END
go

CREATE PROCEDURE uspRemoveCategory
@CategoryID int
AS
BEGIN
    SET NOCOUNT ON
    BEGIN TRY
    IF NOT EXISTS(
        SELECT *
        FROM Categories
        WHERE CategoryID = @CategoryID
    )
    BEGIN;
        THROW 52000,'Kategori o podanym ID nie istnieje',1
    end
    DELETE FROM Categories
        WHERE CategoryID = @CategoryID
    END TRY
    BEGIN CATCH
    DECLARE @msg nvarchar(2048) = N'Błąd podczas usuwania kategorii: ' + ERROR_MESSAGE();
        THROW 52000, @msg, 1;
    END CATCH
END
go

grant execute on uspRemoveCategory to employee
go

CREATE PROCEDURE uspRemoveProductFromOrder
    @ProductID int,
    @OrderID int
    AS
    begin
        begin try
            if not exists(select * from dbo.Products where ProductID=@ProductID)
                throw 52000,N'Podane produkt nie istnieje',1

            if not exists(select * from dbo.Orders where OrderID=@OrderID)
            begin;
                throw 52000,N'Podane zamówienie nie istnieje',1
                end
            
            if not exists(select * from dbo.Orders where OrderID=@OrderID and InvoiceID != null)
            begin;
                throw 52000,N'Na podane zamówienie wygenerowana została już faktura, modyfikacja jest niemożliwa',1
                end

            if not exists(
                select * 
                from dbo.OrderDetails 
                where OrderID=@OrderID and ProductID = @ProductID
            )
            begin;
                throw 52000,N'W zamówieniu o podanym ID nie ma produktu o podanym ID',1
                end

            delete from dbo.OrderDetails where OrderID=@OrderID and ProductID = @ProductID;
        end try
        begin catch
            declare @message nvarchar(2048)=N'Wystąpił błąd podczas usuwania z zamówienia: '+error_message();
            throw 52000,@message,1
        end catch
    end
go

grant execute on uspRemoveProductFromOrder to employee
go

