USE DataCleaning;

--------DATA CLEANING -----------

--Standarize Date Format

ALTER TABLE NationalHousing
ADD Sale_Date DATE;

UPDATE NationalHousing
SET Sale_Date=CONVERT(date,SaleDate);

ALTER TABLE NationalHousing
DROP COLUMN SaleDate;

--Populate Property Address Data

UPDATE nh2
SET PropertyAddress =ISNULL(nh2.PropertyAddress,nh1.PropertyAddress) 
FROM NationalHousing nh1
JOIN NationalHousing nh2
ON nh1.ParcelID=nh2.ParcelID AND nh1.UniqueID <> nh2.UniqueId
WHERE nh2.PropertyAddress IS NULL

SELECT nh1.parcelId,nh1.PropertyAddress,nh2.ParcelId,nh2.PropertyAddress,ISNULL(nh2.PropertyAddress,nh1.PropertyAddress) as Property_Address
FROM NationalHousing nh1
JOIN NationalHousing nh2
ON nh1.ParcelID=nh2.ParcelID AND nh1.UniqueID <> nh2.UniqueId
WHERE nh2.PropertyAddress IS NULL


--Breaking address into city,address,state
SELECT  SUBSTRING(PropertyAddress,1,Charindex(',',PropertyAddress)-1) as address,
TRIM(SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))) as city
FROM NationalHousing;

ALTER TABLE NationalHousing
ADD addresss varchar(255)

UPDATE NationalHousing
SET addresss=SUBSTRING(PropertyAddress,1,Charindex(',',PropertyAddress)-1)

ALTER TABLE NationalHousing
ADD city nvarchar(255);

UPDATE NationalHousing
SET city=TRIM(SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)));



--breaking into state,city and address from owner address

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),1) FROM 
NationalHOusing;
SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),2) FROM 
NationalHOusing;
SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3) FROM 
NationalHOusing;

ALTER TABLE NationalHousing
ADD Owner_Address NVARCHAR(255)

UPDATE NationalHousing
SET Owner_Address= PARSENAME(REPLACE(OwnerAddress,',','.'),3) FROM 
NationalHOusing;

ALTER TABLE NationalHousing
ADD Owner_city NVARCHAR(255)

UPDATE NationalHousing
SET Owner_city= PARSENAME(REPLACE(OwnerAddress,',','.'),2) FROM 
NationalHOusing;

ALTER TABLE NationalHousing
ADD Owner_state NVARCHAR(255)

UPDATE NationalHousing
SET Owner_state= PARSENAME(REPLACE(OwnerAddress,',','.'),1) FROM 
NationalHOusing;



--Change Yes to Y and No to N in soldasvacant column
SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant='Yes' THEN 'Y'
	WHEN SoldAsVacant='No' THEN 'N'
	ELSE SoldAsVacant
END AS Sold_As_Vacant
FROM NationalHousing;

ALTER TABLE NationalHousing
ADD Sold_As_Vacant NVARCHAR(255);

UPDATE NationalHousing
SET Sold_As_Vacant=CASE
	WHEN SoldAsVacant='Yes' THEN 'Y'
	WHEN SoldAsVacant='No' THEN 'N'
	ELSE SoldAsVacant
	END
	FROM NationalHousing;

SELECT UniqueId,count(*) as cou
FROM NationalHousing
GROUP BY UniqueId 
HAVING count(*)>1;


--Remove duplicate values
with cte as
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY parcelid,landuse,propertyaddress,saleprice,legalreference,ownername,owneraddress,landvalue,sale_date 
order by uniqueid) rownum
FROM NationalHousing
)
DELETE
FROM cte
WHERE rownum>1



--Delete Unused columns
SELECT * 
FROM NationalHousing;

ALTER TABLE NationalHousing
DROP COLUMN PropertyAddress,OwnerAddress,TaxDistrict,SoldAsVacant;
