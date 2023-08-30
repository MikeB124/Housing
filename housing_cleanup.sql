-- Cleaning Data in SQL Queries


select * 
from housing_data.dbo.nashville_housing;


-- Standardize Date Format

-- convert from date-time format to a date format ----which is dropping the time

-- test to see expected transformation
Select saledate, convert(date,saledate)
from ..nashville_housing;

-- add a column to the table - update in place did not yield expected transformation
alter table housing_data.dbo.nashville_housing
ADD SaleDateConverted Date;

-- fill the new column with the adjusted dates
UPDATE housing_data.dbo.nashville_housing
SET SaleDateConverted = CONVERT(DATE,saledate);

-- will drop the original

-----Populate Property Address data



-- find the blank property address 
Select PropertyAddress
from housing_data.dbo.nashville_housing
where PropertyAddress is null;

-- can use parcel ID to populate the blank address, use a conditional
--do a self join
-- use "isnull" to check is

select * 
from housing_data.dbo.nashville_housing
where PropertyAddress is null
order by ParcelID;

-- use isnull to what do we want to check to see if it is null, if it is null...what do we need to populate
--example when a.propertyaddres is null, replace with b.propertyadress
select a.ParcelID, a.PropertyAddress, b.parcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from housing_data.dbo.nashville_housing a
join housing_data.dbo.nashville_housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;
	

---this will update the table based on conditional
UPDATE a 
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from housing_data.dbo.nashville_housing a
join housing_data.dbo.nashville_housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;

--rerun to confirm update
select a.ParcelID, a.PropertyAddress, b.parcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from housing_data.dbo.nashville_housing a
join housing_data.dbo.nashville_housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;
	

-- Breaking Address out into individual columns(Address,City, State

SELECT PropertyAddress
From housing_data.dbo.nashville_housing;

--substring is a method to search for a string, 'char index allows you to look for a string and it returns the position
-- testing
SELECT
SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, charindex(',',PropertyAddress) + 1, LEN(PropertyAddress)) as Address

from housing_data.dbo.nashville_housing;

-- Create two new columns
-- add a column to the table - 
alter table housing_data.dbo.nashville_housing
ADD PropertySplitAddress Nvarchar(255);

-- fill the new column with the adjusted dates
UPDATE housing_data.dbo.nashville_housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,charindex(',',PropertyAddress)-1);


-- add a column to the table - update in place did not yield expected transformation
alter table housing_data.dbo.nashville_housing
ADD PropertySplitCity Nvarchar(255);

-- fill the new column with the adjusted dates
UPDATE housing_data.dbo.nashville_housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, charindex(',',PropertyAddress) + 1, LEN(PropertyAddress));

Select *
from housing_data.dbo.nashville_housing;

--Owner Address

Select OwnerAddress
from housing_data.dbo.nashville_housing;

--use parsename to split by delimiter 
--parsename only works with "." as delimiter
--you can REPLACE the current delimiter with a "." <-period so you can use it 
-- instead of using  substring method

SELECT
PARSENAME(OwnerAddress, 1)
from housing_data.dbo.nashville_housing;

--replace comma with period within the parsename method
--parsename starts with the last position as the first position 
SELECT
PARSENAME(REPLACE(owneraddress, ',','.'), 3) as address,
PARSENAME(REPLACE(owneraddress, ',','.'), 2) as city,
PARSENAME(REPLACE(owneraddress, ',','.'), 1) as state
from housing_data.dbo.nashville_housing;


--lets add column to the table and populate the columns
--Address
alter table housing_data.dbo.nashville_housing
ADD OwnersplitAddress Nvarchar(255);

-- fill the new column with the adjusted dates
UPDATE housing_data.dbo.nashville_housing
SET OwnersplitAddress = PARSENAME(REPLACE(owneraddress, ',','.'), 3);


--City
alter table housing_data.dbo.nashville_housing
ADD Ownersplitcity Nvarchar(255);

-- fill the new column with the adjusted dates
UPDATE housing_data.dbo.nashville_housing
SET Ownersplitcity = PARSENAME(REPLACE(owneraddress, ',','.'), 2);


-- State
alter table housing_data.dbo.nashville_housing
ADD Ownersplitstate Nvarchar(255);

-- fill the new column with the adjusted dates
UPDATE housing_data.dbo.nashville_housing
SET Ownersplitstate = PARSENAME(REPLACE(owneraddress, ',','.'), 1);


--confirm added
Select *
from housing_data.dbo.nashville_housing;

-- CHANGE Y AND N to YES and NO in Sold as Vacant field

select distinct(SoldAsVacant), count(soldasvacant)
from housing_data.dbo.nashville_housing
group by SoldAsVacant
order by 2;

--case statement
SELECT SoldAsVacant,
CASE when SoldAsVacant = 'Y' then 'YES'
	when SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	end
from housing_data.dbo.nashville_housing

--update in place
update housing_data.dbo.nashville_housing
set SoldAsVacant = CASE when SoldAsVacant = 'Y' then 'YES'
	when SoldAsVacant = 'N' then 'No'
	ELSE SoldAsVacant
	end

--remove duplicates
--normaly do not delete data
--write a CTE, window function to find duplicate value


--windows functions
with rownumcte as(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UNIQUEID
						)row_num
from housing_data.dbo.nashville_housing
--order by ParcelID
)
select *
from rownumcte
where row_num > 1
--order by PropertyAddress;



--to delete run the same query with the delete statement

with rownumcte as(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY
						UNIQUEID
						)row_num
from housing_data.dbo.nashville_housing
--order by ParcelID
)
DELETE
from rownumcte
where row_num > 1
--order by PropertyAddress;

-- Delete unused columns
select *
from housing_data.dbo.nashville_housing

Alter table housing_data.dbo.nashville_housing
drop column owneraddress,taxdistrict,propertyaddress;

Alter table housing_data.dbo.nashville_housing
drop column saledate;























































































































































































select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress,b.PropertyAddress)
from ..nashville_housing as A
join ..nashville_housing as B
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null;