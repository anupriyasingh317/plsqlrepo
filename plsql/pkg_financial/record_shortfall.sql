CREATE OR REPLACE PROCEDURE pkg_financial.record_shortfall (
    investor_id        IN NUMBER,
    reporting_month    IN DATE,
    shortfall          IN NUMBER
) IS
BEGIN
    -- Simulating recording the shortfall logic
    DBMS_OUTPUT.PUT_LINE('Recording shortfall for investor ' || investor_id || ' of amount ' || shortfall);
END record_shortfall;
