-- CREATE OR REPLACE PROCEDURE pkg_investor.validate_remittance (
--     investor_id        IN NUMBER,
--     reporting_month    IN DATE,
--     v_valid            OUT BOOLEAN
-- ) IS
-- BEGIN
--     -- Simulating validation logic
--     v_valid := TRUE;
-- END validate_remittance;


CREATE OR REPLACE PROCEDURE pkg_investor.validate_remittance (
    investor_id        IN NUMBER,
    reporting_month    IN DATE,
    v_valid            OUT BOOLEAN
) IS
    v_investor_count   NUMBER;                    -- Variable to hold the count of investors
    v_total_remittance NUMBER;                     -- Variable to hold total remittance for the month
    v_expected_remittance NUMBER;                  -- Variable to hold expected remittance
    v_shortfall        NUMBER;                     -- Variable to hold shortfall amount
    v_investor_status  VARCHAR2(20);               -- Variable to hold investor status
    v_remittance_threshold NUMBER := 10000;       -- Example threshold for validation
BEGIN
    -- Check if the investor exists
    SELECT COUNT(*) INTO v_investor_count
    FROM investors
    WHERE investor_id = investor_id;

    IF v_investor_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Investor does not exist');
    END IF;

    -- Get the total remittance for the investor for the reporting month
    SELECT NVL(SUM(remittance_amount), 0) INTO v_total_remittance
    FROM remittances
    WHERE investor_id = investor_id
      AND EXTRACT(YEAR FROM remittance_date) = EXTRACT(YEAR FROM reporting_month)
      AND EXTRACT(MONTH FROM remittance_date) = EXTRACT(MONTH FROM reporting_month);

    -- Get the expected remittance for the investor
    SELECT expected_remittance INTO v_expected_remittance
    FROM investor_expectations
    WHERE investor_id = investor_id
      AND reporting_month = reporting_month;

    -- Calculate shortfall
    v_shortfall := v_expected_remittance - v_total_remittance;

    -- Validate remittance based on shortfall and threshold
    IF v_shortfall > v_remittance_threshold THEN
        v_valid := FALSE;
        v_investor_status := 'UNDER_REMITTANCE';
        DBMS_OUTPUT.PUT_LINE('Validation failed: Shortfall of ' || v_shortfall || ' exceeds threshold for investor ' || investor_id);
    ELSE
        v_valid := TRUE;
        v_investor_status := 'VALID';
        DBMS_OUTPUT.PUT_LINE('Validation successful: Total remittance of ' || v_total_remittance || ' meets expectations for investor ' || investor_id);
    END IF;

    -- Log the validation result
    INSERT INTO remittance_validation_logs (investor_id, reporting_month, total_remittance, expected_remittance, shortfall, validation_status, log_date)
    VALUES (investor_id, reporting_month, v_total_remittance, v_expected_remittance, v_shortfall, v_investor_status, SYSDATE);

END validate_remittance;
