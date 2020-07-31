/**
 * Test Class for P2P WIBS DERPS File Parser
 */
@isTest
private class P2PWIBSDERPSParserTest {
	
    static String fileData = 
'0                 01WBC       WESTPAC BANKING CORP      999123            230817032-002123465                                                                   \r\n' +
'2032-797999999   6130000003212WOODS ANTHONY                   SCM002438527      637-000163344938COMPANYX        05184894COMPANYX INSURANCE        050203        \r\n' +
'7999-999            000000000000000000000000000000                        000000                                                                                ';
    private static testmethod void testDERPSHeader() {
        P2PWIBSDERPSParser parser = P2PWIBSDERPSParser.getInstance(fileData);
        List<String> records = parser.getRecords();
        P2PWIBSParserBase.WIBSRecord record = parser.parseHeader(records[0]);
        List<String> tokens = record.getTokens();
        System.debug(tokens);
        System.assert(tokens.get(0) == '0', 'Invalid Data at 0');
        System.assert(tokens.get(1).trim() == '', 'Invalid Data at 1');
        System.assert(tokens.get(2) == '01', 'Invalid Data at 2');
        System.assert(tokens.get(3) == 'WBC', 'Invalid Data at 3');
        System.assert(tokens.get(4).trim() == '', 'Invalid Data at 4');
        System.assert(tokens.get(5).trim() == 'WESTPAC BANKING CORP', 'Invalid Data at 5');
        System.assert(tokens.get(6) == '999123', 'Invalid Data at 6');
        System.assert(tokens.get(7).trim() == '', 'Invalid Data at 7');
        System.assert(tokens.get(8) == '230817', 'Invalid Data at 8');
        System.assert(tokens.get(9) == '032-002', 'Invalid Data at 9');
        System.assert(tokens.get(10).trim() == '123465', 'Invalid Data at 10');
        System.assert(tokens.get(11).trim() == '', 'Invalid Data at 11 = ['+tokens.get(10)+']');
    }

/* 

2032-797999999   6130000003212WOODS ANTHONY                   SCM002438527      637-000163344938COMPANYX        05184894COMPANYX INSURANCE        050203        
 */
    private static testmethod void testDERPSRecord() {
        P2PWIBSDERPSParser parser = P2PWIBSDERPSParser.getInstance(fileData);
        List<String> records = parser.getRecords();
        P2PWIBSParserBase.WIBSRecord record = parser.parseRecord(records[1]);
        List<String> tokens = record.getTokens();
        System.debug(tokens);
        System.assert(tokens.get(0) == '2', 'Invalid Data at 0');
        System.assert(tokens.get(1) == '032-797', 'Invalid Data at 1');
        System.assert(tokens.get(2).trim() == '999999', 'Invalid Data at 2');
        System.assert(tokens.get(3) == '6', 'Invalid Data at 3');
        System.assert(tokens.get(4) == '13', 'Invalid Data at 4');
        System.assert(tokens.get(5) == '0000003212', 'Invalid Data at 5');
        System.assert(tokens.get(6).trim() == 'WOODS ANTHONY', 'Invalid Data at 6');
        System.assert(tokens.get(7).trim() == 'SCM002438527', 'Invalid Data at 7');
        System.assert(tokens.get(8) == '637-000', 'Invalid Data at 8');
        System.assert(tokens.get(9) == '163344938', 'Invalid Data at 9');
        System.assert(tokens.get(10).trim() == 'COMPANYX', 'Invalid Data at 10 = ['+tokens.get(10)+']');
        System.assert(tokens.get(11) == '05', 'Invalid Data at 11');
        System.assert(tokens.get(12) == '184894', 'Invalid Data at 12');
        System.assert(tokens.get(13).trim() == 'COMPANYX INSURANCE', 'Invalid Data at 13');
        System.assert(tokens.get(14).trim() == '050203', 'Invalid Data at 14');
        System.assert(tokens.get(15).trim() == '', 'Invalid Data at 15');
    }
     
    private static testmethod void testDERPSFooter() {
        P2PWIBSDERPSParser parser = P2PWIBSDERPSParser.getInstance(fileData);
        List<String> records = parser.getRecords();
        P2PWIBSParserBase.WIBSRecord record = parser.parseFooter(records[2]);
        List<String> tokens = record.getTokens();
        System.debug(tokens);
        System.assert(tokens.get(0) == '7', 'Invalid Data at 0');
        System.assert(tokens.get(1) == '999-999', 'Invalid Data at 1');
        System.assert(tokens.get(2).trim() == '', 'Invalid Data at 2');
        System.assert(tokens.get(3) == '0000000000', 'Invalid Data at 3');
        System.assert(tokens.get(4) == '0000000000', 'Invalid Data at 4');
        System.assert(tokens.get(5) == '0000000000', 'Invalid Data at 5');
        System.assert(tokens.get(6).trim() == '', 'Invalid Data at 6');
        System.assert(tokens.get(7).trim() == '000000', 'Invalid Data at 7');
        System.assert(tokens.get(8).trim() == '', 'Invalid Data at 8');
    }
}