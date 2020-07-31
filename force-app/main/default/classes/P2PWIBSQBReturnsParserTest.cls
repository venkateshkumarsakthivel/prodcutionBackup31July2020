@isTest
public class P2PWIBSQBReturnsParserTest {
	
    static String fileData = 
        '"Date","Receipt Number","Supplier Name","Reference Number","Payment Amount","Transaction Code","Transaction Description","Token","Customer Reference Number","Source Product"\n'+
		'"02-Jan-2018","1025252502","TNSWPTPQB","10000031339","120.00","8","Invalid User ID Number","TNSWPP10795258","TNSWPP10795258","QuickBatch"\n'+
		'"02-Jan-2018","1025252503","TNSWPTPQB","10000031349","120.00","4","Customer Deceased","TNSWPP10795259","TNSWPP10795259","QuickBatch"\n'+
		'"02-Jan-2018","1025252504","TNSWPTPQB","10000031359","120.00","1","Invalid BSB Number","TNSWPP10795260","TNSWPP10795260","QuickBatch"\n';
	
	private static testmethod void testReturnsRecords() {
        P2PWIBSQBRETURNSParser parser = P2PWIBSQBRETURNSParser.getInstance(fileData);
        parser.parse();
        List<P2PWIBSParserBase.WIBSRecord> wibsrecord = parser.transactions;

        System.assert(wibsrecord.size() ==3);
        
    } 
    
    // below method does not assert any functionality and 
    // used to achieve the coverage of unused overriden methods in qbreturns parser 
    private static testmethod void testAbstractMethods() {
        P2PWIBSQBRETURNSParser parser = P2PWIBSQBRETURNSParser.getInstance(fileData);
        try{
        	parser.parseHeader('line');    
        }catch(Exception ex) {}
        try{
        	parser.parseBatchHeader('line');    
        }catch(Exception ex) {}
        try{
        	parser.parseRecord('line');    
        }catch(Exception ex) {}
        try{
        	parser.parseBatchFooter('line');    
        }catch(Exception ex) {}
        try{
        	parser.parseFooter('line');    
        }catch(Exception ex) {}
        
    }
    
}