@isTest
public class P2PWIBSQBResponseParserTest {
	static String fileData = 
        '1TNSWPTP   201801021231Transport for NSW Quickweb PTP20180102115158                                                                                                                                                                                       \r\n'+
        '3Point to Point Transport CommiTNSWPTPQB CCBatch 0251        q7ROmEQj1101707                                                                                                                                                                              \r\n'+
        '5  00000000TNSWPP10795247   0000012060               Sara Kingsford        10000031259      1025252519                           008 Honour with identification                                                                                           \r\n'+
        '70000020000120600TNSWPTPQB q7ROmEQj1101707                                                                                                                                                                                                                \r\n'+
        '3Point to Point Transport CommiTNSWPTPQB DDBatch 0251        w0aoa8qD1101712                                                                                                                                                                              \r\n'+
        '5  00000000TNSWPP10795261   0000016000               Rebecca Sorell        10000031369      1025252531                           0G  WBC Exception Processing released successfully                                                                       \r\n'+
        '70000020000076000TNSWPTPQB w0aoa8qD1101712                                                                                                                                                                                                                \r\n'+
        '90200000002000000196600TNSWPTP   Transport for NSW Quickweb PTP20180102115158                                                                                                                                                                             ';   
	
    private static testmethod void testResponseHeader() {
        P2PWIBSQBRESPONSEParser parser = P2PWIBSQBRESPONSEParser.getInstance(fileData);
        List<String> records = parser.getRecords();
        P2PWIBSParserBase.WIBSRecord record = parser.parseHeader(records[0]);
        List<String> tokens = record.getTokens();
        System.debug('header: '+tokens);
        System.assert(tokens.get(0) == '1', 'file header row');
        System.assert(tokens.get(1).trim() == 'TNSWPTP', 'community code');
        System.assert(tokens.get(2) == '20180102', 'date');
        System.assert(tokens.get(3) == '1231', 'time');
        System.assert(tokens.get(4).trim() == 'Transport for NSW Quickweb PTP', 'client name');
        System.assert(tokens.get(5).trim() == '20180102115158', 'unique id');
    } 
    private static testmethod void testBatchHeaderCC() {
        P2PWIBSQBRESPONSEParser parser = P2PWIBSQBRESPONSEParser.getInstance(fileData);
        List<String> records = parser.getRecords();
        P2PWIBSParserBase.WIBSRecord record = parser.parseBatchHeader(records[1]);
        List<String> tokens = record.getTokens();
        System.debug('batch header tokens: '+tokens);
		System.assert(tokens.get(0) == '3', 'batch header row');
        System.assert(tokens.get(1).trim() == 'Point to Point Transport Commi', 'company name');
        System.assert(tokens.get(2).trim() == 'TNSWPTPQB', 'company code');
        System.assert(tokens.get(3) == 'CC', 'batch type');
        System.assert(tokens.get(4).trim() == 'Batch 0251', 'description');
        System.assert(tokens.get(5).trim() == 'q7ROmEQj1101707', 'unique id');
    }
    private static testmethod void testBatchHeaderDD() {
        P2PWIBSQBRESPONSEParser parser = P2PWIBSQBRESPONSEParser.getInstance(fileData);
        List<String> records = parser.getRecords();
        P2PWIBSParserBase.WIBSRecord record = parser.parseBatchHeader(records[4]);
        List<String> tokens = record.getTokens();
        System.debug('batch header tokens: '+tokens);
		System.assert(tokens.get(0) == '3', 'batch header row');
        System.assert(tokens.get(1).trim() == 'Point to Point Transport Commi', 'company name');
        System.assert(tokens.get(2).trim() == 'TNSWPTPQB', 'company code');
        System.assert(tokens.get(3) == 'DD', 'batch type');
        System.assert(tokens.get(4).trim() == 'Batch 0251', 'description');
        System.assert(tokens.get(5).trim() == 'w0aoa8qD1101712', 'unique id');
    }
    private static testmethod void testResponseRecordCC() {
        P2PWIBSQBRESPONSEParser parser = P2PWIBSQBRESPONSEParser.getInstance(fileData);
        List<String> records = parser.getRecords();
        P2PWIBSParserBase.WIBSRecord record = parser.parseRecord(records[2]);
        List<String> tokens = record.getTokens();
        System.debug('response tokens: '+tokens);
        System.assert(tokens.get(0) == '5', 'record type for txn');
        System.assert(tokens.get(2) == '00000000', 'bsb.exp zero filled');
        System.assert(tokens.get(3).trim() == 'TNSWPP10795247', 'account number');
        System.assert(tokens.get(4).trim() == '0000012060', 'Amount');
        System.assert(tokens.get(6).trim() == 'Sara Kingsford', 'Customer Name');
        System.assert(tokens.get(7).trim() == '10000031259', 'Txn number');
        System.assert(tokens.get(9).trim() == '1025252519', 'Receipt Number');
        System.assert(tokens.get(11) == '0', 'Summary code');
        System.assert(tokens.get(12).trim() == '08', 'response code');
        System.assert(tokens.get(13).trim() == 'Honour with identification', 'response description');
    }
	
    private static testmethod void testBatchFooterDD() {
        P2PWIBSQBRESPONSEParser parser = P2PWIBSQBRESPONSEParser.getInstance(fileData);
        List<String> records = parser.getRecords();
        P2PWIBSParserBase.WIBSRecord record = parser.parseBatchFooter(records[6]);
        List<String> tokens = record.getTokens();
        System.debug('batch header tokens: '+tokens);
		System.assert(tokens.get(0) == '7', 'footer row');
        System.assert(tokens.get(1).trim() == '000002', 'txn count');
        System.assert(tokens.get(2).trim() == '0000076000', 'txn amount');
        System.assert(tokens.get(3).trim() == 'TNSWPTPQB', 'company code');
        System.assert(tokens.get(4).trim() == 'w0aoa8qD1101712', 'unique id');
    }
    private static testmethod void testResponseFooter() {
        P2PWIBSQBRESPONSEParser parser = P2PWIBSQBRESPONSEParser.getInstance(fileData);
        List<String> records = parser.getRecords();
        P2PWIBSParserBase.WIBSRecord record = parser.parseFooter(records[7]);
        List<String> tokens = record.getTokens();
        System.debug('footer tokens: '+tokens);
        System.assert(tokens.get(0) == '9', 'footer record');
        System.assert(tokens.get(1) == '02', 'batch count');
        System.assert(tokens.get(2).trim() == '00000002', 'transaction count');
        System.assert(tokens.get(3).trim() == '000000196600', 'transaction amount');
        System.assert(tokens.get(4).trim() == 'TNSWPTP', 'comm code');
        System.assert(tokens.get(5).trim() == 'Transport for NSW Quickweb PTP', 'client name');
        System.assert(tokens.get(6).trim() == '20180102115158', 'unique id');

		
    }

    
}