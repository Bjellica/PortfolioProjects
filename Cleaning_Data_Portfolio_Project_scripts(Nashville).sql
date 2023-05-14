/*

Cleaning Data in SQL Queries

*/

Select *
from PortfolioProfect..NashvilleHousing


-- Standardize Date Format

Select SaleDateConverted, Convert(date,Saledate)
from PortfolioProfect..NashvilleHousing

Update PortfolioProfect..NashvilleHousing
SET SaleDate = Convert(date,Saledate)

Alter Table PortfolioProfect..NashvilleHousing
Add SaleDateConverted date;

Update PortfolioProfect..NashvilleHousing
SET SaleDateConverted = Convert(date,Saledate)


-- Populate Property Address Data

Select *
from PortfolioProfect..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) as PropertyAddress
from PortfolioProfect..NashvilleHousing a
JOIN PortfolioProfect..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProfect..NashvilleHousing a
JOIN PortfolioProfect..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from PortfolioProfect..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from PortfolioProfect..NashvilleHousing

Alter Table PortfolioProfect..NashvilleHousing
Add PropertySplitAddress nvarchar(255);

UPDATE PortfolioProfect..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table PortfolioProfect..NashvilleHousing
Add PropertySplitCity nvarchar(255);

UPDATE PortfolioProfect..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
from PortfolioProfect..NashvilleHousing




Select PropertyAddress, OwnerAddress
from PortfolioProfect..NashvilleHousing
where OwnerAddress is null 
--and OwnerAddress <> 'TN'

Select
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
From PortfolioProfect..NashvilleHousing


Alter Table PortfolioProfect..NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

UPDATE PortfolioProfect..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

Alter Table PortfolioProfect..NashvilleHousing
Add OwnerSplitCity nvarchar(255);

UPDATE PortfolioProfect..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

Alter Table PortfolioProfect..NashvilleHousing
Add OwnerSplitState nvarchar(255);

UPDATE PortfolioProfect..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

Select *
from PortfolioProfect..NashvilleHousing

Select OwnerSplitState
from PortfolioProfect..NashvilleHousing
where OwnerSplitState is null

UPDATE PortfolioProfect..NashvilleHousing
SET OwnerSplitState = CASE When OwnerSplitState is null Then 'TN'
		END

/* 
^^^^^Update NULL at OwnerSplit
*/


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProfect..NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
       when SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   END
from PortfolioProfect..NashvilleHousing

UPDATE PortfolioProfect..NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' Then 'Yes'
		when SoldAsVacant = 'N' Then 'No'
		Else SoldAsVacant
		END


-- Remove Duplicates

WITH RowNumCTE as (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
					UniqueID
					) row_num

from PortfolioProfect..NashvilleHousing
--order by ParcelID
)
--Delete
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

Select *
from PortfolioProfect..NashvilleHousing


-- Delete Unused Columns

Select *
from PortfolioProfect..NashvilleHousing

Alter Table PortfolioProfect..NashvilleHousing
DROP Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
