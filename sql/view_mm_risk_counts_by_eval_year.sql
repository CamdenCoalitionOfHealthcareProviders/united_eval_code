-- View: Aggregate Member Month Count and Risk Score Count by Evaluation Year, Camden residency, and Medicaid product line

CREATE OR REPLACE VIEW view_mm_risk_counts_by_eval_year AS
	SELECT year_eval, camden_cchp, product_bin, COUNT(memb_id) as member_month_count, ROUND(SUM(risk_score_update), 2) as risk_score_sum
	FROM members
	WHERE product_desc != 'MEDICAID - NON-AFDC'
	GROUP BY year_eval, camden_cchp, product_bin;

COMMENT ON VIEW	view_mm_risk_counts_by_eval_year IS 'Member Month Count and Risk Score Count by Evaluation Year, Camden residency, and Medicaid product line';
