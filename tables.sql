create table Categories
(
    CategoryID   int identity
        constraint PK_Categories
            primary key,
    CategoryName nvarchar(40) not null,
    Description  text         not null
)
go

grant select on Categories to owner
go

create table Companies
(
    CompanyID   int identity
        constraint PK_Companies
            primary key,
    CompanyName nvarchar(40) not null,
    ContactName nvarchar(40)
)
go

grant select on Companies to owner
go

create table ConfigurationVariables
(
    D1 int   not null
        constraint CHK_D1
            check ([D1] > 0),
    K1 money not null
        constraint CHK_K1
            check ([K1] > 0),
    K2 money not null
        constraint CHK_K2
            check ([K2] > 0),
    R1 real  not null
        constraint CHK_R1
            check (0 < [R1] AND [R1] < 1),
    R2 real  not null
        constraint CHK_R2
            check (0 < [R2] AND [R2] < 1),
    Z1 int   not null
        constraint CHK_Z1
            check ([Z1] > 0),
    WK int   not null
        constraint CHK_WK
            check ([WK] > 0),
    WZ money not null
        constraint CHK_WZ
            check ([WZ] > 0)
)
go

grant select on ConfigurationVariables to owner
go

create table Customers
(
    CustomerID     int identity
        constraint PK_Customers
            primary key,
    Lastname       nvarchar(20)                          not null,
    Firstname      nvarchar(20)                          not null,
    Address        nvarchar(20)                          not null,
    City           nvarchar(20)                          not null,
    Region         nvarchar(20)                          not null,
    PostalCode     nvarchar(20)                          not null
        constraint CHK_Customers_PostalCode
            check ([PostalCode] like '[0-9][0-9]-[0-9][0-9][0-9]'),
    Country        nvarchar(20)                          not null,
    Phone          nvarchar(20)                          not null
        constraint CHK_Customers_Phone
            check ([Phone] like '+[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'),
    CompanyID      int
        constraint FK_Customers_Companies
            references Companies
            on update set null on delete set null,
    EarnedDiscount real
        constraint DF_Customers_EarnedDiscount default 0 not null
        constraint CHK_EarnedDiscount
            check ([EarnedDiscount] >= 0)
)
go

create unique index UQ_Customers_CompanyID
    on Customers (CompanyID)
    where [CompanyID] IS NOT NULL
go

grant select on Customers to owner
go

create table Employees
(
    EmployeeID int identity
        constraint PK_Employees
            primary key,
    FirstName  nvarchar(20) not null,
    LastName   nvarchar(20) not null,
    CompanyID  int          not null
        constraint FK_Employees_Companies
            references Companies
)
go

create index IX_Employees_FirstName
    on Employees (FirstName)
go

create index IX_Employees_LastName
    on Employees (LastName)
go

grant select on Employees to owner
go

create table Invoices
(
    InvoiceID   int identity
        constraint PK_Invoices
            primary key,
    InvoiceDate datetime not null
)
go

grant select on Invoices to owner
go

create table Menus
(
    MenuID        int identity
        constraint PK_Menus
            primary key,
    AvailableFrom datetime not null,
    AvailableTo   datetime not null,
    constraint CHK_Menus_Date
        check ([AvailableFrom] <= [AvailableTo])
)
go

grant select on Menus to owner
go

create table OneTimeDiscounts
(
    OneTimeDiscountID int identity
        constraint PK_OneTimeDiscounts
            primary key,
    CustomerID        int      not null
        constraint FK_OneTimeDiscounts_Customers1
            references Customers
            on update cascade on delete cascade,
    ExpirationDate    datetime not null,
    Discount          real     not null
        constraint CK_OneTimeDiscounts_Discount
            check ([Discount] >= 0 AND [Discount] <= 1),
    BeginingDate      datetime not null,
    constraint CK_OneTimeDiscounts_Date
        check ([BeginingDate] < [ExpirationDate])
)
go

create trigger TR_OneTimeDiscount_UpdateEarnedDiscount
on dbo.OneTimeDiscounts
for insert
as
begin
    if(select OneTimeDiscountID from inserted)not in(select OneTimeDiscountID from OneTimeDiscounts)
    begin
        RAISERROR('Podany OneTimeDiscountID nie istnieje', 16, 1)
        rollback transaction
    end
    if(select ExpirationDate from inserted)<GETDATE()
    begin
        RAISERROR('Podaj date większą niż dzisiaj! ', 16, 1)
        rollback transaction
    end
    if(select CustomerID from inserted)not in(select CustomerID from Customers)
    begin
        RAISERROR('Podany użytkownik nie istnieje', 16, 1)
        rollback transaction
    end
