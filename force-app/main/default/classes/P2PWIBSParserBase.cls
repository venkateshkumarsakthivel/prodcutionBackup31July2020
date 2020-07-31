/**
 * Base class for WIBS Response File Parsers
 */
public abstract class P2PWIBSParserBase {
    protected String fileData;
    protected List<String> records;
    public ENUM WIBS_RECORD_TYPE{ HEADER, RECORD, FOOTER, BATCH_HEADER, BATCH_FOOTER }
    public String type { get; set; }
    public Map<String, WIBS_RECORD_TYPE> recordType { get; set; } {
            this.recordType =  new Map<String, WIBS_RECORD_TYPE>{'0' => WIBS_RECORD_TYPE.HEADER, '1' => WIBS_RECORD_TYPE.RECORD, '2' => WIBS_RECORD_TYPE.RECORD, '7' => WIBS_RECORD_TYPE.FOOTER, '9' => WIBS_RECORD_TYPE.FOOTER,
                                                                 '1' => WIBS_RECORD_TYPE.HEADER, '5' => WIBS_RECORD_TYPE.RECORD, '3' => WIBS_RECORD_TYPE.BATCH_HEADER, '7' => WIBS_RECORD_TYPE.BATCH_FOOTER,
                                                                 'RECALL-0' => WIBS_RECORD_TYPE.HEADER, 'RECALL-1' => WIBS_RECORD_TYPE.RECORD, 'RECALL-9' => WIBS_RECORD_TYPE.FOOTER
                                                                };
    }
    
    public P2PWIBSParserBase() {}
    
    public P2PWIBSParserBase(String fileData){
        this.fileData = fileData;
        records = this.fileData.split('\r\n');
        System.debug('recordtype: '+recordType);
    }
    
    public List<String> getRecords() { return records; }
    
    public WIBSRecord parseHeader(String line){
        return new WIBSRecord(line, WIBS_RECORD_TYPE.HEADER, parse(line, WIBS_RECORD_TYPE.HEADER));
    }
    public WIBSRecord parseBatchHeader(String line){
        return new WIBSRecord(line, WIBS_RECORD_TYPE.BATCH_HEADER, parse(line, WIBS_RECORD_TYPE.BATCH_HEADER));
    }
    public WIBSRecord parseRecord(String line){
        return new WIBSRecord(line, WIBS_RECORD_TYPE.RECORD, parse(line, WIBS_RECORD_TYPE.RECORD));
    }
    public WIBSRecord parseBatchFooter(String line){
        return new WIBSRecord(line, WIBS_RECORD_TYPE.BATCH_FOOTER, parse(line, WIBS_RECORD_TYPE.BATCH_FOOTER));
    }
    
    public WIBSRecord parseFooter(String line){
        return new WIBSRecord(line, WIBS_RECORD_TYPE.FOOTER, parse(line, WIBS_RECORD_TYPE.FOOTER));
    }
    
    public WIBSRecord parse(String line, String recordType)  {
            return new WIBSRecord(line, this.recordType.get(recordType), parse(line, this.recordType.get(recordType)));
    }
    
    /**
    * File Format Patterns
    */        
    protected abstract Pattern getHeaderPattern();
    protected abstract Pattern getFooterPattern();
    protected abstract Pattern getRecordPattern();
    protected abstract Pattern getBatchHeaderPattern(); 
    protected abstract Pattern getBatchFooterPattern();
    
    protected List<String> parse(String record, WIBS_RECORD_TYPE wibsRecordType){
        System.debug('wibsRecordType: '+wibsRecordType);
        Integer groupCount = 0;
        Matcher matcher = null;
        List<String> tokens = new List<String>();
        if(wibsRecordType == WIBS_RECORD_TYPE.HEADER) {
            matcher = getHeaderPattern().matcher(record);
        } else if (wibsRecordType == WIBS_RECORD_TYPE.FOOTER){
            matcher = getFooterPattern().matcher(record);
        } else if (wibsRecordType == WIBS_RECORD_TYPE.RECORD){
            matcher = getRecordPattern().matcher(record);
        } else if(wibsRecordType == WIBS_RECORD_TYPE.BATCH_HEADER) {
            matcher = getBatchHeaderPattern().matcher(record);
        } else if(wibsRecordType == WIBS_RECORD_TYPE.BATCH_FOOTER) {
            matcher = getBatchFooterPattern().matcher(record);
        }
        //System.debug('Line = ' + record);
        //System.debug(matcher);
        //System.debug('matcher.matches() : ' + matcher.matches());
        if(matcher.matches()) {
            groupCount = matcher.groupCount();
            for(Integer i=1;i<=groupCount;i++){
                //System.debug('Found Token - ' + i + ': ' + matcher.group(i));
                tokens.add(matcher.group(i));
            }
        }
        return tokens;
    }
    
    /**
     * Data Struct for One Line of WIBS File Record
     */
    public class WIBSRecord{
        private String line;
        private List<String> tokens;
        private WIBS_RECORD_TYPE wibsRecordType;
        
        public String getLine() { return line; }
        public List<String> getTokens(){ return tokens; }
        public WIBS_RECORD_TYPE getWIBSRecordType(){ return wibsRecordType; }
        
        public WIBSRecord(String line, List<String> tokens)  {
                this.line = line;
                this.tokens = tokens;
        }
        
        private WIBSRecord(String line, WIBS_RECORD_TYPE wibsRecordType, List<String> tokens){
            this.line = line;
            this.wibsRecordType = wibsRecordType;
            this.tokens = tokens;
        }
    }
}