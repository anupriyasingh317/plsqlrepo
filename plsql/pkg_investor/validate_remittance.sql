CREATE OR REPLACE PROCEDURE pkg_investor.validate_remittance (
    investor_id        IN NUMBER,
    reporting_month    IN DATE,
    v_valid            OUT BOOLEAN
) IS
BEGIN
    -- Simulating validation logic
    v_valid := TRUE;
END validate_remittance;
