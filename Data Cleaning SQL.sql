#Data update

select SaleDate from nashvillehousing 


update nashvillehousing 
set SaleDate = convert(date, SaleDate)

alter table nashvillehousing 
add SaleDateConverted date;

update nashvillehousing 
set SaleDateConverted = convert(date, SaleDate)

#Populate Property Addres data

select * from nashvillehousing
where PropertyAddress is null
order byParcelID 


update nashvillehousing
set PropertyAddress = NULL
where PropertyAddress = ''


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress 
from nashvillehousing a
join nashvillehousing b
	on a.ParcelID =  b.ParcelID 
	and a.UniqueID <> b.UniqueID 
where a.PropertyAddress is null

update portfolioproject.nashvillehousing a
join portfolioproject.nashvillehousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
set a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
where a.PropertyAddress IS NULL


select 
substring(propertyaddress, 1, locate(',', PropertyAddress)-1) as Adress
,substring(propertyaddress,locate(',', PropertyAddress)+1, length (PropertyAddress)) as Adress
from nashvillehousing 

SELECT
  SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(owneraddress, ',', '.'), '.', 3), '.', -1) AS Part1,
  SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(owneraddress, ',', '.'), '.', 2), '.', -1) AS Part2,
  SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(owneraddress, ',', '.'), '.', 1), '.', -1) AS Part3
FROM nashvillehousing;


alter table nashvillehousing 
add OwnerSplitAddress varchar(255);

update nashvillehousing 
set OwnerSplitAddress = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(owneraddress, ',', '.'), '.', 1), '.', -1)

alter table nashvillehousing 
add OwnerSplitCity varchar(255);

update nashvillehousing 
set OwnerSplitCity= SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(owneraddress, ',', '.'), '.', 2), '.', -1)


alter table nashvillehousing 
add OwnerSplitState varchar(255);

update nashvillehousing 
set OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(REPLACE(owneraddress, ',', '.'), '.', 3), '.', -1)


select * from nashvillehousing 

#Change Y and N to YES and NO

select distinct (soldasvacant), count(soldasvacant)
from nashvillehousing n
group by SoldAsVacant 
order by 2


select soldasvacant,
case 	when soldasvacant = 'Y' then 'YES'
		when soldasvacant = 'N' then 'NO'
		else soldasvacant
		end
from nashvillehousing 

update nashvillehousing 
set soldasvacant =case 	when soldasvacant = 'Y' then 'YES'
		when soldasvacant = 'N' then 'NO'
		else soldasvacant
		end		
		
#Remove Duplicates

with RowNumCTE as(
select *,
	row_number() over(
	partition by 	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					order by UniqueID) row_num 
from nashvillehousing)
#order by ParcelID 

delete
from RowNumCTE
where row_num > 1
#order by propertyaddress

##Delete Unused Columns
select * from nashvillehousing

ALTER TABLE nashvillehousing
DROP COLUMN owneraddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;

ALTER TABLE nashvillehousing
DROP COLUMN SaleDate;
