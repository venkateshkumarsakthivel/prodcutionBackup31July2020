/**
* @name P2PWIBSResponseFileProcessor.cls
* *description this class is responsible to process file data and create list of orders to be updated
*/
public with sharing class P2PWIBSResponseFileProcessor {
    
    public P2PWIBSParserBase parser { get; private set; }
    public List<String> tokens { get; private set; }
    public Boolean success { get; private set; }
    public P2PWIBSParserFacadeBase facade { get; private set; }
    public String name { get; set; }
    
    /* constructor to initialize type of parser, facade and other properties required to process file data. */
    public P2PWIBSResponseFileProcessor(String name, P2PWIBSParserBase parser) {
        this.success = false;
        this.name = name;
        this.parser = parser;
        
        if (this.parser.type.equalsIgnoreCase('DEEDS')) this.facade = new P2PWIBSDEEDSParserFacade();
        if (this.parser.type.equalsIgnoreCase('DERPS')) this.facade = new P2PWIBSDERPSParserFacade();
        if (this.parser.type.equalsIgnoreCase('RECALL')) this.facade = new P2PWIBSRECALLParserFacade();
        if (this.parser.type.equalsIgnoreCase('CAF')) this.facade = new P2PWIBSCAFParserFacade();
        if (this.parser.type.equalsIgnoreCase('QBRESPONSE')) this.facade = new P2PWIBSQBResponseParserFacade();
        if (this.parser.type.equalsIgnoreCase('QBRETURNS')) this.facade = new P2PWIBSQBReturnsParserFacade();
    }
    
    
    /* this method will be called to start execution of file data processing and switch between generalized processor or caf processor */
    public void execute() {
        if (this.parser.type.equalsIgnoreCase('CAF')) {
            this.caf();
        } else if(this.parser.type.equalsIgnoreCase('QBRETURNS')) {
            this.qbReturns();
        } else {
            this.process();    
        } 
    }
    
    /** this method will process generalized data from DEEDS, DERPS and RECALL */
    private void process() {
        try {
            P2PWIBSParserBase.WIBSRecord wibsRecord;
            String headerTransactionOrFooter = '';
            for(String record : this.parser.getRecords())  {
                headerTransactionOrFooter = record.subString(0, 1);
                /** we are not processing T records as of now, these records will appends to all transactions with status indicator R illustrating cause of Rejection. */
                if(headerTransactionOrFooter.equalsIgnoreCase('T')) continue;
                System.debug(LoggingLevel.INFO, 'Invoke parse ' + headerTransactionOrFooter + '   --' + record);
                if(this.parser.type.equalsIgnoreCase('RECALL')){
                    wibsRecord = this.parser.parse(record, 'RECALL-' + headerTransactionOrFooter);
                } else {
                    wibsRecord = this.parser.parse(record, headerTransactionOrFooter);
                }
                
                this.tokens = wibsRecord.getTokens();
                this.facade.execute(this.tokens);
            }
            
            this.success = true;
        } catch(Exception cexception)  {
            System.debug('exception thrown: '+cexception.getMessage());
            System.debug(cexception.getStacktraceString());
        }
        
    }
    
    /** this method will process specialized CAF records. */
    private void caf() {
        try {
            P2PWIBSCAFParser parser = (P2PWIBSCAFParser) this.parser;
            parser.parse();
            for(P2PWIBSParserBase.WIBSRecord trecord : parser.transactions)  {
                this.facade.execute(trecord.getTokens());
            }
            
            this.success = true;
        } catch(Exception cexception)  {}
    }

    private void qbReturns() {
        try {
            P2PWIBSQBRETURNSParser parser = (P2PWIBSQBRETURNSParser) this.parser;
            parser.parse();
            for(P2PWIBSParserBase.WIBSRecord trecord : parser.transactions)  {
                this.facade.execute(trecord.getTokens());
            }
            
            this.success = true;
        } catch(Exception cexception)  {System.debug('exception thrown: '+cexception.getMessage());}
    }

    public void finalize()  {
        List<Database.SaveResult> updates = this.facade.finalize();
        for(Database.SaveResult oupdate : updates)  {
            if(oupdate.isSuccess() && this.success) this.success = true; else this.success = false; 
        }
    }
  
}