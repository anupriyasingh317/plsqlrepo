-- CREATE OR REPLACE PROCEDURE pkg_financial.record_shortfall (
--     investor_id        IN NUMBER,
--     reporting_month    IN DATE,
--     shortfall          IN NUMBER
-- ) IS
-- BEGIN
--     -- Simulating recording the shortfall logic
--     DBMS_OUTPUT.PUT_LINE('Recording shortfall for investor ' || investor_id || ' of amount ' || shortfall);
-- END record_shortfall;



-- Updated record_shortfall procedure with SQL patterns
CREATE OR REPLACE PROCEDURE pkg_financial.record_shortfall (
    investor_id        IN NUMBER,
    reporting_month    IN DATE,
    shortfall          IN NUMBER
) IS
    -- Constants for calculations
    interest_rate      CONSTANT NUMBER := 0.05;  -- 5% interest rate
    penalty_factor     CONSTANT NUMBER := 1.1;    -- 10% penalty on the shortfall
    adjusted_shortfall NUMBER;                    -- Variable to hold the adjusted shortfall
    v_investor_count   NUMBER;                    -- Variable to hold the count of investors
    CURSOR c_investors IS
        SELECT investor_id 
        FROM investors 
        WHERE investor_id = investor_id;

BEGIN
    -- Validate inputs
    pkg_financial.validate_inputs(investor_id, reporting_month, shortfall);

    -- Check if the investor exists
    SELECT COUNT(*) INTO v_investor_count
    FROM investors
    WHERE investor_id = investor_id;

    IF v_investor_count = 0 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Investor does not exist');
    END IF;

    -- Calculate the adjusted shortfall based on interest and penalty
    adjusted_shortfall := shortfall * (1 + interest_rate) * penalty_factor;

    -- Log the shortfall
    pkg_financial.log_shortfall(investor_id, reporting_month, shortfall, adjusted_shortfall);

    -- Output the result
    DBMS_OUTPUT.PUT_LINE('Recorded shortfall for investor ' || investor_id || 
                         ' of original amount ' || shortfall || 
                         ', adjusted shortfall is ' || adjusted_shortfall ||
                         ' for the reporting month ' || TO_CHAR(reporting_month, 'YYYY-MM'));

    -- Nested SELECT example: Get the total shortfall for the investor in the current month
    DECLARE
        v_total_shortfall NUMBER;
    BEGIN
        SELECT SUM(original_shortfall) INTO v_total_shortfall
        FROM shortfall_logs
        WHERE investor_id = investor_id
          AND EXTRACT(YEAR FROM reporting_month) = EXTRACT(YEAR FROM SYSDATE)
          AND EXTRACT(MONTH FROM reporting_month) = EXTRACT(MONTH FROM SYSDATE);

        DBMS_OUTPUT.PUT_LINE('Total shortfall for investor ' || investor_id || ' this month: ' || NVL(v_total_shortfall, 0));
    END;
END record_shortfall;

    -- -- Using a cursor to fetch and display all shortfalls for the investor
    -- FOR rec IN c_investors LOOP
    --     DBMS_OUTPUT.PUT_LINE('Investor ID: ' || rec.investor_id);
    -- END LOOP;
