USE Portfolio_Project

SELECT * 
FROM Portfolio_Project..Nashville_Housing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


SELECT SaleDate, CONVERT(Date,SaleDate)
FROM Nashville_Housing

UPDATE Nashville_Housing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE Nashville_Housing
Add SaleDateConverted Date; 

UPDATE Nashville_Housing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM Portfolio_Project..Nashville_Housing


-- Populate Property Address data

SELECT *
FROM Nashville_Housing
WHERE PropertyAddress is null

SELECT *
FROM Nashville_Housing
--WHERE PropertyAddress is null
order by ParcelID

-- Trying to populate property when 2 parce ids are the same 

SELECT a.ParcelID , a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville_Housing a
JOIN Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b. [UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Nashville_Housing a
JOIN Nashville_Housing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b. [UniqueID ]
WHERE a.PropertyAddress is null


-- Breaking out Adress into individual Columns (Address, City , State)

SELECT PropertyAddress
FROM Nashville_Housing

-- Find where the ',' is and cut the string into 2 pieces remove the ',' in the process

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN (PropertyAddress)) as Address
FROM Nashville_Housing

--Create two new values and add the property in 

ALTER TABLE Nashville_Housing
Add PropertySplitAddress Nvarchar(255); 

UPDATE Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1)

ALTER TABLE Nashville_Housing
Add PropertySplitCity Nvarchar(255); 

UPDATE Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,LEN (PropertyAddress))


SELECT * 
FROM Nashville_Housing

SELECT OwnerAddress
FROM Nashville_Housing

-- Delimit string with PARSENAME

SELECT  
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Nashville_Housing

--Odd thing it does things backwards ...


--------------------------------------------------------------------------------------------------------------------------

-- Create again the new columns

ALTER TABLE Nashville_Housing
Add OwnerSplitAddress Nvarchar(255); 

UPDATE Nashville_Housing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Nashville_Housing
Add OwnerSplitCity Nvarchar(255); 

UPDATE Nashville_Housing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Nashville_Housing
Add OwnerSplitState Nvarchar(255); 

UPDATE Nashville_Housing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM Nashville_Housing

--------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant),COUNT(SoldAsVacant)
FROM Nashville_Housing
Group By SoldAsVacant
order by 2

SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM Nashville_Housing

UPDATE Nashville_Housing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


--------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates (Best practice is to add the non-dublicates in a new column, here we are just gonna delete.)

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num

FROM Nashville_Housing
--ORDER BY ParcelID
)

SELECT * 
FROM RowNumCTE 
WHERE row_num > 1
--Order by PropertyAddress


--------------------------------------------------------------------------------------------------------------------


-- Delete Unused Columns

Select * 
From Nashville_Housing

ALTER TABLE Nashville_Housing
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress

ALTER TABLE Nashville_Housing
DROP COLUMN SaleDate