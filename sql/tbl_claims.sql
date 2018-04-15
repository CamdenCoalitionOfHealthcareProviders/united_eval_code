-- Create United Claims table

DROP TABLE claims;

CREATE TABLE claims (
	Year integer,
	Month integer,
	DETAIL_SVC_DATE date,
	PRODUCT_DESC varchar,
	COS_STL_1_DESC varchar,
	COS_STL_2_DESC varchar,
	COS_STL_3_DESC varchar,
	COS_STL_4_DESC varchar,
	Days integer,
	Visits integer,
	Units integer,
	Admits integer,
	Procedures integer,
	Quantity numeric,
	memb_id varchar,
	claim_cost numeric,
	month_pad varchar,
	memb_date date,
	year_eval varchar,
	year_eval_mo_count integer,
	product_bin varchar,
	cost_bin varchar
);

-- Import data
COPY claims from 'y:/united_evaluation/united_claims.csv' WITH CSV HEADER DELIMITER as ',';

-- Create index
CREATE INDEX memb_id_c_idx on claims (memb_id);