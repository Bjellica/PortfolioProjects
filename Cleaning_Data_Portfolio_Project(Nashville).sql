/*

Cleaning Data in SQL Queries

*/

Select *
from PortfolioProject..NashvilleHousing


-- Standardize Date Format

Select SaleDateConverted, Convert(date,Saledate)
from PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
SET SaleDate = Convert(date,Saledate)

Alter Table PortfolioProfect..NashvilleHousing
Add SaleDateConverted date;

Update PortfolioProject..NashvilleHousing
SET SaleDateConverted = Convert(date,Saledate)


-- Populate Property Address Data

Select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) as PropertyAddress
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


Update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from PortfolioProject..NashvilleHousing

Alter Table PortfolioProfect..NashvilleHousing
Add PropertySplitAddress nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter Table PortfolioProject..NashvilleHousing
Add PropertySplitCity nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
from PortfolioProject..NashvilleHousing




Select PropertyAddress, OwnerAddress
from PortfolioProject..NashvilleHousing
where OwnerAddress is null 
--and OwnerAddress <> 'TN'

Select
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
From PortfolioProject..NashvilleHousing


Alter Table PortfolioProfect..NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

Alter Table PortfolioProfect..NashvilleHousing
Add OwnerSplitCity nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

Alter Table PortfolioProfect..NashvilleHousing
Add OwnerSplitState nvarchar(255);

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

Select *
from PortfolioProject..NashvilleHousing

Select OwnerSplitState
from PortfolioProject..NashvilleHousing
where OwnerSplitState is null

UPDATE PortfolioProject..NashvilleHousing
SET OwnerSplitState = CASE When OwnerSplitState is null Then 'TN'
		END

/* 
^^^^^Update NULL at OwnerSplit
*/


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' Then 'Yes'
       when SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   END
from PortfolioProject..NashvilleHousing

UPDATE PortfolioProject..NashvilleHousing
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

from PortfolioProject..NashvilleHousing
--order by ParcelID
)
--Delete
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

Select *
from PortfolioProject..NashvilleHousing


-- Delete Unused Columns

Select *
from PortfolioProject..NashvilleHousing

Alter Table PortfolioProfect..NashvilleHousing
DROP Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
