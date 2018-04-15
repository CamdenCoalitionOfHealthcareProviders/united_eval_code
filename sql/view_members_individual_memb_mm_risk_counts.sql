-- View: Member and risk score counts by individual member, Camden residency and Medicaid product line

CREATE OR REPLACE VIEW view_member_indivudal_mm_risk_counts AS
	SELECT memb_id, year_eval, camden_cchp, product_bin, COUNT(memb_id) as member_month_count, ROUND(SUM(risk_score_update), 2) as risk_score_sum
	FROM members
	WHERE product_desc != 'MEDICAID - NON-AFDC'
	GROUP BY memb_id, year_eval, camden_cchp, product_bin;

COMMENT ON VIEW	view_claim_cost_year_medicaid_line IS 'Member count by individual member, Camden residency and Medicaid product line';
