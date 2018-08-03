/*
    1. yields commits (paths) for given author and date:
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
