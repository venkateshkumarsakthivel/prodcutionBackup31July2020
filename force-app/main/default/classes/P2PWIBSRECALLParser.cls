/**
 * RECALL BPay Transactions (CAF) File Parser
 * After the processing of BPay transaction by customer / user the Westpac system creates RECALL file for all 
 * for BPay returned transactions.  for such this parser will collect all required information and pass it to further processing
 * to reject all such transactions to Payment Rejected ( Returned ) negation.
*/ 

/**
 * Sample RECALL File Data
001111NSW TRANSPORT PTP           20320011704970000022092017                                                                                                                                            
190100000019998               B00000050000IB          2   0000000000CBA2209201701412681799310000                                                                                                        
197100000019894               B00000020000IB          2   0000000000CBA2209201701414373669310000                                                                                                        
186100000019795               B00001000000IB          2   0000000000CBA2209201703537868019310000                                                                                                        
9000000003000000000000000001070000000000000000000000000000000000000000000000000000000000000000000000000000000                                                                                           
*/

public with sharing class P2PWIBSRECALLParser extends P2PWIBSParserBase  {
	
    private static final Pattern RECALL_HEADER_PATTERN = Pattern.compile('(.{1,1})(.{5,5})(.{28,28})(.{1,1})(.{6,6})(.{6,6})(.{5,5})(.{8,8})(.{140,140})(.*)'); /** last is optional filler upto 200 characters */
    private static final Pattern RECALL_RECORD_PATTERN = Pattern.compile('(.{1,1})(.{29,29})(.{1,1})(.{11,11})(.{2,2})(.{8,8})(.{16,16})(.{21,21})(.{4,4})(.{3,3})(.{16,16})(.{2,2})(.{12,12})(.{6,6})(.{20,20})(.{4,4})(.{12,12})(.{12,12})(.{20,20})(.*)');
    private static final Pattern RECALL_FOOTER_PATTERN = Pattern.compile('(.{1,1})(.{9,9})(.{9,9})(.{15,15})(.{15,15})(.{15,15})(.{15,15})(.{15,15})(.{15,15})(.{91,91})(.*)');
    
    private P2PWIBSRECALLParser(String data){
        super(data);
    }
    
    protected override Pattern getHeaderPattern(){return RECALL_HEADER_PATTERN;}
    protected override Pattern getFooterPattern(){return RECALL_FOOTER_PATTERN;}
    protected override Pattern getRecordPattern(){return RECALL_RECORD_PATTERN;}
    protected override Pattern getBatchHeaderPattern(){return Pattern.compile(null);}
    protected override Pattern getBatchFooterPattern(){return Pattern.compile(null);}
        
    public static P2PWIBSRECALLParser getInstance(String data){
        return new P2PWIBSRECALLParser(data);
    }
}