CREATE OR REPLACE PROCEDURE process_investor_report (
    investor_id        IN NUMBER,
    reporting_month    IN DATE,
    total_remittance   OUT NUMBER
) IS
    v_remittance_total NUMBER := 0;
    v_shortfall        NUMBER := 0;
    v_valid            BOOLEAN := FALSE;
BEGIN
    pkg_investor.validate_remittance(investor_id, reporting_month, v_valid);
    IF v_valid THEN
        SELECT SUM(remittance_amount)
        INTO v_remittance_total
        FROM remittance_table
        WHERE investor_id = investor_id AND remittance_status = 'COMPLETED' AND reporting_month = reporting_month;

        IF v_remittance_total < 100000 THEN
            v_shortfall := 100000 - v_remittance_total;
            pkg_financial.record_shortfall(investor_id, reporting_month, v_shortfall);
        END IF;

        UPDATE investor_report
        SET report_status = 'COMPLETED',
            total_remittance = v_remittance_total
        WHERE investor_id = investor_id AND reporting_month = reporting_month;
        COMMIT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('Invalid remittance data for investor ' || investor_id);
    END IF;
END process_investor_report;
