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
