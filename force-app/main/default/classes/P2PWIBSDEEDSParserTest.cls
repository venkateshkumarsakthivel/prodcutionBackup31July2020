/**
 * Test class for WIBS DEEDS File Parser
 */
@isTest
private class P2PWIBSDEEDSParserTest {
    static String fileData = 
'0ENTR             01WBC       P2P Commission            999123P2P WBC PAY 230817                                        G\r\n'+
'1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G\r\n'+
'7999-999               1230670         0   1230670                        000010                                        G\r\n'+
'0RLSE             01WBC       P2P Commission            999123P2P WBC PAY 230817                                        G\r\n'+
'1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G\r\n'+
'1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G\r\n'+
'1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G\r\n'+
'1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G\r\n'+
'1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G\r\n'+
'1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G\r\n'+
'1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G\r\n'+
'1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G\r\n'+
'1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G\r\n'+
'1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G\r\n';
    private static testmethod void testDEEDSSHeader() {
        P2PWIBSDEEDSParser parser = P2PWIBSDEEDSParser.getInstance(fileData);
        List<String> records = parser.getRecords();
        P2PWIBSParserBase.WIBSRecord record = parser.parseHeader(records[0]);
        List<String> tokens = record.getTokens();
        System.debug(tokens);
        System.assert(tokens.get(0) == '0', 'Invalid Data at 0');
        System.assert(tokens.get(1).trim() == 'ENTR', 'Invalid Data at 1');
        System.assert(tokens.get(2) == '01', 'Invalid Data at 2');
        System.assert(tokens.get(3) == 'WBC', 'Invalid Data at 3');
        System.assert(tokens.get(4).trim() == '', 'Invalid Data at 4');
        System.assert(tokens.get(5).trim() == 'P2P Commission', 'Invalid Data at 5');
        System.assert(tokens.get(6) == '999123', 'Invalid Data at 6');
        System.assert(tokens.get(7).trim() == 'P2P WBC PAY', 'Invalid Data at 7');
        System.assert(tokens.get(8) == '230817', 'Invalid Data at 8');
        System.assert(tokens.get(9).trim() == '', 'Invalid Data at 9');
        System.assert(tokens.get(10) == 'G', 'Invalid Data at 10');
    } 
    private static testmethod void testDEEDSRecord1() {
        P2PWIBSDEEDSParser parser = P2PWIBSDEEDSParser.getInstance(fileData);
        List<String> records = parser.getRecords();
        P2PWIBSParserBase.WIBSRecord record = parser.parseRecord(records[1]);
        List<String> tokens = record.getTokens();
        System.debug(tokens);
        System.assert(tokens.get(0) == '1', 'Invalid Data at 0');
        System.assert(tokens.get(1) == '032-002', 'Invalid Data at 1');
        System.assert(tokens.get(2).trim() == '123465', 'Invalid Data at 2');
        System.assert(tokens.get(3).trim() == '', 'Invalid Data at 3');
        System.assert(tokens.get(4) == '13', 'Invalid Data at 4');
        System.assert(tokens.get(5).trim() == '123067', 'Invalid Data at 5');
        System.assert(tokens.get(6).trim() == 'Title of Account all Okey', 'Invalid Data at 6');
        System.assert(tokens.get(7).trim() == '1000000111', 'Invalid Data at 7');
        System.assert(tokens.get(8) == '032-002   123465', 'Invalid Data at 8');
        System.assert(tokens.get(9).trim() == 'okay remitter', 'Invalid Data at 10 = ['+tokens.get(10)+']');
        System.assert(tokens.get(10) == '00000000', 'Invalid Data at 11');
        System.assert(tokens.get(11) == 'G', 'Invalid Data at 12');
    }
    private static testmethod void testDEEDSFooter() {
        P2PWIBSDEEDSParser parser = P2PWIBSDEEDSParser.getInstance(fileData);
        List<String> records = parser.getRecords();
        P2PWIBSParserBase.WIBSRecord record = parser.parseFooter(records[2]);
        List<String> tokens = record.getTokens();
        System.debug(tokens);
        System.assert(tokens.get(0) == '7', 'Invalid Data at 0');
        System.assert(tokens.get(1) == '999-999', 'Invalid Data at 1');
        System.assert(tokens.get(2).trim() == '', 'Invalid Data at 2');
        System.assert(tokens.get(3).trim() == '1230670', 'Invalid Data at 3');
        System.assert(tokens.get(4).trim() == '0', 'Invalid Data at 4');
        System.assert(tokens.get(5).trim() == '1230670', 'Invalid Data at 5');
        System.assert(tokens.get(6).trim() == '', 'Invalid Data at 6');
        System.assert(tokens.get(7).trim() == '000010', 'Invalid Data at 7');
        System.assert(tokens.get(8).trim() == '', 'Invalid Data at 8');
        System.assert(tokens.get(9).trim() == 'G', 'Invalid Data at 9');
    }
}