CREATE view vwCustomerAvailableDiscount as
    select C.CustomerID, O.Discount, O.ExpirationDate from dbo.OneTimeDiscounts O
    inner join dbo.Customers C on C.CustomerID = O.CustomerID
    where O.ExpirationDate>GETDATE()
go

exec sp_addextendedproperty 'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "O"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "C"
            Begin Extent = 
               Top = 6
               Left = 246
               Bottom = 136
               Right = 418
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', 'dbo', 'VIEW', 'vwCustomerAvailableDiscount'
go

exec sp_addextendedproperty 'MS_DiagramPaneCount', 1, 'SCHEMA', 'dbo', 'VIEW', 'vwCustomerAvailableDiscount'
go

grant select on vwCustomerAvailableDiscount to employee
go

grant select on vwCustomerAvailableDiscount to owner
go

CREATE VIEW dbo.vwCustomerEarnedDiscount
AS
SELECT        CustomerID, EarnedDiscount, Lastname, Firstname, Address, City, Region, PostalCode, Country, Phone, CompanyID
FROM            dbo.Customers AS C
go

exec sp_addextendedproperty 'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "C"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 181
               Right = 210
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', 'dbo', 'VIEW', 'vwCustomerEarnedDiscount'
go

exec sp_addextendedproperty 'MS_DiagramPaneCount', 1, 'SCHEMA', 'dbo', 'VIEW', 'vwCustomerEarnedDiscount'
go

grant select on vwCustomerEarnedDiscount to employee
go

grant select on vwCustomerEarnedDiscount to owner
go

CREATE view dbo.vwCustomerStatistics as
    select C.CustomerID, count(O.OrderID) number_of_orders, sum(OD.OrderValue) as value_of_orders
        from dbo.Customers C
        inner join dbo.Orders O on C.CustomerID = O.CustomerID
        left join  dbo.vwOrderData OD on O.OrderID=OD.OrderID
group by C.CustomerID
go

grant select on vwCustomerStatistics to employee
go

grant select on vwCustomerStatistics to owner
go

create view vwFutureReservations as
select R.ReservationID,ReservationDateStart,ReservationDateEnd,T.TableID,SeatCount from Reservations R
join TablesReservations RD on R.ReservationID = RD.ReservationID and R.ReservationDateStart>GETDATE()
left join Tables T on RD.TableID = T.TableID
go

grant select on vwFutureReservations to employee
go

grant select on vwFutureReservations to owner
go

CREATE view vwInvoicesData as
select distinct I.InvoiceID,
       I.InvoiceDate,
       O.CustomerID,
       C.Firstname +' '+C.Lastname as 'Full_name',
       C.Address+' '+ C.City+' '+C.Country+' '+C.Region+' '+C.PostalCode as 'Address',
       C.Phone,
       sum (OD.OrderValue) as SummaryOrderValue,
       CO.CompanyID,
       CO.CompanyName from dbo.Invoices I
inner join dbo.Orders O on I.InvoiceID = O.InvoiceID
inner join dbo.Customers C on C.CustomerID = O.CustomerID
inner join dbo.vwOrderData OD on OD.OrderID=O.OrderID
left join dbo.Companies CO on CO.CompanyID=C.CompanyID
group by I.InvoiceID, I.InvoiceDate, O.CustomerID, C.Firstname +' '+C.Lastname, 
         C.Address+' '+ C.City+' '+C.Country+' '+C.Region+' '+C.PostalCode, C.Phone, 
         CO.CompanyID, CO.CompanyName
go

grant select on vwInvoicesData to employee
go

grant select on vwInvoicesData to owner
go

create view MenuStatistics as
select M.MenuID, M.AvailableFrom, M.AvailableTo, MD.ProductID, (
    select sum(Quantity)
    from OrderDetails OD
    join Orders O on OD.OrderID = O.OrderID 
    where OD.ProductID = MD.ProductID and OrderDate between M.AvailableFrom and M.AvailableTo
) as sellCount
from MenuDetails MD
join Menus M on MD.MenuID = M.MenuID
go

