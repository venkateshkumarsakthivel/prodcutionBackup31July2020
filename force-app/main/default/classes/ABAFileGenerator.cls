/**
* @name ABAFileGenerator.cls
* @usage this is the wrapper class used to generate stream of contents to be used as ABA file or create attachment of ABA file
* @dependencies ABAHeader, ABAransaction, ABAFooter
* each of the above mentioned classes is responsible to generate specific line of a ABA header, transaction and footer.
*/

public with sharing class ABAFileGenerator  {

	public Integer fileOfTheDay;
	public P2PWIBSFileUploadResponseParserVisitor visitor { get; set; }
	
	public ABAFileGenerator() {}
	
    public void execute(Integer fileOfTheDay, List<Order> orders)  {
    		this.fileOfTheDay = fileOfTheDay;
    		String lines;
    		Decimal total = 0, ctotal = 0, dtotal = 0;
    		Integer totalTransactions = 0;
        Attachment abafile = new Attachment();
        ABAHeader abaHeader = new ABAHeader(String.valueOf(this.fileOfTheDay));
        lines = abaHeader.toString();
        ABAFooter abaFooter;
        ABATransaction abaTransaction;
        
        /** this will be iteration over list of oder to generate transaction records for each of the order present in the
        	* system for the day. */
        for(Order order : orders)  {
        		totalTransactions += 1;
        		/**
        		* @TODO get parameters from Order and Authorisation relation properties populated in the flow of application creation. */
        			abaTransaction = new ABATransaction(order.Authorisation__r.BSB_Number__c, order.Authorisation__r.Bank_Account_Number__c, '13', order.TotalAmount, order.Authorisation__r.Bank_Account_Name__c, order.Payment_Reference__c, order.Authorisation__r.Authorisation_Name__c);
        		if(abaTransaction.transactionCode == '13')  {
        			dtotal += order.TotalAmount;
        		/** } else { ctotal += order.TotalAmount; this line is commented as aba file will contain debit trasactions only. */
        		}
        		lines += abaTransaction.toString();
        }
        total = Math.abs(ctotal - dtotal);
        abaFooter = new ABAFooter(total, ctotal, dtotal, totalTransactions);
        lines += abaFooter.toString();
        System.debug('');
        System.debug(lines);
        
        P2PWIBSClient.WIBSRequestParam params = new P2PWIBSClient.WIBSRequestParam();
        params.fileName = 'ABAfileforEMI_' + DateTime.now().format('ddMMyyyykkmmss') + '_' + this.fileOfTheDay + '.aba';
        params.fileData = lines;
        P2PWIBSClient client = new P2PWIBSClient();
        this.visitor = new P2PWIBSFileUploadResponseParserVisitor();
        client.callWIBSApp(P2PWIBSClient.WIBS_REQUEST_TYPE.FILEUPLOAD, this.visitor, params);
    }

}