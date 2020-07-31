/**
* @name QBRequestFileGenerator.cls
* @usage this is the wrapper class used to generate stream of contents to be used as Quick Batch Request file
* @dependencies QBFileHeader, QBBatchHeader, QBTransaction, QBBatchFooter, QBFileFooter
* each of the above mentioned classes is responsible to generate specific line of a File Control Header, Batch Control Header,
* transaction detail record, Batch Control Footer and File Control Footer.
*/
public with sharing class QBRequestFileGenerator {
	
	public P2PWIBSFileUploadResponseParserVisitor visitor { get; set; }
    
    public QBRequestFileGenerator() { }
    
    public void execute(List<Order> orders)  {
        String lines;
        Decimal fileTransactionAmount = 0, creditCardTxnAmount = 0, directDebitTxnAmount = 0;
        Integer fileTransactions = 0;
        Attachment abafile = new Attachment();
        QBFileHeader fileHeader = new QBFileHeader();
        lines = fileHeader.toString();
        
        QBBatchHeader ccBatchHeader = new QBBatchHeader('CC');
        QBBatchHeader ddBatchHeader = new QBBatchHeader('DD');
        
        /** this will be iteration over list of oder to generate transaction records for each of the order present in the
        	* system for the day. */
        Integer creditCardTxnCount = 0, directDebitTxnCount = 0 ;
        String ccRecords = '', ddRecords = '';
        for(Order order : orders)  {
            fileTransactions += 1;
            fileTransactionAmount += order.TotalAmount;
           	QBTransaction qbTxnRecord = new QBTransaction(order.Authorisation__r.Payment_Token__c , order.TotalAmount, order.Payment_Reference__c);
            if(order.Payment_Method__c == GlobalConstants.PAYMENT_METHOD_CREDIT_DEBIT_CARD)  {
                creditCardTxnCount += 1;
                creditCardTxnAmount += order.TotalAmount;
                ccRecords += qbTxnRecord.toString();
            }
            if(order.Payment_Method__c == GlobalConstants.PAYMENT_METHOD_DIRECT_DEBIT) {
                directDebitTxnCount += 1;
                directDebitTxnAmount += order.TotalAmount;
                ddRecords += qbTxnRecord.toString();
            }
        }
        if(creditCardTxnCount+directDebitTxnCount == 0) return;
        if(creditCardTxnCount > 0) {
            lines += ccBatchHeader.toString();
            lines += ccRecords;
            lines += new QBBatchFooter(creditCardTxnCount, creditCardTxnAmount, ccBatchHeader.communityCode, ccBatchHeader.uniqueBatchId).toString();
        }
        if(directDebitTxnCount > 0) {
			lines += ddBatchHeader.toString();
            lines += ddRecords;
            lines += new QBBatchFooter(directDebitTxnCount, directDebitTxnAmount, ddBatchHeader.communityCode, ddBatchHeader.uniqueBatchId).toString();            
        }
        Integer batchCount = 0;
        If(creditCardTxnCount > 0 ) batchCount++;
        if(directDebitTxnCount > 0 ) batchCount++;
        QBFileFooter fileFooter = new QBFileFooter(batchCount, fileTransactions, fileTransactionAmount, fileHeader.communityCode, fileHeader.clientName, fileHeader.uniqueFileId);
        lines += fileFooter.toString();

        System.debug('\n'+lines);
        //ApplicationLogUtility.logMessage(GlobalConstants.Info, 'QBRequestFileGenerator', 
        //                                         'execute', lines , null);
        
        P2PWIBSClient.WIBSRequestParam params = new P2PWIBSClient.WIBSRequestParam();
        params.fileName = 'QBRequest_TNSWPTP_' + DateTime.now().format('yyyyMMddkkmmss')  + '.txt';
        params.fileData = lines;
        P2PWIBSClient client = new P2PWIBSClient();
        this.visitor = new P2PWIBSFileUploadResponseParserVisitor();
        client.callWIBSApp(P2PWIBSClient.WIBS_REQUEST_TYPE.FILEUPLOAD, this.visitor, params);
		
    }    

}