/*

SQL cleaning

*/
select * from dbo.NashvilleHousing

------------------------------------------------------
--Standardize date format

select SaleDateConverted from dbo.NashvilleHousing

Alter table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
set SaleDateConverted = convert(Date,SaleDate)

-----------------------------------------------------
--Populate Property Address Data

select Propertyaddress from dbo.NashvilleHousing
where Propertyaddress is null

select * from dbo.NashvilleHousing
--where Propertyaddress is null
order by parcelID

select a.parcelid,a.propertyaddress,b.parcelid,b.propertyaddress,ISNULL(a.propertyaddress,b.propertyaddress) from dbo.NashvilleHousing a
join dbo.NashvilleHousing b
on a.parcelId = b.parcelId
and a.uniqueId <> b.uniqueID
where a.propertyaddress is null

Update a
set propertyaddress =  ISNULL(a.propertyaddress,b.propertyaddress)
from dbo.NashvilleHousing a
join dbo.NashvilleHousing b
on a.parcelId = b.parcelId
and a.uniqueId <> b.uniqueID
where a.propertyaddress is null

--------------------------------------------------------------------------

--Breaking address into Individual cols

select * from dbo.NashvilleHousing
--where Propertyaddress is null
--order by parcelID


select 
substring(propertyaddress,1,charindex(',',propertyaddress)-1) as address,
substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress)) as state
from dbo.NashvilleHousing


alter table dbo.NashvilleHousing
add PropertySplitAddress nvarchar(255)

Update NashvilleHousing
set PropertySplitAddress = substring(propertyaddress,1,charindex(',',propertyaddress)-1)

alter table dbo.NashvilleHousing
add PropertySplitCity nvarchar(255)

Update NashvilleHousing
set PropertySplitCity = substring(propertyaddress,charindex(',',propertyaddress)+1,len(propertyaddress))


--Alternative way

--select Owneraddress from dbo.NashvilleHousing

select 
PARSENAME(Replace(owneraddress,',','.'),3) as address,
PARSENAME(Replace(owneraddress,',','.'),2) as City,
PARSENAME(Replace(owneraddress,',','.'),1) as state

from dbo.NashvilleHousing

--Adding new col to store Owneraddress

alter table dbo.NashvilleHousing
add OwnerSplitAddress nvarchar(255)

Update NashvilleHousing
set OwnerSplitAddress = PARSENAME(Replace(owneraddress,',','.'),3)

--Adding new col  to store Ownercity

alter table dbo.NashvilleHousing
add OwnerSplitCity nvarchar(255)

Update NashvilleHousing
set OwnerSplitCity = PARSENAME(Replace(owneraddress,',','.'),2)

--Adding new col to store Ownerstate

alter table dbo.NashvilleHousing
add OwnerSplitState nvarchar(255)

Update NashvilleHousing
set OwnerSplitState = PARSENAME(Replace(owneraddress,',','.'),1)

--select * from NashvilleHousing

--------------------------------------------------------------------------

--Change Y and N to Yes  and No in "sold as vacant" field

select Soldasvacant,count(SoldAsVacant) from NashvilleHousing
group by Soldasvacant

select Soldasvacant,
	case 
	when soldasvacant ='Y' then 'Yes'
	when soldasvacant ='N' then 'No'
	else soldasvacant
	end 
	from NashvilleHousing

Update NashvilleHousing
set soldasvacant = case when soldasvacant ='Y' then 'Yes'
	when soldasvacant ='N' then 'No'
	else soldasvacant
	end 

---------------------------------------------------------------------

--Remove duplicates (usally create Temp tables for future purpose)


with rownum_cte as(
select *,
ROW_NUMBER() over(
	partition by parcelID,
				propertyaddress,
				saleprice,
				saleDate,
				LegalReference
					order by 
					uniqueID) row_num
from nashvillehousing
)
--delete from rownum_cte
select * from rownum_cte
where row_num>1
--order by propertyaddress

---------------------------------------------------------

--Delete unused columns

select * from nashvillehousing

alter table nashvillehousing
drop column owneraddress,taxdistrict,propertyaddress

alter table nashvillehousing
drop column saledate