grant select on vwMenuStatistics to employee
go

grant select on vwMenuStatistics to owner
go

create view vwMonthlySalesStatistics as
select Year(OrderDate) as year,
       month(OrderDate) as month,
       P.ProductName,
       isNull(count(OD.ProductID),0) as NumberOfSales from Products P
left join OrderDetails OD on OD.ProductID=P.ProductID
left join Orders O on O.OrderID=OD.OrderID
group by P.ProductName,P.ProductID,Year(OrderDate),month(OrderDate)
go

CREATE view vwOrderData as
        	select O.OrderID, dbo.udfGetOrderValue(OrderID) as OrderValue,
        	CustomerID,
        	OrderDate, ISNULL((
        		select sum(Amount)
        		from Payments P
        		where P.OrderID = O.OrderID
        	), 0) as Paid,
        	PickUpDate,
        	InvoiceID,
        	Discount,
                OneTimeDiscountID
        	from Orders O
go

exec sp_addextendedproperty 'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "O"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 196
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', 'dbo', 'VIEW', 'vwOrderData'
go

exec sp_addextendedproperty 'MS_DiagramPaneCount', 1, 'SCHEMA', 'dbo', 'VIEW', 'vwOrderData'
go

grant select on vwOrderData to employee
go

grant select on vwOrderData to owner
go

CREATE view OrderStatisticsMonthly as
select
    year(O.OrderDate) as 'year',
    month(O.OrderDate) as 'month',
    isNull(count(O.OrderID), 0) as 'OrdersCount',
    isNull(sum(OD.Quantity * OD.UnitPrice * (1 - O.Discount)), 0) as 'OrdersValue'
from Orders O
join OrderDetails OD on O.OrderID = OD.OrderID
group by year(O.OrderDate), month(O.OrderDate)
go

grant select on vwOrderStatisticsMonthly to employee
go

grant select on vwOrderStatisticsMonthly to owner
go

CREATE view OrderStatisticsWeekly as
select
    year(O.OrderDate) as 'year',
    DATEPART(week, O.OrderDate) as 'week',
    isNull(count(O.OrderID), 0) as 'OrdersCount',
    isNull(sum(OD.Quantity * OD.UnitPrice * (1 - O.Discount)), 0) as 'OrdersValue'
from Orders O
join OrderDetails OD on O.OrderID = OD.OrderID
group by year(O.OrderDate), DATEPART(week, O.OrderDate)
go

grant select on vwOrderStatisticsWeekly to employee
go

grant select on vwOrderStatisticsWeekly to owner
go

CREATE VIEW dbo.vwOrdersToPickUp
AS
SELECT        OrderID, CustomerID, OrderDate, Discount, PickUpDate
FROM            dbo.Orders
WHERE        (PickUpDate IS NOT NULL) AND (PickUpDate > GETDATE())
go

exec sp_addextendedproperty 'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "Orders"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 181
               Right = 208
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', 'dbo', 'VIEW', 'vwOrdersToPickUp'
go

exec sp_addextendedproperty 'MS_DiagramPaneCount', 1, 'SCHEMA', 'dbo', 'VIEW', 'vwOrdersToPickUp'
go

grant select on vwOrdersToPickUp to employee
go

grant select on vwOrdersToPickUp to owner
go

CREATE view vwOverPaidOrders as
                select OrderID, OrderValue, CustomerID, OrderDate, 
                    PickUpDate, InvoiceID, Discount, OneTimeDiscountID
                from vwOrderData OD
                where OD.OrderValue - OD.Paid < 0
go

grant select on vwOverpaidOrders to employee
go

grant select on vwOverpaidOrders to owner
go

CREATE view  dbo.vwOwingCustomers as
select UPO.CustomerID customer_id, sum(OD.OrderValue) orders_value
from dbo.vwUnPaidOrders UPO
	inner join dbo.vwOrderData OD on UPO.CustomerID=OD.CustomerID
