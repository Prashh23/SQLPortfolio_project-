--cleaning data

select * 
from PortfolioProject..NashvilleHousing


---standardize date format
select SaleDate, Convert(Date,SaleDate)
from PortfolioProject..NashvilleHousing

update NashvilleHousing
Set SaleDate= Convert(Date,SaleDate)

Alter table NashvilleHousing
add SaleDateConverted Date;

select SaleDate
from PortfolioProject..NashvilleHousing

update NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)

select SaleDateConverted
from PortfolioProject..NashvilleHousing


---------------Property address


select *
from PortfolioProject..NashvilleHousing
--where propertyAddress is null
order by parcelid

-------------

select a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress, isnull(a.propertyaddress,b.propertyaddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b

on a.parcelid = b.parcelid
and a.[uniqueid] <> b.[uniqueid]
where a.propertyaddress is null

update a
set propertyaddress = isnull(a.propertyaddress,b.propertyaddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b

on a.parcelid = b.parcelid
and a.[uniqueid] <> b.[uniqueid]
where a.propertyaddress is null

----------address into columns----split

select propertyaddress
from PortfolioProject..Nashvillehousing


select 
substring ( propertyaddress, 1, CHARINDEX( ',',propertyaddress)-1) as Address,
substring ( propertyaddress, CHARINDEX( ',',propertyaddress) +1, LEN(PropertyAddress)) as Address
from PortfolioProject..Nashvillehousing



Alter table NashvilleHousing
add propertysplitaddress Nvarchar(255);


update NashvilleHousing
Set propertysplitaddress= substring ( propertyaddress, 1, CHARINDEX( ',',propertyaddress)-1)


Alter table NashvilleHousing
add propertysplitcity Nvarchar(255);


update NashvilleHousing
Set propertysplitcity= substring ( propertyaddress, CHARINDEX( ',',propertyaddress) +1, LEN(PropertyAddress))


select *
from PortfolioProject..Nashvillehousing



------------------------split by parsing -----

select owneraddress
from PortfolioProject..Nashvillehousing


select
PARSENAME(replace(owneraddress, ',','.'), 3) as ,
PARSENAME(replace(owneraddress, ',','.'), 2),
PARSENAME(replace(owneraddress, ',','.'), 1)
from PortfolioProject..Nashvillehousing



Alter table NashvilleHousing
add  ownersplitaddress Nvarchar(255);


update NashvilleHousing
Set ownersplitaddress= PARSENAME(replace(owneraddress, ',','.'), 3)



Alter table NashvilleHousing
add  ownersplitcity Nvarchar(255);

update NashvilleHousing
Set ownersplitcity= PARSENAME(replace(owneraddress, ',','.'), 2)

Alter table NashvilleHousing
add  ownersplitstate Nvarchar(255);

update NashvilleHousing
Set ownersplitstate= PARSENAME(replace(owneraddress, ',','.'), 1)


select *
from PortfolioProject..Nashvillehousing



--------------

select Distinct(Soldasvacant), count(soldasvacant)
from PortfolioProject..Nashvillehousing
group by soldasvacant
order by 2

--------------

select soldasvacant,
case
when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
Else Soldasvacant
end
from PortfolioProject..Nashvillehousing


update nashvillehousing
set soldasvacant = case
when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
Else Soldasvacant
end


--------------duplicates removal----
----using CTE and window functions






with RownumCTE as(

select *,
ROW_NUMBER() over (
partition by parcelid, propertyaddress, saleprice, saledate, legalreference
order by
uniqueid)
row_num

from PortfolioProject..Nashvillehousing
---order by parcelid
)

select *
from RownumCTE
where row_num>1
order by propertyaddress


with RownumCTE as(

select *,
ROW_NUMBER() over (
partition by parcelid, propertyaddress, saleprice, saledate, legalreference
order by
uniqueid)
row_num

from PortfolioProject..Nashvillehousing
---order by parcelid
)

delete
from RownumCTE
where row_num>1
--order by propertyaddress
