# united_eval_code
Code to create files for United ACO evaluation analysis

## `R` Folder
The R files are used to clean the individual claim and members files into two distinct files: `claims` and `members`.

- `clean_files.R`: Script to clean members, claims, and risk scores for United MCO evaluation. It also:

1. Bind members and claims files into their own tables
2. Rename different identifying variables to for members in members and claims files
3. Set Baseline and Performance Years
4. Add in # of months are in Baseline and Performance Years
5. "Bin" Medicaid Product Lines
6. Update risk scores  

- `clean_files_2_add_spending_caps.R`: Adds evaluation scenarios with no spending caps and with spending caps. Uses the results of `clean_files.R`.
  
## `SQL` Folder

- `tbl_claims.sql`: SQL table for `claims` files from `clean_files.R`
- `tbl_members.sql` SQL table for `members` files from `clean_files.R`
- Various views
