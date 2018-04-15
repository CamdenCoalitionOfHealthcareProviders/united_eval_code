-- Create United members table

DROP TABLE members;

CREATE TABLE members (
	Year integer,
	Month integer,
	PROV_FULL_NAME varchar,
	PROV_FIRST_NAME varchar,
	PROV_LAST_NAME varchar,
	PROV_ADDRESS_LINE_1 varchar,
	PROV_ADDRESS_LINE_2 varchar,
	PROV_CITY varchar,
	PROV_STATE varchar,
	PROV_ZIP varchar,
	VEND_FULL_NAME varchar,
	IRS_TAX_ID integer,
	GENDER  varchar (1),
	PRODUCT_DESC varchar,
	PLAN_DESC varchar,
	ORIGINAL_EFFECTIVE_DATE date,
	DOB date,
	MEMB_ELIG_STATUS varchar(2),
	IPRO_RISK_SCORE numeric,
	memb_id varchar,
	month_pad varchar,
	memb_date date,
	age_at_memb_date varchar,
	year_eval varchar,
	year_eval_mo_count integer,
	product_bin varchar,
	memb_month integer,
	risk_score numeric,
	risk_diff numeric,
	risk_score_update numeric,
	ZIP_CODE varchar,
	Camden varchar,
	camden_cchp varchar
);

-- Import data
COPY members from 'y:/united_evaluation/united_members.csv' WITH CSV HEADER DELIMITER as ',';

-- Create index
CREATE INDEX memb_id_m_idx on members (memb_id);