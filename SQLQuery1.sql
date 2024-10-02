---------------------------------------------------- Q 1 ------------------------------------------------------------
select CONCAT(Fname,' ' ,Lname) as [Full Name]
from Employee
where len(Fname) > 3

---------------------------------------------------- Q 2 --------------------------------------------------------------
select Count(Title) as [NO OF PROGRAMMING BOOKS]
from Book
where Cat_id IN (select Id from Category where Cat_name = 'programming' )

---------------------------------------------------- Q 3 -------------------------------------------------------------
select count(Title) as [NO_OF_BOOKS]
from Book inner join Publisher
ON Publisher_id = Publisher.Id
where Name = 'HarperCollins'

---------------------------------------------------- Q 4 --------------------------------------------------------------
select SSN , [User_Name] , Borrow_date , Due_date
from Users inner join Borrowing
ON SSN = User_ssn
where (Year(Due_date) = 2022 and MONTH(Due_date) <= 7) or (YEAR(Due_date) < 2022)

---------------------------------------------------- Q 5 ------------------------------------------------------------
select CONCAT(Title ,' is written by ' , [Name])
from Book inner join Book_Author
ON Book.Id = Book_Author.Book_id
inner join Author
ON Book_Author.Author_id = Author.Id

---------------------------------------------------- Q 6 -----------------------------------------------------------
select [User_Name]
from Users
where [User_Name] Like 'A%' or [User_Name]  Like '%A' or [User_Name] Like '%A%'

---------------------------------------------------- Q 7 -----------------------------------------------------------
select top 1 User_ssn
from Borrowing
group by User_ssn
order by count(*) desc

---------------------------------------------------- Q 8 ------------------------------------------------------------
select User_ssn ,SUM(Amount) as [Total amount of money]
from Borrowing
group by User_ssn

---------------------------------------------------- Q 9 ------------------------------------------------------------
select top 1 Cat_name 
from Borrowing inner join Book
ON Book_id = Book.Id
inner join Category
ON Category.Id = Cat_id
group by Cat_name , Title
order by SUM(Amount) asc

---------------------------------------------------- Q 10 -----------------------------------------------------------
select Email , [Address] , DOB
from Employee
where Email is Null or [Address] is Null 

---------------------------------------------------- Q 11 -----------------------------------------------------------
select Cat_name , COUNT(*) as [Count Of Books]
from Category inner join Book
ON Category.Id = Cat_id
group by Cat_name

---------------------------------------------------- Q 12 ------------------------------------------------------------
select Id
from Book inner join Shelf
ON Shelf_code = Code 
where Floor_num <> 1 and Shelf_code <> 'A1'

---------------------------------------------------- Q 13 ------------------------------------------------------------
select Floor_no ,Num_blocks, COUNT(*) as [Number of employees]
from Employee inner join Floor
ON Floor_no = Number
group by Floor_no , Num_blocks

--------------------------------------------------- Q 14 -------------------------------------------------------------
select *
from Borrowing inner join Book
ON Book_id = Book.Id
inner join Users
ON User_ssn = SSN
where Borrow_date between '2022-01-03' and '2022-01-10'

---------------------------------------------------- Q 15 ------------------------------------------------------------
select CONCAT(e1.Fname,' ',e1.Lname) as [Full Name] , CONCAT(e2.Fname,' ',e2.Lname) as [Supervisor Name]
from Employee e1 join employee e2
ON e1.Super_id = e2.Id

---------------------------------------------------- Q 16 -------------------------------------------------------------------
select CONCAT(Fname,' ',Lname) as [Full Name] , coalesce (Salary , Bouns)
from Employee

------------------------------------------------------ Q 17 --------------------------------------------------------------------------
select MIN(salary) as [Min Salary] , MAX(Salary) as [Max Salary]
from Employee

------------------------------------------------------ Q 18 ---------------------------------------------------------------------------
create function EvenOdd(@num int)    -- scalar function return value
returns varchar(20)
     begin
	    declare @type varchar(20)
	    if @num % 2 <> 0
		   select @type = 'Odd'
		   
		else 
		   select @type = 'Even'
		return @type

	 end
--calling
select dbo.EvenOdd(100)

--------------------------------------------------------- Q 19 -----------------------------------------------------------------------
-- inline function return table only use select
create function ViewBooks (@cat_name varchar(20)) 
returns table
as
return
(
       select Title from Book
	   where Cat_id = Any (select Id from Category
	                       where Cat_name = @cat_name)
)
--calling
--deal with table
select * from ViewBooks('programming')

---------------------------------------------------------- Q 20 -----------------------------------------------------------------------
create function Info (@phone varchar(50)) 
returns table
as
return
(
      select Title , [User_Name] , Amount ,Due_date
      from User_phones inner join Users 
      ON User_phones.User_ssn = SSN
      inner join Borrowing
      ON Borrowing.User_ssn = SSN
	  inner join Book
	  ON Book.Id = Book_id
      where Phone_num = @phone
)
--calling
--deal with table
select * from Info('0010235555')

