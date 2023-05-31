-- Standardize Data Format
-- *** Standardised values 

select 
	SaleDate,
	SaleDateConverted
from 
	PortProj2..NashvilleHousing;

alter table 
	PortProj2..NashvilleHousing
add
	SaleDateConverted Date; 

update 
	PortProj2..NashvilleHousing
set 
	SaleDateConverted = CONVERT(date, SaleDate);

-- FILLING IN ADDRESS NULLS 
-- *** Used Joins to fill in null values 

-- Populate Property Address Data --
-- I do not fully understand how structure of this query 

select
	a.[UniqueID ],
	a.ParcelID,
	a.PropertyAddress,
	b.[UniqueID ],
	b.ParcelID,
	b.PropertyAddress,
	ISNULL(a.propertyaddress, b.PropertyAddress) 
from 
	PortProj2..NashvilleHousing as a
join
	PortProj2..NashvilleHousing as b 
on 
	a.ParcelID = b.ParcelID and 
	a.[UniqueID ] <> b.[UniqueID ]
where
	a.PropertyAddress is null


update 
	a
set
	PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress) 
from 
	PortProj2..NashvilleHousing as a
join
	PortProj2..NashvilleHousing as b 
on 
	a.ParcelID = b.ParcelID and 
	a.[UniqueID ] <> b.[UniqueID ]
where
	a.PropertyAddress is null;

-- CLEANING THE ADDRESSES
-- *** String functions: CHARINDEX(), SUBSTRING(), REPLACE(), PARSENAME(), LEN()
-- *** Parsing


-- PART 1) Breaking out address into individual columns (Address, City, State)
---


select 
	-- PropertyAddress,
	-- CHARINDEX(',', PropertyAddress) as 'Position of the comma',
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as 'Property Address', 
	-- LEN(PropertyAddress) as 'Length',
	LTRIM(RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress))) as 'City'
from  
	PortProj2..NashvilleHousing; 

--- ALTERNATIVE METHOD - The 3rd argument in substring is the number of characters you want to extract 
select 
	PropertyAddress, 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as 'Property Address', 
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(propertyaddress))
from
	PortProj2..NashvilleHousing


alter table
	PortProj2..NashvilleHousing
add
	PropertySplitAddress nvarchar(255);

update
	PortProj2..NashvilleHousing
set
	PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1); 
	
alter table
	PortProj2..NashvilleHousing
add
	PropertySplitCity nvarchar(255);

update
	PortProj2..NashvilleHousing
set
	PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(propertyaddress)); 

select 
	*
from 
	PortProj2..NashvilleHousing;
	

-- PART 2) Breaking our owner address into individual columns (Address, City, State)

select 
	OwnerAddress,
	REPLACE(owneraddress, ',', '.'),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
from 
	PortProj2..NashvilleHousing;


alter table
	PortProj2..NashvilleHousing
add
	OwnerSplitAddress nvarchar(255);

update
	PortProj2..NashvilleHousing
set
	OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3); 

alter table
	PortProj2..NashvilleHousing
add
	OwnerSplitCity nvarchar(255);

update
	PortProj2..NashvilleHousing
set
	OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2); 

alter table
	PortProj2..NashvilleHousing
add
	OwnerSplitState nvarchar(255);

update
	PortProj2..NashvilleHousing
set
	OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1); 

select 
	*
from 
	PortProj2..NashvilleHousing;


---------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to yes and no in 'Sold as vacant field'
-- *** Case statements 

select 
	SoldAsVacant,
	case
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end as YesOrNo
from
	PortProj2..NashvilleHousing
where SoldAsVacant in ('Y', 'N');

update 
	PortProj2..NashvilleHousing
set SoldAsVacant = 
	case
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end; 

---------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicate Rows
-- *** CTE's and windows functions to locate duplicate values 
-- You have to partition on the columns that will be unique for each row (ignoring UNIQUE ID)

WITH RowNumCTE as (
select 
	*,
	ROW_NUMBER() OVER (
	PARTITION BY 
		ParcelID, 
		PropertyAddress, 
		SalePrice, 
		SaleDate,
		LegalReference
		ORDER BY 
			UNIQUEID
			) row_num
from 
	PortProj2..NashvilleHousing
)
delete
from 
	RowNumCTE
where
	row_num > 1;



WITH RowNumCTE as (
select 
	*,
	ROW_NUMBER() OVER (
	PARTITION BY 
		ParcelID, 
		PropertyAddress, 
		SalePrice, 
		SaleDate,
		LegalReference
		ORDER BY 
			UNIQUEID
			) row_num
from 
	PortProj2..NashvilleHousing
)
select
	*
from 
	RowNumCTE
where
	row_num > 1;



---------------------------------------------------------------------------------------------------------------------------------

--	Delete Unused Columns 
-- *** Simple ALTER COLUMN and DROP COLUMN

alter table 
	PortProj2..NashvilleHousing
drop column
	PropertyAddress,
	OwnerAddress, 
	TaxDistrict,
	SaleDate;

select
	*
from 
	PortProj2..NashvilleHousing;
	
--------------------------------------------------------------------------------------

-- RANDOM STUFF 

select
	ROW_NUMBER() OVER (order by saleprice) as 'Row Number', 
	[UniqueID ],
	OwnerName, 
	SalePrice
	
from 
	PortProj2..NashvilleHousing
