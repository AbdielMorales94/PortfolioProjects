/* 

Cleaning Data in SQL Queries

*/

Select *
FROM [Portfolio_Project].[dbo].[NashvilleHousing]

--Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)
FROM [Portfolio_Project].[dbo].[NashvilleHousing]

--Update NashvilleHousing
--SET SaleDate = CONVERT(Date,SaleDate)

--Change the Data type of the SalesDate column to Date

ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate Date

--Populate Property Address Data

--WHERE is to  look for NULL Data in the table, later order by is to check data by ParcelID which is something that they will have in common.
Select *
FROM [Portfolio_Project].[dbo].[NashvilleHousing]
WHERE PropertyAddress is NULL
 --Order By ParcelID

--Here you are going to selfjoin the table to fill out the NULL values with the values that they have in common

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio_Project].[dbo].[NashvilleHousing] a
JOIN [Portfolio_Project].[dbo].[NashvilleHousing] b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL


Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio_Project].[dbo].[NashvilleHousing] a
JOIN [Portfolio_Project].[dbo].[NashvilleHousing] b
     on a.ParcelID = b.ParcelID
	 AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

--Breaking out Address into Individual Columns (Address, City, State) 

Select PropertyAddress
FROM [Portfolio_Project].[dbo].[NashvilleHousing]
--WHERE PropertyAddress is NULL
 --Order By ParcelID

 --Substring to extract characters, then column, starting point, CHARINDEX to especify the ',' then name it, 
 --2nd CHARINDEX to check placement number for the ,
Select
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)) as Address, 
  CHARINDEX(',', PropertyAddress)
  FROM [Portfolio_Project].[dbo].[NashvilleHousing]

--(-1) To remove the ',' from our column and to identify the values that we are  going to extract for our new columns 
-- CHARINDEX as starting position because we want the value after the ',' , +1 to remove   the ',' LEN as lenght because the lenght varies from 
-- address to address

Select
 SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
 SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
 FROM [Portfolio_Project].[dbo].[NashvilleHousing]


--ADD THE NEW COLUMNS and insert  the values into them

 ALTER TABLE NashvilleHousing
 ADD PropertySplitAddress NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--CHECK THE RESULTS

SELECT*
FROM NashvilleHousing

SELECT OwnerAddress
FROM NashvilleHousing

--Do the same  with the OwnerAddress Field but instead using PARSENAME since its easier, REPLACE is  because PARSENAME only acts when there are '.' so you have to change the ',' to  '.'
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.')  , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.')  , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.')  , 1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.')  , 3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.')  , 2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.')  , 1)

SELECT*
FROM NashvilleHousing

--Change Y and N to Yes and No in the SoldAsVacant Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS TotalSold
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY TotalSold

SELECT SoldAsVacant
 ,   CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	     WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = 
    CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	     WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM NashvilleHousing


--Remove DUPLICATE DATA

WITH RowNumCTE AS(
SELECT*
, ROW_NUMBER() OVER(
      PARTITION BY ParcelID,
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   ORDER BY
				     UniqueID
				   ) row_num

FROM NashvilleHousing
)

SELECT*
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


--DELETE UNUSED COLUMNS

SELECT*
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN  OwnerAddress, TaxDistrict, PropertyAddress

