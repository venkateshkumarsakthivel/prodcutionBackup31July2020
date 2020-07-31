/**
 * Sample QBReturnsCashAppliedFile File Data

"Date","Receipt Number","Supplier Name","Reference Number","Payment Amount","Transaction Code","Transaction Description","Token","Customer Reference Number","Source Product"
"21-Dec-2017","1024765517","TNSWPTPQB","409438","120.00","8","Invalid User ID Number","TNSWPP10795258","TNSWPP10795258","QuickBatch"
"21-Dec-2017","1024765518","TNSWPTPQB","409439","120.00","4","Customer Deceased","TNSWPP10795259","TNSWPP10795259","QuickBatch"
"21-Dec-2017","1024765519","TNSWPTPQB","409440","120.00","1","Invalid BSB Number","TNSWPP10795260","TNSWPP10795260","QuickBatch"


*/
public with sharing class P2PWIBSQBRETURNSParser extends P2PWIBSParserBase  {
    
    protected override Pattern getHeaderPattern(){ return Pattern.compile(null); }
    protected override Pattern getFooterPattern(){ return Pattern.compile(null); }
    protected override Pattern getRecordPattern(){ return Pattern.compile(null); }
    protected override Pattern getBatchHeaderPattern(){return Pattern.compile(null);}
    protected override Pattern getBatchFooterPattern(){return Pattern.compile(null);}
	
	private List<String> clean(List<String> tokens)  {
        List<String> parts = new List<String>();
        for(String token : tokens)  {
        		token = token.trim().removeStartIgnoreCase('"');
        		token = token.trim().removeEndIgnoreCase('"');
        		parts.add(token);
        }
        
        return parts;
	}
	

    private String delimiter { get; set; } { this.delimiter = ','; }
    private String linebreak { get; set; } { this.linebreak = '\n'; }
    
    public WIBSRecord header { get; set; }
    public List<WIBSRecord> transactions { get; set; } { this.transactions = new List<WIBSRecord>(); }
    
    public P2PWIBSQBRETURNSParser(String data)  {
        this.fileData = data;
        this.records = this.fileData.split(this.linebreak);
    }
    
    public static P2PWIBSQBRETURNSParser getInstance(String data)  {
        return new P2PWIBSQBRETURNSParser(data);
    }
    
    public void parse()  {
        if(!this.records.isEmpty())  {
            String hrecord = this.records.remove(0);
            this.header = new WIBSRecord(hrecord, this.clean(hrecord.split(this.delimiter)));
            
            for(String trecord : this.records)  {
                this.transactions.add(new WIBSRecord(trecord, this.clean(trecord.split(this.delimiter))));
            }
            
        }
    }
    
}