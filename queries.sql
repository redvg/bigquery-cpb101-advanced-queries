/*
    1. yields authored commits:
    email, path, date
    UNNEST is used as path and email are nested props of parent object 
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