group by UPO.CustomerID
go

exec sp_addextendedproperty 'MS_DiagramPane1', N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "UPO"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 224
            End
            DisplayFlags = 280
            TopColumn = 0
         End
         Begin Table = "OD"
            Begin Extent = 
               Top = 6
               Left = 262
               Bottom = 136
               Right = 448
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 12
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
', 'SCHEMA', 'dbo', 'VIEW', 'vwOwingCustomers'
go

exec sp_addextendedproperty 'MS_DiagramPaneCount', 1, 'SCHEMA', 'dbo', 'VIEW', 'vwOwingCustomers'
go

grant select on vwOwingCustomers to employee
go

grant select on vwOwingCustomers to owner
go

create view vwPendingReservationsRequests as
select R.ReservationID,ReservationDateStart,ReservationDateEnd,T.TableID,SeatCount from Reservations R
join TablesReservations RD on R.ReservationID = RD.ReservationID and R.Accepted=0
left join Tables T on RD.TableID = T.TableID
go

grant select on vwPendingReservationsRequests to employee
go

grant select on vwPendingReservationsRequests to owner
go

create view ProductsData as
select P.ProductName, C.CategoryName, C.Description
from dbo.Products as P
	inner join dbo.Categories C on C.CategoryID=P.CategoryID
go

grant select on vwProductsData to employee
go

grant select on vwProductsData to owner
go

CREATE view vwProductsOverallSales as
	select P.ProductID,
		P.ProductName,
		(
			select(count(OD.OrderID))
			from OrderDetails OD
			where OD.ProductID = P.ProductID
		) as SalesCount,
		CategoryID,
		QuantityPerUnit,
		UnitPrice,
		UnitsInStock
	from Products P
go

grant select on vwProductsOverallSales to employee
go

grant select on vwProductsOverallSales to owner
go

create view vwReservationsData as
select R.ReservationID,ReservationDateStart,ReservationDateEnd,T.TableID,SeatCount from Reservations R
join TablesReservations RD on R.ReservationID = RD.ReservationID and R.Accepted=1
left join Tables T on RD.TableID = T.TableID
go

grant select on vwReservationsData to employee
go

grant select on vwReservationsData to owner
go

create view vwTablesReservationsMontly as
select year(ReservationDateStart) as year,
       month(ReservationDateStart) as month,
       T.TableID,
       T.SeatCount,
       isNull(count(RD.TableID),0) as NumberOfReservation from Tables T
left join TablesReservations RD on T.TableID = RD.TableID
left join Reservations R2 on RD.ReservationID = R2.ReservationID
group by year(ReservationDateStart),month(ReservationDateStart),T.TableID,T.SeatCount
go

create view vwTablesReservationsWeekly as
select year(ReservationDateStart) as year,
       datepart(week,ReservationDateStart) as week,
       T.TableID,
       T.SeatCount,
       count(RD.TableID) as NumberOfReservation from Tables T
left join TablesReservations RD on T.TableID = RD.TableID
left join Reservations R2 on RD.ReservationID = R2.ReservationID
group by year(ReservationDateStart),datepart(week,ReservationDateStart),T.TableID,T.SeatCount
go

CREATE view vwUnPaidOrders as
    select OrderID, OrderValue, CustomerID, OrderDate,
        PickUpDate, InvoiceID, Discount, OneTimeDiscountID
    from vwOrderData OD
    where Paid < OD.OrderValue
go

grant select on vwUnPaidOrders to employee
go

grant select on vwUnPaidOrders to owner
go

create view vwWeeklySalesStatistics as
select Year(OrderDate) as year,
       datepart(week,OrderDate) as week,
       P.ProductName,
       isNull(count(OD.ProductID),0) as NumberOfSales from Products P
left join OrderDetails OD on OD.ProductID=P.ProductID
left join Orders O on O.OrderID=OD.OrderID
group by P.ProductName,P.ProductID,Year(OrderDate),datepart(week,OrderDate)
go