end
go

grant select on OneTimeDiscounts to owner
go

create table Orders
(
    OrderID           int identity
        constraint PK_Orders
            primary key,
    CustomerID        int
        constraint FK_Orders_Customers
            references Customers
            on update cascade on delete cascade,
    OrderDate         datetime       not null,
    PickUpDate        datetime,
    InvoiceID         int
        constraint FK_Orders_Invoices
            references Invoices,
    Discount          real default 0 not null
        constraint CHK_Orders
            check ([Discount] >= 0 AND [Discount] <= 1),
    OneTimeDiscountID int  default NULL
        constraint FK_Orders_OneTimeDiscounts1
            references OneTimeDiscounts
)
go

grant select on Orders to owner
go

create table Payments
(
    PaymentID int identity
        constraint PK_Payments
            primary key,
    OrderID   int      not null
        constraint FK_Payments_Orders
            references Orders,
    Date      datetime not null,
    Amount    money    not null
        constraint CHK_Payments_Amount
            check ([Amount] > 0)
)
go

CREATE trigger TR_Customers_GrantEarnedDiscount
on Payments
after insert
as
begin
    set NOCOUNT on
    begin
        declare @CustomerID int
        set @CustomerID=(
            select CustomerID from Orders O
            join Payments P
            on O.OrderID=P.OrderID and P.PaymentID=(select PaymentID from inserted))
        
        declare @NumberOfOrders int
        set @NumberOfOrders=(
            select count(Orders.OrderID) from Orders
            where CustomerID=@CustomerID)
        
        declare @NumberOfAmount int
        set @NumberOfAmount=(
            select sum(O.OrderValue)
            from Payments P
            join vwOrderData O on P.OrderID = O.OrderID and CustomerID=@CustomerID
            where O.OrderValue <= O.Paid)
        
        if @NumberOfAmount >=(select K1 from ConfigurationVariables) and 
                @NumberOfOrders>=(select Z1 from ConfigurationVariables)
        begin
            update Customers
            set EarnedDiscount=(select R1 from ConfigurationVariables)
            where CustomerID=@CustomerID
        end
    end
end
go

CREATE trigger TR_OneTimeDiscount_GrantOneTimeDiscount
on Payments
after insert
as
begin
    set NOCOUNT on
    begin
        declare @CustomerID int
        set @CustomerID=(
            select CustomerID from Orders O
            join Payments P
            on O.OrderID=P.OrderID and P.PaymentID=(select PaymentID from inserted))
        declare @StartingDay date
        set @StartingDay=(
            select max(BeginingDate) from OneTimeDiscounts
            where CustomerID=@CustomerID)
        if (@StartingDay is null)
            set @StartingDay = '1900-01-01'
        if(
            select sum(O.OrderValue)
            from Payments P
            join vwOrderData O on P.OrderID = O.OrderID and CustomerID=@CustomerID
            where O.OrderDate > @StartingDay and O.OrderValue <= O.Paid
            ) >=(select K2 from ConfigurationVariables)
        begin
            insert into OneTimeDiscounts (CustomerID, BeginingDate, ExpirationDate, Discount)
                values (
                    @CustomerID,
                    getdate(),
                    DATEADD(day, (select D1 from ConfigurationVariables),getdate()),
                    (select R2 from ConfigurationVariables)
                )
        end
    end
end
go

grant select on Payments to owner
go

create table Products
(
    ProductID       int identity
        constraint PK_Products
            primary key,
    ProductName     nvarchar(40) not null,
    CategoryID      int          not null
        constraint FK_Products_Categories
            references Categories
            on update cascade on delete cascade,
    QuantityPerUnit smallint     not null
        constraint CHK_Products_QuantityPerUnit
            check ([QuantityPerUnit] >= 0),
    UnitPrice       money        not null
        constraint CHK_Products_UnitPrice
            check ([UnitPrice] >= 0),
    UnitsInStock    smallint     not null
        constraint CHK_Products_UnitsInStock
            check ([UnitsInStock] >= 0)
)
go

create table MenuDetails
(
    MenuID    int not null
        constraint FK_MenuDetails_Menus
            references Menus,
    ProductID int not null
        constraint FK_MenuDetails_Products1
            references Products,
    constraint PK_MenuDetails
        primary key (MenuID, ProductID)
)
go

