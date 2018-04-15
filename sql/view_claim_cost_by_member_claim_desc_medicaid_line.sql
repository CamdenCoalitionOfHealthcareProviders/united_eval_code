-- View:  Claim cost by individual member, claim description and Medicaid product line

CREATE OR REPLACE VIEW view_claim_cost_by_member_claim_desc_medicaid_line AS
	SELECT memb_id, year_eval, product_bin, COS_STL_1_DESC, COS_STL_2_DESC, COS_STL_3_DESC, COS_STL_4_DESC, SUM(claim_cost) as claim_cost
	FROM claims
	WHERE product_desc != 'MEDICAID - NON-AFDC'
	GROUP BY memb_id, year_eval, product_bin, COS_STL_1_DESC, COS_STL_2_DESC, COS_STL_3_DESC, COS_STL_4_DESC;

COMMENT ON VIEW	view_claim_cost_year_medicaid_line IS 'Claim cost by individual member, claim description, and Medicaid product line';
