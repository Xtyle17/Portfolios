 -- change string to date 
 UPDATE test.nashville
SET saledate = STR_TO_DATE(saledate, '%M %e, %Y')
 
 -- change null where the address is '' or blank
UPDATE test.nashville SET PropertyAddress = NULL WHERE PropertyAddress = '';

 -- Change null values in property address
 -- THIS IS FOR CHECKING
 SELECT nash1.ParcelID,nash1.PropertyAddress,nash2.ParcelID,nash2.PropertyAddress,IFNULL(nash1.PropertyAddress,nash2.PropertyAddress)
 FROM test.nashville AS nash1
 JOIN test.nashville as nash2
 ON nash1.ParcelID = nash2.ParcelID AND nash1.UniqueID <> nash2.UniqueID
 
-- THIS IS WHERE TO UPDATE
UPDATE test.nashville as nash1
JOIN test.nashville as nash2
ON nash1.ParcelID = nash2.ParcelID AND nash1.UniqueID <> nash2.UniqueID
SET nash1.PropertyAddress = IFNULL(nash1.PropertyAddress,nash2.PropertyAddress)

-- seperating address comma and adding new column
-- this is for property address
SELECT
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1) as address, -- before comma
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)+1, length(PropertyAddress)) as addressssss -- after cooma
FROM test.nashville

ALTER TABLE test.nashville
ADD PropertySplit nvarchar(255)

UPDATE test.nashville
SET PropertySplit = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress)-1)

ALTER TABLE test.nashville
ADD PropertySplitCity nvarchar(255)

UPDATE test.nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress)+1, length(PropertyAddress))

SELECT * FROM test.nashville

-- this is for owner address
SELECT
    SUBSTRING(OwnerAddress, 1, LOCATE(',', OwnerAddress) - 1) AS address_part1, -- Before first comma
    SUBSTRING(
        SUBSTRING(
            OwnerAddress,
            LOCATE(',', OwnerAddress) + 1
        ),
        1,
        LOCATE(',', SUBSTRING(OwnerAddress, LOCATE(',', OwnerAddress) + 1)) - 1
    ) AS address_part2, -- Between first and second comma
    SUBSTRING(
        OwnerAddress,
        LOCATE(',', OwnerAddress, LOCATE(',', OwnerAddress) + 1) + 1
    ) AS address_part3 -- After second comma
FROM
    test.nashville


ALTER TABLE test.nashville
ADD OwnerSplitAddress nvarchar(255)

UPDATE test.nashville
SET OwnerSplitAddress = SUBSTRING(OwnerAddress, 1, LOCATE(',', OwnerAddress) - 1)

ALTER TABLE test.nashville
ADD OwnerSplitCity nvarchar(255)

UPDATE test.nashville
SET OwnerSplitCity = SUBSTRING(
        SUBSTRING(
            OwnerAddress,
            LOCATE(',', OwnerAddress) + 1
        ),
        1,
        LOCATE(',', SUBSTRING(OwnerAddress, LOCATE(',', OwnerAddress) + 1)) - 1
    )

ALTER TABLE test.nashville
ADD OwnerSplitState nvarchar(255)

UPDATE test.nashville
SET OwnerSplitState =  SUBSTRING(
        OwnerAddress,
        LOCATE(',', OwnerAddress, LOCATE(',', OwnerAddress) + 1) + 1
    )

SELECT * FROM test.nashville



-- change yes and no to y and n in soldasvacant

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM test.nashville
Group BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'N' THEN 'No' 
	ELSE SoldAsVacant
    END as changed_value
FROM test.nashville

UPDATE test.nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'No' 
	ELSE SoldAsVacant
    END 
    
    
-- REMOVE DUPLICATES

WITH ROWNUM AS (SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,SaleDate,SalePrice,PropertyAddress,LegalReference 
		ORDER BY UniqueID
	) AS rownum
 FROM test.nashville
 -- ORDER BY ParcelID
 )
 
 SELECT * FROM ROWNUM
 WHERE rownum > 1



-- deleting unused columns

SELECT * FROM test.nashville

ALTER TABLE test.nashville
DROP COLUMN OwnerAddress, DROP COLUMN TaxDistrict,  DROP COLUMN PropertyAddress;
