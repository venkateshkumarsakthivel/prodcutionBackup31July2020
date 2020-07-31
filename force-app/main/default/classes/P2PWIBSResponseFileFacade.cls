/**
* @name P2PWIBSResponseFileFacade.cls
* @usage this is the wrapper class used to process list of file i.e. file names available to download from WIBS server
* each of the file is downloaed and based on type of file DEEDS and DERPS identified by file naming convention
* corresponding parser is invoked and file is processed and associated Order is updated.
*/

global with sharing class P2PWIBSResponseFileFacade implements Database.Batchable<String>, Database.Stateful, Database.AllowsCallouts  {
    
    public List<String> files { get; private set; }
    private P2PWIBSParserBase parser;
    
    private List<P2PWIBSResponseFileProcessor> processors;
    
    public P2PWIBSResponseFileFacade() {}
    
    global Iterable<String> start(Database.BatchableContext batchableContext)  {
        P2PWIBSClient.WIBSRequestParam wibsRequestParameters = new P2PWIBSClient.WIBSRequestParam();
        P2PWIBSClient wibsClient = new P2PWIBSClient();
        P2PWIBSFilesListResponseParserVisitor p2PWIBSFilesListResponseParserVisitor = new P2PWIBSFilesListResponseParserVisitor();
        wibsClient.callWIBSApp(P2PWIBSClient.WIBS_REQUEST_TYPE.FILESLIST, p2PWIBSFilesListResponseParserVisitor, wibsRequestParameters);
        this.files = new List<String>(); 
        for(String file : p2PWIBSFilesListResponseParserVisitor.files)  {
            if((file.containsIgnoreCase('DEEDS') || file.containsIgnoreCase('DERPS') || file.containsIgnoreCase('CashAppliedFile') || 
               file.containsIgnoreCase('RECALL') || file.containsIgnoreCase('QBRESPONSE') || file.containsIgnoreCase('QBRETURNS')) && !file.containsIgnoreCase('RPT_DEEDS'))  {
                this.files.add(file);
            }
        }
        
        this.files.sort(); return this.files;
    }
    
    /**
     * Orders to be updated should be committed
     * THEN the delete routine should be queued
     */ 
    global void finish(Database.BatchableContext batchableContext) {
        /** call REST API to delete already processed file
        @FIXME - move to a different batch transaction outside this Txn Scope
        */
/*       
        P2PWIBSClient.WIBSRequestParam wibsRequestParameters = new P2PWIBSClient.WIBSRequestParam();
        for(String file : this.files)  {
            wibsRequestParameters.fileName = file;
            P2PWIBSClient wibsClient = new P2PWIBSClient();
            wibsClient.callWIBSApp(P2PWIBSClient.WIBS_REQUEST_TYPE.FILEDELETE, null, wibsRequestParameters);      
        }
*/      

        
        for(P2PWIBSResponseFileProcessor processor : this.processors)  {
            processor.finalize();
            System.debug(processor.name + ' processed success : ' + processor.success);
        }
        /** @FIXME done here. */
        System.debug('Before Queueable call : ' + this.processors.size());
        Id id = System.enqueueJob(new P2PWIBSResponseFilePostProcessor(this.processors));
    }
    
    public void execute(Database.BatchableContext batchableContext, List<String> scope)  {
        /** call REST API to download contents of file available in the list one by one. */
        this.processors = new List<P2PWIBSResponseFileProcessor>();
        P2PWIBSClient.WIBSRequestParam wibsRequestParameters = new P2PWIBSClient.WIBSRequestParam();
        String data = '';
        for (String file : scope)  {
            data = '';
            wibsRequestParameters.fileName = file;
            P2PWIBSClient wibsClient = new P2PWIBSClient();
            P2PWIBSFileDownloadResponseParserVisitor p2PWIBSFileDownloadResponseParserVisitor = new P2PWIBSFileDownloadResponseParserVisitor();
            wibsClient.callWIBSApp(P2PWIBSClient.WIBS_REQUEST_TYPE.FILEDOWNLOAD, p2PWIBSFileDownloadResponseParserVisitor, wibsRequestParameters);
            data = p2PWIBSFileDownloadResponseParserVisitor.data;
            System.debug('data: '+data);
            /** now identify type of file DEEDS or DERPS based on file name as per naming convention already specified. 
             and invoke corresponding pareser. */
            if(true == file.containsIgnoreCase('DEEDS'))  { this.parser = P2PWIBSDEEDSParser.getInstance(data); this.parser.type = 'DEEDS';
            } else if (true == file.containsIgnoreCase('DERPS'))  { this.parser = P2PWIBSDERPSParser.getInstance(data); this.parser.type = 'DERPS';
            } else if (true == file.containsIgnoreCase('QBRETURNS'))  { this.parser = P2PWIBSQBRETURNSParser.getInstance(data); this.parser.type = 'QBRETURNS';
            } else if (true == file.containsIgnoreCase('CashAppliedFile'))  { this.parser = P2PWIBSCAFParser.getInstance(data); this.parser.type = 'CAF';
            } else if (true == file.containsIgnoreCase('RECALL'))  { this.parser = P2PWIBSRECALLParser.getInstance(data); this.parser.type = 'RECALL'; 
            } else if (true == file.containsIgnoreCase('QBRESPONSE'))  { this.parser = P2PWIBSQBRESPONSEParser.getInstance(data); this.parser.type = 'QBRESPONSE'; }
            
            this.processors.add(new P2PWIBSResponseFileProcessor(file, this.parser));
        }

        /* after downloading all required data using callouts start processing. */
        this.process();

    }
    
    /**
    * this private method actual will perform the processing of file based on data parsed by the parser
    * this method will fire getRecords method of parser and split chunk of data into List of String (per line)
    * each line is Header, Transaction or Footer, this will be identified based on the FIRST character of line
    * 0: header, 1: transaction (record), 7: footer once type of record is identified then we need to parser header, record or footer
    * using parser methods and received tokens for each of the field present and most important is status indicator G: processed successfully or R: rejected.
    */
    private void process()  {
        
        for(P2PWIBSResponseFileProcessor processor : this.processors)  {
            processor.execute();
        }
    }
}