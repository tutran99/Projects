/*

Cleansing Data With SQL Queries

*/



SELECT *
FROM PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- STANDARDISE DATE FORMAT --

SELECT	SaleDate, 
		CONVERT(Date,SaleDate)
FROM PortfolioProject..NashvilleHousing

-- Convert sale date column to date format (removing timer)
ALTER TABLE NashvilleHousing
ALTER COLUMN SaleDate date

 --------------------------------------------------------------------------------------------------------------------------

-- POPULATE PROPERTY ADDRESS DATA --

-- Searching for NULL values for property address
SELECT *
FROM PortfolioProject..NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT	a.ParcelID, 
		a.PropertyAddress, 
		b.ParcelID, 
		b.PropertyAddress, 
		ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
--WHERE a.PropertyAddress IS NULL

-- Update NULL values to contain appropriate address
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--------------------------------------------------------------------------------------------------------------------------

-- SPLITTNG UP ADDRESS (ADDRESS, CITY, STATE) TO MAKE DATA MORE USABLE --

-- PROPERTY --
-- Separate and remove commas
SELECT	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS address,
		SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS city
FROM PortfolioProject..NashvilleHousing

-- Add new columns for splitting property address
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);

-- Populate data into columns added above
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



-- OWNER --
SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

-- Separate and remove commas
SELECT	PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS address,
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS city,
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS state
FROM PortfolioProject..NashvilleHousing

-- Add new columns for splitting owner address
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

ALTER TABLE NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

-- Populate data into columns added above
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

--------------------------------------------------------------------------------------------------------------------------

-- MAINTAINING DATA CONSISTENCY --

-- Change Y and N to Yes and No in "SoldAsVacant" field 
SELECT	DISTINCT(SoldAsVacant), 
		COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
	CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
FROM PortfolioProject..NashvilleHousing
--WHERE SoldAsVacant = 'Y' OR SoldAsVacant = 'N'

UPDATE NashvilleHousing
SET SoldAsVacant =	CASE
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- REMOVE DUPLICATES --

WITH RowNumCTE AS 
(
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
		ORDER BY UniqueID
	) row_num

FROM PortfolioProject.dbo.NashvilleHousing
)
SELECT * -- replace with DELETE
FROM RowNumCTE
WHERE row_num > 1 -- greater than one indicates duplicate(s) of row exists
ORDER BY ParcelID 

SELECT *
FROM PortfolioProject..NashvilleHousing

---------------------------------------------------------------------------------------------------------

-- REMOVE UNUSED COLUMNS FROM TABLE --

SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, 
			TaxDistrict,
			PropertyAddress, 
			SaleDate