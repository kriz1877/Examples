set CUR_YYYY=%date:~10,4%
set CUR_MM=%date:~4,2%
set CUR_DD=%date:~7,2%
set CUR_HH=%time:~0,2%
if %CUR_HH% lss 10 (set CUR_HH=0%time:~1,1%)

set CUR_NN=%time:~3,2%
set CUR_SS=%time:~6,2%
set CUR_MS=%time:~9,2%

set export_account=Account_export.csv
set export_contact=SalesContact_export.csv
set export_task=Note_export.csv
set export_application=Submission_export.csv
set export_job=Job_export.csv
set export_placement=Placement_export.csv
set export_userlist=UserList_export.csv
set export_user=User_export.csv
set export_candidate=Candidate_export.csv

TEMPLATE_CONTACT_BAT
TEMPLATE_COMPANY_BAT
TEMPLATE_SUBMISSION_BAT
TEMPLATE_JOB_BAT
TEMPLATE_PLACEMENT_BAT
TEMPLATE_CANDIDATE_BAT
call dataloader_win\bin\process.bat C:\Initial_Import\dataloader_win\ csvTaskExtractProcess  "dataAccess.name=C:\Initial_Import\dataloader_win\export\%export_task%"
call process.bat C:\Initial_Import\dataloader_win\ csvUserListExtractProcess  "dataAccess.name=C:\Initial_Import\dataloader_win\export\%export_userlist%"
call dataloader_win\bin\process.bat C:\Initial_Import\dataloader_win\ csvUserExtractProcess  "dataAccess.name=C:\Initial_Import\dataloader_win\export\%export_user%"
