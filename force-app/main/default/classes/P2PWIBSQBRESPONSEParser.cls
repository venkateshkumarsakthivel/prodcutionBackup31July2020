/**
 * 
Sample response file

1TNSWPTP   201712150945Transport for NSW Quickweb PTP2017111501                                                                                                                                                                                           
3Point to Point Transport CommiTNSWPTPQB CCCredit Card Batch 2017111501_01                                                                                                                                                                                
5  00000000TNSWPP10731815   0000002508               MC Stolen             10000031149      1024566759                           008 Honour with identification                                                                                           
5  00000000TNSWPP10731829   0000113138               Restricted Card       10000031150      1024566760                           162 Restricted card                                                                                                      
5  00000000TNSWPP10731828   0000224758               Insufficient funds    10000031512      1024566761                           151 Not sufficient funds                                                                                                 
5  00000000TNSWPP10731826   0000233758               Refer to issuer       10000031511      1024566762                           101 Refer to card issuer                                                                                                 
5  00000000TNSWPP10731825   0000265758               Honour                10000031517      1024566763                           008 Honour with identification                                                                                           
70000050000839920TNSWPTPQB 2017111501_01                                                                                                                                                                                                                  
3Point to Point Transport CommiTNSWPTPQB DDDirect Debit Batch2017111501_02                                                                                                                                                                                
5  00000000TNSWPP10731821   0000115238               Test                  10000031153      1024566765                           3R  Failed due to BSB settings                                                                                           
5  00000000TNSWPP10731822   0000245758               Success               10000031554      1024566766                           0G  WBC Exception Processing released successfully                                                                       
5  00000000TNSWPP10731814   0000549962               Other                 10000031559      1024566767                           0G  WBC Exception Processing released successfully                                                                       
5  00000000TNSWPP10731809   0000542662               Customer Deceased     10000031560      1024566768                           0G  WBC Exception Processing released successfully                                                                       
5  00000000TNSWPP10731808   0000545562               Account Closed        10000031561      1024566769                           0G  WBC Exception Processing released successfully                                                                       
70000050001999182TNSWPTPQB 2017111501_02                                                                                                                                                                                                                  
90200000010000002839102TNSWPTP   Transport for NSW Quickweb PTP2017111501                                                                                                                                                                                 

 *
 */
public class P2PWIBSQBRESPONSEParser extends P2PWIBSParserBase {

    
	private static final Pattern QBRESPONSE_HEADER_PATTERN = Pattern.compile('(.{1,1})(.{10,10})(.{8,8})(.{4,4})(.{30,30})(.{20,20})(.{177,177})');
   	private static final Pattern QBRESPONSE_BATCH_HEADER_PATTERN = Pattern.compile('(.{1,1})(.{30,30})(.{10,10})(.{2,2})(.{18,18})(.{15,15})(.{1,1})(.{3,3})(.{170,170})');
    private static final Pattern QBRESPONSE_RECORD_PATTERN = Pattern.compile('(.{1,1})(.{2,2})(.{8,8})(.{17,17})(.{10,10})(.{15,15})(.{22,22})(.{15,15})(.{2,2})(.{21,21})(.{16,16})(.{1,1})(.{3,3})(.{60,60})(.{2,2})(.{55,55})');
   	private static final Pattern QBRESPONSE_BATCH_FOOTER_PATTERN = Pattern.compile('(.{1,1})(.{6,6})(.{10,10})(.{10,10})(.{15,15})(.{208,208})');   
    private static final Pattern QBRESPONSE_FOOTER_PATTERN = Pattern.compile('(.{1,1})(.{2,2})(.{8,8})(.{12,12})(.{10,10})(.{30,30})(.{20,20})(.{167,167})');
    
    public P2PWIBSQBRESPONSEParser(String fileData){
        super(fileData);
    }
	
    protected override Pattern getHeaderPattern(){return QBRESPONSE_HEADER_PATTERN;}
   	protected override Pattern getBatchHeaderPattern(){return QBRESPONSE_BATCH_HEADER_PATTERN;}
    protected override Pattern getRecordPattern(){return QBRESPONSE_RECORD_PATTERN;}
    protected override Pattern getBatchFooterPattern(){return QBRESPONSE_BATCH_FOOTER_PATTERN;}    
    protected override Pattern getFooterPattern(){return QBRESPONSE_FOOTER_PATTERN;}
    
    public static P2PWIBSQBRESPONSEParser getInstance(String fileData){
        return new P2PWIBSQBRESPONSEParser(fileData);
    }
}