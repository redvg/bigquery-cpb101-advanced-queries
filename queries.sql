/*
    1. yields paths affected by commit for given author and date:
    email| path | date
    const | different | const
    UNNEST is applied to a column which has repeated records, and flattens it
    so email [path1, path2,...]
    becomes:
    email,path1 email,path2...
    difference = [Struct<>, Struct<>...]
*/

SELECT
  author.email,
  diff.new_path AS path,
  author.date
FROM
  `bigquery-public-data.github_repos.commits`,
  UNNEST(difference) diff
WHERE
  EXTRACT(YEAR
  FROM
    author.date)=2016
LIMIT 10

/*
    2. yields first path affected by commit for given author and date
*/

SELECT
  author.email,
  difference[OFFSET(0)].new_path AS path,
  author.date
FROM
  `bigquery-public-data.github_repos.commits`
WHERE
  EXTRACT(YEAR
  FROM
    author.date)=2016
LIMIT
  10

/*
    3. extract file extensions of all commits by author and date
*/

SELECT
  author.email,
  LOWER(REGEXP_EXTRACT(diff.new_path, r'\.([^\./\(~_ \- #]*)$')) lang,
  diff.new_path AS path,
  author.date
FROM
  `bigquery-public-data.github_repos.commits`,
  UNNEST(difference) diff
WHERE
  EXTRACT(YEAR
  FROM
    author.date)=2016
LIMIT
  10

/*
    4. group by language and list in descending order of the number of commits
    Also filters the languages which consist purely of letters and have a
    length that is fewer than 8 characters
*/

WITH
  commits AS (
  SELECT
    author.email,
    LOWER(REGEXP_EXTRACT(diff.new_path, r'\.([^\./\(~_ \- #]*)$')) lang,
    diff.new_path AS path,
    author.date
  FROM
    `bigquery-public-data.github_repos.commits`,
    UNNEST(difference) diff
  WHERE
    EXTRACT(YEAR
    FROM
      author.date)=2016 )
SELECT
  lang,
  COUNT(path) AS numcommits
FROM
  commits
WHERE
  LENGTH(lang) < 8
  AND lang IS NOT NULL
  AND REGEXP_CONTAINS(lang, '[a-zA-Z]')
GROUP BY
  lang
HAVING
  numcommits > 100
ORDER BY
  numcommits DESC

/*
    5. extracts the day of the week from author.date. Days 2 to 6 are weekdays.
*/

WITH
  commits AS (
  SELECT
    author.email,
    EXTRACT(DAYOFWEEK
    FROM
      author.date) BETWEEN 2
    AND 6 is_weekday,
    LOWER(REGEXP_EXTRACT(diff.new_path, r'\.([^\./\(~_ \- #]*)$')) lang,
    diff.new_path AS path,
    author.date
  FROM
    `bigquery-public-data.github_repos.commits`,
    UNNEST(difference) diff
  WHERE
    EXTRACT(YEAR
    FROM
      author.date)=2016)
SELECT
  lang,
  is_weekday,
  COUNT(path) AS numcommits
FROM
  commits
WHERE
  LENGTH(lang) < 8
  AND lang IS NOT NULL
  AND REGEXP_CONTAINS(lang, '[a-zA-Z]')
GROUP BY
  lang,
  is_weekday
HAVING
  numcommits > 100
ORDER BY
  numcommits DESC
