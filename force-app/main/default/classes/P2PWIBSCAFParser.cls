/**
 * Cash Applied File (CAF) File Parser
 * After the processing of a Direct Entry file within the Westpac systems, 
 * Westpac will provide the customer with CAF report
 * for CC and DD transactions.  for Direct Debit transaction and Credit / Debit Card transactions 
*/ 

/**
 * Sample CAF File Data
"Date","Receipt Number","Supplier Name","Payment Reference","Payment Amount","Transaction Code","Transaction Description","Card Type","Card Holder Name","Card Number","Customer Reference Number","Source Product"
"14-Sep-2017","1022454876","TNSWPTP","10000001119","120.00","08","Honour with identification","VISA","","","","QuickWeb"
"14-Sep-2017","1022454893","TNSWPTP","10000001129","120.00","08","Honour with identification","VISA","","","","QuickWeb"
"14-Sep-2017","1022455813","TNSWPTP","10000001149","120.00","08","Honour with identification","VISA","","","","QuickWeb"
"14-Sep-2017","1022455819","TNSWPTP","10000001169","120.00","08","Honour with identification","VISA","","","","QuickWeb"
"14-Sep-2017","1022455823","TNSWPTP","10000001179","120.00","08","Honour with identification","VISA","","","","QuickWeb"
"14-Sep-2017","1022455828","TNSWPTP","10000001189","120.00","08","Honour with identification","VISA","","","","QuickWeb"
"14-Sep-2017","1022455829","TNSWPTP","10000001199","120.00","08","Honour with identification","VISA","","","","QuickWeb"
"14-Sep-2017","1022455832","TNSWPTP","10000001209","120.00","08","Honour with identification","VISA","","","","QuickWeb"
"14-Sep-2017","1022470700","TNSWPTP","Test","200.00","08","Honour with identification","MASTERCARD","","","","QuickWeb"
"14-Sep-2017","1022470706","TNSWPTP","Test","200.00","08","Honour with identification","MASTERCARD","","","","QuickWeb"
"14-Sep-2017","1022470711","TNSWPTP","Test","200.00","08","Honour with identification","MASTERCARD","","","","QuickWeb"
"14-Sep-2017","1022471271","TNSWPTP","10000005509","160.00","08","Honour with identification","VISA","","","","QuickWeb"
"14-Sep-2017","1022471279","TNSWPTP","10000005519","160.00","08","Honour with identification","VISA","","","","QuickWeb"
"14-Sep-2017","1022471286","TNSWPTP","10000001219","160.00","08","Honour with identification","VISA","","","","QuickWeb"
"14-Sep-2017","1022471296","TNSWPTP","10000005529","160.00","08","Honour with identification","VISA","","","","QuickWeb"

*/
public with sharing class P2PWIBSCAFParser extends P2PWIBSParserBase  {
    
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
    
    public P2PWIBSCAFParser(String data)  {
    		this.fileData = data;
    		this.records = this.fileData.split(this.linebreak);
    }
    
    public static P2PWIBSCAFParser getInstance(String data)  {
    		return new P2PWIBSCAFParser(data);
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