----------------------------------------------------------- Q 21 ---------------------------------------------------------------------
create Function isduplicated (@name varchar(20))
returns varchar(50)
        begin
		    declare @count int
		    select @count = count(*)
			from Users
			group by [User_Name]
			having [User_Name] = @name
			declare @format varchar(50)
			if @count > 1
			   set @format = CONCAT(@name , ' is Repeated ',@count,' times ')
			else if @count = 1
			   set @format = CONCAT(@name , ' is not duplicated ')
			else
			   set @format = CONCAT(@name , ' is Not Found ')
			return @format



		end

select dbo.isduplicated('Amr Ahmed')

------------------------------------------------------------------- Q 22 --------------------------------------------------------------
create function [DateFormat] (@date varchar(20) , @format int)
returns varchar(20)
as
    begin
	   
	   declare @formatting_date varchar(20)
       select @formatting_date = convert(varchar(20),@date,@format)             
	   return @formatting_date
	end

select dbo.[DateFormat]('3/5/2022' , 23)

------------------------------------------------------------------ Q 23 --------------------------------------------------------------
create procedure NumOfBooks 
as
    select Cat_name , COUNT(*)
	from Book inner join Category
	ON Book.Cat_id = Category.Id
	group by Cat_name

-- call
NumOfBooks

----------------------------------------------------------------- Q 24 -----------------------------------------------------------------
create procedure UpdateManager (@OldEmp_id int , @NewEmp_id int ,@NumOfFloor int)
as
     update [Floor]
	 set MG_ID = @NewEmp_id
	 where Number = @NumOfFloor

	 update [Floor]
	 set Hiring_Date = getdate()
	 where Number = @NumOfFloor

UpdateManager 3,10,1

------------------------------------------------------------------- Q 25 ----------------------------------------------------------------  
create view AlexandCairoEmp
as
     select *
	 from Employee
	 where [Address] = 'Alex' or [Address] = 'Cairo'

select * from AlexandCairoEmp

------------------------------------------------------------------ Q 26 ------------------------------------------------------------------
create view v2 
as
     select Shelf_code , count(*) as [Number of books]
	 from Book
	 group by Shelf_code


select * from v2

-------------------------------------------------------------------- Q 27 -------------------------------------------------------------------
create view v3
as
   select top 1 Shelf_code
   from v2
   order by [Number of books] desc

select * from v3

------------------------------------------------------------------- Q 28 --------------------------------------------------------------------
Create Table ReturnedBookss
(
	UserSSN int,
	BookId  int,
	DueDate date,
	ReturnDate Date,
	Fees Money
)

Create Trigger ReturnDateWithFees
On ReturnedBookss
instead of insert
as
	Declare @DueDate Date , @ReturnDate Date , @UserSSN int , @BookId int , @Fees int , @DueDate2 Date

	Select @UserSSN = UserSSN       from inserted
	Select @BookId  = BookId        from inserted
	Select @DueDate = DueDate	    from inserted
	Select @ReturnDate = ReturnDate from inserted
	Select @DueDate2 = Due_Date From Borrowing Where User_ssn = @UserSSN and Book_id = @BookId
	Select @Fees = Amount * 0.2 From Borrowing

	if @DueDate2 < @ReturnDate
		insert into ReturnedBooks
		Values (@UserSSN , @BookId , @DueDate , @ReturnDate , @Fees)
	else
		insert into ReturnedBooks
		Values (@UserSSN , @BookId , @DueDate , @ReturnDate , 0)

insert into ReturnedBooks
Values (1,3,'2021-02-27' , GETDATE() , null)
------------------------------------------------------- Q 29 ---------------------------------------------------------------------------
insert into Floor
values(7,2,20,GETDATE())
go
update Employee
set Floor_no = 7
where Id = 20
---
update Floor
set MG_ID = 5
where Number = 6

update Floor
set MG_ID = 12
where Number = 4

update Employee
set Floor_no = 6
where Id = 5

update Employee
set Floor_no = 4
where Id = 12

----------------------------------------------------------------- Q 30 -----------------------------------------------------------
Create View V2006Check
With Encryption
as
	Select MG_ID [EmpNumber] , Number [FloorNumber] , Num_blocks , Hiring_Date [JoiningDate]
	From Floor
	Where Hiring_Date between '2022-03-01' and '2022-05-30'
	With Check Option

Select * From V2006Check

insert into V2006Check ([EmpNumber] , Num_blocks , FloorNumber , JoiningDate)
values (2,6,2,'2023-07-08')
----------------------------------------------------------------- Q 31 -----------------------------------------------------------------
create trigger TT
on employee
instead of insert , update , delete 
as 
      select 'You can not take any action with this Table'


update Employee
set Floor_no = 4
where Id = 12
---------------------------------------------------------------- Q 32 ------------------------------------------------------------------
--A
insert into User_phones   -- give me error because there is no user with SSN = 20
values(50,'01227791844')
--B
drop trigger TT
update Employee      -- Error because Id (primary key) must be unique
set Id = 21
where Id = 20
--C
delete from Employee    --- Error because it is foriegn key in other table (NO ACTION)
where Id = 1
--D
delete from Employee    --- Error because it is foriegn key in other table (NO ACTION)
where Id = 12
--E
create clustered index i4  ---You Can not create more than one clustered index on table , you can create non clustered index
on employee(Salary)

------------------------------------------------------- Exam Finished successfully ----------------------------------------------------------------------

