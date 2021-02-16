-- https://en.wikipedia.org/wiki/Perfect_number
WITH Numbers (Number) AS
(
	SELECT
		*
	FROM (
		VALUES
		(NULL),
		(1),
		(2),
		(3),
		(4),
		(5),
		(6),
		(7),
		(8),
		(9),
		(10),
		(20),
		(28),
		(30),
		(40),
		(50),
		(100),
		(496),
		(500),
		(1000),
		(8128),
		(10000)
	) Numbers (Number)
),
PerfectNumberCandidates AS
(
	SELECT 
		Number
		, 1 AS IndexNumber
		, 1 as deneme
		, 0 AS DivisorSum
		, CAST('' AS VARCHAR(1000)) AS Summation
	FROM Numbers

	UNION ALL

	SELECT 
		Number,
		IndexNumber+1 AS IndexNumber,
		IndexNumber as deneme,
		CASE WHEN Number % IndexNumber = 0 THEN DivisorSum + IndexNumber 
		ELSE DivisorSum + 0 END AS DivisorSum,
		CAST(Summation +
		(CASE 
		WHEN Number / 2 = IndexNumber THEN CAST(IndexNumber AS VARCHAR(1000)) + ' '
		WHEN Number % IndexNumber = 0 THEN CAST(IndexNumber AS VARCHAR(1000)) + '+'		
		ELSE '' 
		END)
		AS VARCHAR(1000)) 
	FROM PerfectNumberCandidates
	WHERE IndexNumber <= Number/2
),
PerfectNumbers AS
(
	SELECT
		Number,		
		Summation + '= ' + CAST(Number AS VARCHAR(1000)) AS Summation
	FROM PerfectNumberCandidates
	WHERE DivisorSum = Number
)
SELECT
	*
FROM PerfectNumbers
ORDER BY Number
OPTION (MAXRECURSION 10000)
