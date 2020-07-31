/**
 * Direct Entry Returns Processing System (DERPS) File Parser
 * Whenever customers process Direct Entry files, 
 * it is more than likely that a number of transactions 
 * will not be able to be processed. 
 * This transaction must then be reversed or Returned. 
 * Items may be returned for a number of reasons, here are some common ones: 
 * Invalid BSB | Payment stopped | Account closed | Customer deceased | No account or incorrect account 
 * | Refer to customer | no longer valid - has been deleted | Invalid user number | Other
 */ 

/**
 * Sample DERPS File Data
0                 01WBC       WESTPAC BANKING CORP      999123            230817032-002123465                                                                   
2032-797999999   6130000003212WOODS ANTHONY                   10001004699       637-000163344938COMPANYX        05184894COMPANYX INSURANCE        050203        
7999-999            000000000000000000000000000000                        000000                                                                                
*/

/** SPEC
 * Header Record
1-1 REC-TYPE PIC X(1) ‘0’ 
2-18 FILLER PIC X(17) Blank filled 
19-20 REEL-SEQ-NUM  PIC X(2) ‘01’ 
21-23 FIN-INST PIC X(3) ‘WBC’ 
24-30 Filler PIC X(7) Blank 
31-56 FIN-INST-NAME PIC X(26) ‘WESTPAC BANKING CORP.’
57-62 USER-ID PIC X(6) DE User ID of the customer, mapped to the original DE file Header. 
63-74 Filler PIC X(12) Blank 
75-80 RETURN-DATE PIC X(6) DDMMYY. Return date of the file. 
81-87 BSB-Trace PIC X(7) trace BSB 
88-96 acc-num-trace PIC X(9) trace account num  
97-160 filler pic x(64)
*/
public class P2PWIBSDERPSParser extends P2PWIBSParserBase{
    private static final Pattern DERPS_HEADER_PATTERN = Pattern.compile('(.{1,1})(.{17,17})(.{2,2})(.{3,3})(.{7,7})(.{26,26})(.{6,6})(.{12,12})(.{6,6})(.{7,7})(.{9,9})(.{64,64})'); /**bsb,acc-num-filler */
    private static final Pattern DERPS_RECORD_PATTERN = Pattern.compile('(.{1,1})(.{7,7})(.{9,9})(.{1,1})(.{2,2})(.{10,10})(.{32,32})(.{18,18})(.{7,7})(.{9,9})(.{16,16})(.{2,2})(.{6,6})(.{26,26})(.{6,6})(.{8,8})');
    private static final Pattern DERPS_FOOTER_PATTERN = Pattern.compile('(.{1,1})(.{7,7})(.{12,12})(.{10,10})(.{10,10})(.{10,10})(.{24,24})(.{6,6})(.{80,80})');
    
    private P2PWIBSDERPSParser(String fileData){
        super(fileData);
    }
    
    protected override Pattern getHeaderPattern(){return DERPS_HEADER_PATTERN;}
    protected override Pattern getFooterPattern(){return DERPS_FOOTER_PATTERN;}
    protected override Pattern getRecordPattern(){return DERPS_RECORD_PATTERN;}
    protected override Pattern getBatchHeaderPattern(){return Pattern.compile(null);}
    protected override Pattern getBatchFooterPattern(){return Pattern.compile(null);}
        
    public static P2PWIBSDERPSParser getInstance(String fileData){
        return new P2PWIBSDERPSParser(fileData);
    }
}