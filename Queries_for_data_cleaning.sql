-- Data Cleaning Using SQL [This Project use data from "Alex The Analyst" portfolio project series]



-- Viewing the data as a whole to get an understanding

Select *
From Portfolio_Project.dbo.NashvilleHousing


-- Standardizing the Date Foramt

Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)

-- Making sure the it updates properly
Alter Table NashvilleHousing
Add StandardizedSaleDate Date;
Update NashvilleHousing
Set StandardizedSaleDate = Convert(date,SaleDate)


-- Populating Property Adress Data using Self Join

Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
From Portfolio_Project.dbo.NashvilleHousing A
JOIN Portfolio_Project.dbo.NashvilleHousing B
	on A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null

Update A
Set PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
From Portfolio_Project.dbo.NashvilleHousing as A
Join Portfolio_Project.dbo.NashvilleHousing as B
	on A.ParcelID = B.ParcelID
	and A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null 


-- To Enrich the Data; Breaking out the Addresses into Useful Columns 

Select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1),
	   SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))
From Portfolio_Project.dbo.NashvilleHousing

Alter table NashvilleHousing
Add Property_Address NVARCHAR(255),
	Property_City NVARCHAR(255);

Update NashvilleHousing
Set Property_Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress) - 1),
	Property_City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))

Select PARSENAME(Replace(OwnerAddress,',','.'),3),
	   PARSENAME(Replace(OwnerAddress,',','.'),2),
	   PARSENAME(Replace(OwnerAddress,',','.'),1)
From Portfolio_Project.dbo.NashvilleHousing

Alter table NashvilleHousing
Add Owner_Address NVARCHAR(255),
	Owner_City NVARCHAR(255),
	Owner_State NVARCHAR(255);

Update NashvilleHousing
Set Owner_Address = PARSENAME(Replace(OwnerAddress,',','.'),3),
	Owner_City = PARSENAME(Replace(OwnerAddress,',','.'),2),
	Owner_State = PARSENAME(Replace(OwnerAddress,',','.'),1);


-- For Data Consistency; Changing Y and N to YES and NO 

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From Portfolio_Project.dbo.NashvilleHousing
Group By SoldAsVacant
Order by 2

Update NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant='Y' Then 'YES'
						When SoldAsVacant= 'N' Then 'NO'
						ELSE SoldAsVacant
						END


-- Removing Duplicate Rows Using CTE and Row Number

With CTE as(
Select *,ROW_NUMBER() Over (Partition by ParcelID, 
							PropertyAddress,
							SalePrice,
							SaleDate,
							LegalReference
							Order by UniqueID) as row_number
From Portfolio_Project.dbo.NashvilleHousing
)

Delete
From CTE
Where row_number > 1


-- Deleting Redundant Columns

Alter table NashvilleHousing
Drop Column PropertyAddress, OwnerAddress, SaleDate


-- Finally Reviewing the Cleaned Data

Select *
From Portfolio_Project.dbo.NashvilleHousing
