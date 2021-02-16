WITH TESTDATA (TestID, Numerator, Denumerator) AS 
(
	SELECT
		*
	FROM (
		VALUES
		(1, 28, 49),			-->  4/7
		(2, -28, -49),			-->  4/7
		(3, 28, -49),			-->  -4/7
		(4, -28, 49),			-->  -4/7

		(5, 22, 6),			-->  11/3
		(6, -22, -6),			-->  11/3
		(7, 22, -6),			-->  -11/3
		(8, -22, 6),			-->  -11/3
		
		(9, 28, 14),			-->  2
		(10, -28, -14),			-->  2
		(11, 28, -14),			-->  -2
		(12, -28, 14),			-->  -2

		(13, 7919, 2687),		-->  7919/2687
		(14, -7, -2),			-->  7/2
		(15, 11, -17),			-->  -11/17
		(16, -19, 9),			-->  -19/9

		(17, 15, -3),			-->  -5
		(18, -20, 4),			-->  -5
		(19, -10, -2),			-->  5
		(20, 5, 1),			-->  5

		(21, 1, 1),			-->  1
		(22, -1, -1),			-->  1
		(23, 1, -1),			-->  -1
		(24, -1, 1),			-->  -1
		(25, -7, -7),			-->  1
		(26, 7, -7),			-->  -1

		(27, 0, 2),			-->  0
		(28, 0, -2),			-->  0
		(29, 0, 1),			-->  0
		(30, 0, -1),			-->  0

		(31, 2, 0),				-->  +Infinity
		(32, -100, 0),			-->  -Infinity
		(33, 0, 0),				-->  NaN

		(34, 10, NULL),			-->  NULL
		(35, -5, NULL),			-->  NULL
		(36, 0, NULL),			-->  NULL
		(37, NULL, 11),			-->  NULL
		(38, NULL, -8),			-->  NULL
		(39, NULL, 0),			-->  NULL
		(40, NULL, NULL)		-->  NULL
	) 
	TESTDATA (TestID, Numerator, Denumerator)
),
SET1(TestID, Numerator, Denumerator,Simplified) AS
(
SELECT
	TestID,
	Numerator,
	Denumerator,
	(CASE
	WHEN Numerator IS NULL THEN 'Undefined'
	WHEN Denumerator IS NULL THEN 'Undefined'
	WHEN Numerator = 0 AND Denumerator = 0 THEN 'NaN'
	WHEN Numerator = 0 THEN '0'
	WHEN Numerator > 0 AND Denumerator = 0 THEN '+Infinity'
	WHEN Numerator < 0 AND Denumerator = 0 THEN '-Infinity'
	END) AS Simplified 
FROM TESTDATA
WHERE Numerator IS NULL OR Denumerator IS NULL
OR Numerator = 0 OR Denumerator = 0
),
SET2_recursive AS(
SELECT
	TestID,
	Numerator,
	Denumerator,
	ABS(Numerator) AS Num,
	ABS(Denumerator) AS Denum,
	1 AS Division,
	1 AS GCD
FROM TESTDATA
WHERE Numerator IS NOT NULL AND Denumerator IS NOT NULL
AND Numerator != 0 AND Denumerator != 0
UNION ALL
SELECT
	TestID,
	Numerator,
	Denumerator,
	Num,
	Denum,
	Division+1 AS Division,
	CASE WHEN  Num % Division = 0 AND Denum % Division = 0 THEN  
	Division END
	AS GCD
FROM SET2_recursive
WHERE Division <= Num/2 OR Division <= Denum/2
),
SET2(TestID, Numerator, Denumerator,Simplified) AS(
SELECT 
	TestID, 
	Numerator, 
	Denumerator,
	CASE
	WHEN ABS(Numerator) > Denumerator AND Numerator % Denumerator = 0 THEN CAST(Numerator/Denumerator as varchar(1000))
	WHEN Numerator % Denumerator=0 AND Numerator/Denumerator = 1 THEN '1'
	WHEN Numerator % Denumerator=0 AND Numerator/Denumerator = -1 THEN '-1'
	WHEN Numerator/Denumerator = Numerator THEN CAST(Numerator as varchar(1000))
	WHEN Numerator < 0 AND Denumerator < 0 THEN cast(cast(ABS(Numerator)/MAX(GCD) as varchar(1000)) + '/' +  cast(ABS(Denumerator)/MAX(GCD) as varchar(1000)) as varchar(1000))
	WHEN Numerator < 0 AND Denumerator > 0 THEN cast('-'+cast(ABS(Numerator)/MAX(GCD) as varchar(1000)) + '/' +  cast(Denumerator/MAX(GCD) as varchar(1000)) as varchar(1000))
	WHEN Numerator > 0 AND Denumerator < 0 THEN cast('-'+cast(Numerator/MAX(GCD) as varchar(1000)) + '/' +  cast(ABS(Denumerator)/MAX(GCD) as varchar(1000)) as varchar(1000))
	WHEN Numerator > 0  AND Denumerator > 0 THEN cast(cast(Numerator/MAX(GCD) as varchar(1000)) + '/' +  cast(Denumerator/MAX(GCD) as varchar(1000)) as varchar(1000))
	END 
	AS Simplified
FROM SET2_recursive
WHERE GCD IS NOT NULL
GROUP BY TestID,Numerator,Denumerator
),
RESULT(TestID, Numerator, Denumerator,Simplified)  AS 
(
SELECT
	TestID, 
	Numerator, 
	Denumerator, 
	Simplified
FROM SET1
UNION
SELECT
	TestID, 
	Numerator, 
	Denumerator, 
	Simplified
FROM SET2
)
SELECT
	TestID, 
	Numerator, 
	Denumerator, 
	Simplified
FROM RESULT
ORDER BY TestID
OPTION (MAXRECURSION 5000)
