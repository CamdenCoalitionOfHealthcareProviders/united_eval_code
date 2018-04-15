-- View: Claim Cost by evaluation year and Medicaid product line

CREATE OR REPLACE VIEW view_claim_cost_year_medicaid_line AS
	SELECT year_eval, product_bin, SUM(claim_cost) as claim_cost
	FROM claims
	WHERE product_desc != 'MEDICAID - NON-AFDC'
	GROUP BY year_eval, product_bin;

COMMENT ON VIEW	view_claim_cost_year_medicaid_line IS 'Claim Cost by evaluation year and Medicaid product line';