grant select on MenuDetails to owner
go

create table OrderDetails
(
    ProductID int      not null
        constraint FK_OrderDetails_Products
            references Products,
    OrderID   int      not null
        constraint FK_OrderDetails_Orders
            references Orders,
    Quantity  smallint not null
        constraint CHK_OrderDetails_Quantity
            check ([Quantity] >= 0),
    UnitPrice money    not null
        constraint CHK_OrderDetails_UnitPrice
            check ([UnitPrice] >= 0),
    constraint PK_OrderDetails
        primary key (OrderID, ProductID)
)
go

create trigger TR_OrderDetails_MondaySeaFoodCheck
on dbo.OrderDetails
after insert
as
begin
    set nocount on;
        if exists(
            select * from inserted as i
            inner join dbo.Orders as O on i.OrderID=O.OrderID
            inner join dbo.Products as P on i.ProductID=P.ProductID
            inner join dbo.Reservations as R on O.OrderID=R.OrderID
            where(datename(weekday, O.PickUpDate) like 'Thursday'
                and datediff(day,O.OrderDate, O.PickUpDate)<=2
                and P.CategoryID=5)
                    or (datename(weekday, O.PickUpDate) like 'Friday'
                and datediff(day,O.OrderDate, O.PickUpDate)<=3
                and P.CategoryID=5)
                    or (datename(weekday, O.PickUpDate) like 'Saturday'
                and datediff(day,O.OrderDate, O.PickUpDate)<=4
                and P.CategoryID=5)
                    or (datename(weekday, R.ReservationDateStart) like 'Thursday'
                and datediff(day,O.OrderDate, R.ReservationDateStart)<=2
                and P.CategoryID=5)
                    or (datename(weekday, R.ReservationDateStart) like 'Friday'
                and datediff(day,O.OrderDate, R.ReservationDateStart)<=3
                and P.CategoryID=5)
                    or (datename(weekday, R.ReservationDateStart) like 'Saturday'
                and datediff(day,O.OrderDate, R.ReservationDateStart)<=4
                and P.CategoryID=5)
            )
        begin;
        throw 50001, N'Zamównienie zawierajce owoce morza powinno być złożone maksymalnie do poniedziałku poprzedzającego zamówienie. ',1
    end
end
go

grant select on OrderDetails to owner
go

grant select on Products to owner
go

create table Reservations
(
    ReservationID        int identity
        constraint PK_Reservations
            primary key,
    ReservationDateStart datetime not null,
    ReservationDateEnd   datetime not null,
    Accepted             bit      not null,
    OrderID              int      not null
        constraint FK_Reservations_Orders
            references Orders,
    constraint CHK_Reservations_Date
        check ([ReservationDateStart] < [ReservationDateEnd])
)
go

create table EmployeesReservations
(
    ReservationID int not null
        constraint FK_EmployeesReservations_Reservations
            references Reservations,
    EmployeeID    int not null
        constraint FK_EmployeesReservations_Employees
            references Employees,
    constraint PK_EmployeesReservations
        primary key (ReservationID, EmployeeID)
)
go

grant select on EmployeesReservations to owner
go

create unique index UQ_Reservations_OrderID
    on Reservations (OrderID)
    where [OrderID] IS NOT NULL
go

grant select on Reservations to owner
go

create table Tables
(
    TableID   int identity
        constraint PK_Tables
            primary key,
    SeatCount tinyint not null
        constraint CHK_Tables_SeatCount
            check ([SeatCount] >= 1)
)
go

grant select on Tables to owner
go

create table TablesReservations
(
    ReservationID int not null
        constraint FK_ReservationDetails_Reservations
            references Reservations
            on update cascade on delete cascade,
    TableID       int not null
        constraint FK_ReservationDetails_Tables
            references Tables,
    constraint PK_TablesReservations
        primary key (ReservationID, TableID)
)
go

grant select on TablesReservations to owner
go

create table sysdiagrams
(
    name         sysname not null,
    principal_id int     not null,
    diagram_id   int identity
        primary key,
    version      int,
    definition   varbinary(max),
    constraint UK_principal_name
        unique (principal_id, name)
)
go

exec sp_addextendedproperty 'microsoft_database_tools_support', 1, 'SCHEMA', 'dbo', 'TABLE', 'sysdiagrams'
go

