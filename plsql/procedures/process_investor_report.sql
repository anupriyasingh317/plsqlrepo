-- CREATE OR REPLACE PROCEDURE process_investor_report ( 
--     investor_id        IN NUMBER, 
--     reporting_month    IN DATE, 
--     total_remittance   OUT NUMBER 
-- ) IS 
--     v_remittance_total NUMBER := 0; 
--     v_shortfall        NUMBER := 0; 
--     v_valid            BOOLEAN := FALSE; 
    
--     -- Declare variables for HTTP request 
--     l_http_request  UTL_HTTP.req; 
--     l_http_response UTL_HTTP.resp; 
--     l_response_text VARCHAR2(32767); 
    
--     -- Declare variables for SMTP 
--     l_mailhost VARCHAR2(255) := 'smtp.example.com'; 
--     l_port     NUMBER := 25; 
--     l_sender   VARCHAR2(255) := ' your_email@example.com'; 
--     l_recipient VARCHAR2(255) := ' recipient_email@example.com'; 
--     l_subject  VARCHAR2(255) := 'Service Call Notification'; 
--     l_message  VARCHAR2(32767) := 'The service call was executed successfully.'; 
    
-- BEGIN 
--     pkg_investor.validate_remittance(investor_id, reporting_month, v_valid); 
--     IF v_valid THEN 
--         SELECT SUM(remittance_amount) 
--         INTO v_remittance_total 
--         FROM remittance_table 
--         WHERE investor_id = investor_id AND remittance_status = 'COMPLETED' AND reporting_month = reporting_month; 

--         IF v_remittance_total < 100000 THEN 
--             v_shortfall := 100000 - v_remittance_total; 
--             pkg_financial.record_shortfall(investor_id, reporting_month, v_shortfall); 
--         END IF; 

--         UPDATE investor_report 
--         SET report_status = 'COMPLETED', 
--             total_remittance = v_remittance_total 
--         WHERE investor_id = investor_id AND reporting_month = reporting_month; 
--         COMMIT; 
        
--         -- Make an HTTP request 
--         l_http_request := UTL_HTTP.begin_request('http://example.com/api/service', 'GET'); 
--         l_http_response := UTL_HTTP.get_response(l_http_request); 
--         BEGIN 
--             LOOP 
--                 UTL_HTTP.read_text(l_http_response, l_response_text, 32767); 
--                 DBMS_OUTPUT.put_line(l_response_text); 
--             END LOOP; 
--         EXCEPTION 
--             WHEN UTL_HTTP.end_of_body THEN 
--                 UTL_HTTP.end_response(l_http_response); 
--         END; 
        
--         -- Send an email notification 
--         UTL_SMTP.start_session(l_mailhost, l_port); 
--         UTL_SMTP.mail(l_sender); 
--         UTL_SMTP.rcpt(l_recipient); 
--         UTL_SMTP.open_data; 
--         UTL_SMTP.close_data; 
--         UTL_SMTP.quit; 
        
--     ELSE 
--         DBMS_OUTPUT.PUT_LINE('Invalid remittance data for investor ' || investor_id); 
--     END IF; 
    
-- EXCEPTION 
--     WHEN OTHERS THEN 
--         DBMS_OUTPUT.put_line('Error:  ' || SQLERRM); 
-- END process_investor_report; 
-- /





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



