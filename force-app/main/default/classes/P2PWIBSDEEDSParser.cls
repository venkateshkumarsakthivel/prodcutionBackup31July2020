/**
 * Direct Entry Exceptions Disbursements Report (DEEDS) File Parser
 * After the processing of a Direct Entry file within the Westpac systems, 
 * Westpac will provide the customer with 2 reports 
 * Exception report (this produces on entry in to Direct Entry)
 * Disbursement report (this report is produced after the file is processed through release) 
 */ 

/**
 * Sample DEEDS File Data
0ENTR             01WBC       P2P Commission            999123P2P WBC PAY 230817                                        G
1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G
1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G
1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G
1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G
1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G
1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G
1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G
1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G
1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G
1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G
7999-999               1230670         0   1230670                        000010                                        G
0RLSE             01WBC       P2P Commission            999123P2P WBC PAY 230817                                        G
1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G
1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G
1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G
1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G
1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G
1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G
1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G
1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G
1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G
1032-002   123465 13    123067Title of Account all Okey       1000000111        032-002   123465okay remitter   00000000G
*/

public class P2PWIBSDEEDSParser extends P2PWIBSParserBase{
    
    private static final Pattern DEEDS_HEADER_PATTERN = Pattern.compile('(.{1,1})(.{17,17})(.{2,2})(.{3,3})(.{7,7})(.{26,26})(.{6,6})(.{12,12})(.{6,6})(.{40,40})(.{1,1})');
    private static final Pattern DEEDS_RECORD_PATTERN = Pattern.compile('(.{1,1})(.{7,7})(.{9,9})(.{1,1})(.{2,2})(.{10,10})(.{32,32})(.{18,18})(.{16,16})(.{16,16})(.{8,8})(.{1,1})');
    private static final Pattern DEEDS_FOOTER_PATTERN = Pattern.compile('(.{1,1})(.{7,7})(.{12,12})(.{10,10})(.{10,10})(.{10,10})(.{24,24})(.{6,6})(.{40,40})(.{1,1})');
    
    public P2PWIBSDEEDSParser(String fileData){
        super(fileData);
    }
    
    protected override Pattern getHeaderPattern(){return DEEDS_HEADER_PATTERN;}
    protected override Pattern getFooterPattern(){return DEEDS_FOOTER_PATTERN;} 
    protected override Pattern getRecordPattern(){return DEEDS_RECORD_PATTERN;}
    protected override Pattern getBatchHeaderPattern(){return Pattern.compile(null);}
    protected override Pattern getBatchFooterPattern(){return Pattern.compile(null);}
    
    public static P2PWIBSDEEDSParser getInstance(String fileData){
        return new P2PWIBSDEEDSParser(fileData);
    }
}