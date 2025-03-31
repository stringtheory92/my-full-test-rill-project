-- Model SQL
-- Reference documentation: https://docs.rilldata.com/reference/project-files/models
-- @materialize: true

with commit_file_stats as (
  select 
  a.*,
  b.filename,
  b.added_lines,
  b.deleted_lines,
  regexp_extract(b.new_path, '(.*)', 1) as directory_path
  from 
  commits__ a
  inner join
  modified_files__ b
  on a.commit_hash = b.commit_hash
)
select 
author_date,
author_name,
directory_path,
filename,
string_agg(distinct commit_msg, ', ') as commit_msg,
count(distinct commit_hash) as num_commits,
sum(added_lines) - sum(deleted_lines) as net_line_changes,
sum(added_lines) + sum(deleted_lines) as total_line_changes,
sum(added_lines) as added_lines,
sum(deleted_lines) as deleted_lines,
from 
commit_file_stats
where directory_path is not null
group by all
order by author_date desc