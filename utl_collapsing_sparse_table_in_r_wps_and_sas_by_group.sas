Collapsing Sparse table in R WPS and SAS by group

github
https://tinyurl.com/yda5c5mk
https://github.com/rogerjdeangelis/utl_collapsing_sparse_table_in_r_wps_and_sas_by_group

  Same results with SAS or WPS and WPS/Proc R and IML/R(IML/R was untested)

  Six Solutions (all create tables)

    1. proc report (out=want_rpt do not need to sort - most flexible?)
    2. data want - update
    3. summary
    4. R1  summary
    5. R2  sapply
    6. SQL

see
https://tinyurl.com/yao65jnx
https://stackoverflow.com/questions/49075098/collapsing-sparse-dataframe-in-r-based-on-group-by

profiles
https://stackoverflow.com/users/6883405/user6883405
https://stackoverflow.com/users/6174377/felipe-alvarenga


INPUT
=====

 SD1.HAVE total obs=10

  NAME     V1     V2     V3     V4     V5

   A      0.1     .      .      .      .
   A       .     0.3     .      .      .
   A       .      .     0.4     .      .
   A       .      .      .     0.7     .
   A       .      .      .      .     0.9
   B      0.2     .      .      .      .
   B       .     0.5     .      .      .
   B       .      .     0.8     .      .
   B       .      .      .     0.1     .
   B       .      .      .      .     0.3

 WANT

 WORK.WANT total obs=2

   NAME     V1     V2     V3     V4     V5

    A      0.1    0.3    0.4    0.7    0.9
    B      0.2    0.5    0.8    0.1    0.3

PROCESS

  1. proc report (out=want_rpt do not need to sort - most flexible?)

    proc report data=sd1.have nowd out=want_rpt;
    cols name v1-v4;
    define name / group;
    run;quit;

  2. data want - update

    * originally by data_null_;
    data want;
       update sd1.have(obs=0) sd1.have;
       by name;
    run;quit;

  3. summary

    proc summary data=sd1.have max;
    class name;
    var v1-v4;
    output out=want(drop=_:) max=;
    run;quit;

  4. R1 (working code)

     want<-have %>% group_by(NAME) %>% summarise_all(funs(na.omit(.)[1]));

  5  R2

     data.frame(NAME=unique(have$NAME), sapply(have[-1], na.omit));

  6. SQL

     proc sql;
       create
          table want as
       select
          name
          %array(vs,values=v1-v5)
         ,%do_over(vs,phrase=max(?) as ?,between=comma)
       from
          sd1.have
       group
          by name
     ;quit;

OUTPUT
=====

 WORK.WANT total obs=2

   NAME     V0     V1     V2     V3     V4

    A      0.1    0.3    0.4    0.7    0.9
    B      0.2    0.5    0.8    0.1    0.3

*                _              _       _
 _ __ ___   __ _| | _____    __| | __ _| |_ __ _
| '_ ` _ \ / _` | |/ / _ \  / _` |/ _` | __/ _` |
| | | | | | (_| |   <  __/ | (_| | (_| | || (_| |
|_| |_| |_|\__,_|_|\_\___|  \__,_|\__,_|\__\__,_|

;

data sd1.have;
  input Name$ V` V2 V3 V4 V5;
cards4;
A 0.1 . . . .
A . 0.3 . . .
A . . 0.4 . .
A . . . 0.7 .
A . . . . 0.9
B 0.2 . . . .
B . 0.5 . . .
B . . 0.8 . .
B . . . 0.1 .
B . . . . 0.3
;;;;
run;quit;

*
 ___  __ _ ___
/ __|/ _` / __|
\__ \ (_| \__ \
|___/\__,_|___/

;

* originally by data_null_;
data want;
   update sd1.have(obs=0) sd1.have;
   by name;
run;quit;

proc sql;
  create
     table want as
  select
     name
     %array(vs,values=v1-v4)
    ,%do_over(vs,phrase=max(?) as ?,between=comma)
  from
     sd1.have
  group
     by name
;quit;

proc summary data=sd1.have max;
class name;
var v1-v4;
output out=want(drop=_:) max=;
run;quit;

proc report data=sd1.have nowd out=want_rpt;
cols name v1-v4;
define name / group;
run;quit;

*
__      ___ __  ___
\ \ /\ / / '_ \/ __|
 \ V  V /| |_) \__ \
  \_/\_/ | .__/|___/
         |_|
;

* originally by data_null_;
data want;
   update sd1.have(obs=0) sd1.have;
   by name;
run;quit;

proc sql;
  create
     table want as
  select
     name
     %array(vs,values=v1-v4)
    ,%do_over(vs,phrase=max(?) as ?,between=comma)
  from
     sd1.have
  group
     by name
;quit;

proc summary data=sd1.have max nway;
class name;
var v1-v4;
output out=want(drop=_:) max=;
run;quit;

proc report data=sd1.have nowd out=want_rpt;
cols name v1-v4;
define name / group;
run;quit;



%utl_submit_wps64('
libname sd1 "d:/sd1";
libname wrk "%sysfunc(pathname(work))";
data wrk.want_update;
   update sd1.have(obs=0) sd1.have;
   by name;
run;quit;
*
 _ __
| '__|
| |
|_|

;
proc sql;
  create
     table wrk.want_sql as
  select
     name
     %array(vs,values=v1-v4)
    ,%do_over(vs,phrase=max(?) as ?,between=comma)
  from
     sd1.have
  group
     by name
;quit;

proc summary data=sd1.have max nway;
class name;
var v1-v4;
output out=wrk.want_sum(drop=_:) max=;
run;quit;

proc report data=sd1.have nowd out=wrk.want_rpt;
cols name v1-v4;
define name / group;
run;quit;
');


