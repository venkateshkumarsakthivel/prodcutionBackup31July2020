public class P2PWIBSQBResponseParserFacade extends P2PWIBSParserFacadeBase  {
	@TestVisible private with sharing class Header {
	@TestVisible private String type;
		private String status;
		private String rdate;
		public Header(String type)  {
			this.type = type;
		}
	}
	@TestVisible private Header header;
	@TestVisible private final String STATUS_REJECTED = 'Payment Rejected';
    private final String STATUS_PAID_IN_FULL = 'Paid in Full';
    private final String STATUS_PAYMENT_UNCLEAR = 'Payment Uncleared';
	public P2PWIBSQBResponseParserFacade () { 
        this.ordersToBeUpdated = new Map<String,Order>(); 
    }	
	
	public override void execute(List<String> tokens)  {
		this.tokens = tokens;
        if(this.tokens.get(P2PWIBSParserFacadeBase.QBRECORD_TYPE) == '3' && 
           (this.tokens.get(P2PWIBSParserFacadeBase.BATCH_TYPE) == 'DD' || this.tokens.get(P2PWIBSParserFacadeBase.BATCH_TYPE) == 'CC')) {
			this.header = new Header(tokens.get(P2PWIBSParserFacadeBase.BATCH_TYPE).trim());
        }
        if(this.tokens.get(P2PWIBSParserFacadeBase.QBRECORD_TYPE) == '5')  {
			this.process();
        } 
	}
    
    /**
	* this private process method will switch between processing of transactions related to exception report or disbursment report.
	*/
	private void process() {
        
		if(this.header.type.equalsIgnoreCase('DD'))  {
            this.processDirectDebitTxn();
        } else if (this.header.type.equalsIgnoreCase('CC'))  {
            this.processCreditCardTxn();
        }             
       
	}
	
    private void processDirectDebitTxn() {
        String paymentRef = this.tokens.get(P2PWIBSParserFacadeBase.AUTH_NUMBER).trim();
        Order payment = [SELECT ID FROM Order where Payment_Reference__c =: paymentRef];
        String summaryCode = this.tokens.get(P2PWIBSParserFacadeBase.SUMMARY_CODE).trim();
        if(summaryCode != '0') {
            payment.Payment_Summary_Code__c = summaryCode;
            payment.Payment_Response_Code__c = this.tokens.get(P2PWIBSParserFacadeBase.RESPONSE_CODE).trim();
            payment.Payment_Response_Description__c = this.tokens.get(P2PWIBSParserFacadeBase.RESPONSE_DESCRIPTION).trim();
            payment.Status = STATUS_REJECTED;
            this.ordersTobeUpdated.put(this.tokens.get(P2PWIBSParserFacadeBase.AUTH_NUMBER).trim(), payment);
        } else {
            payment.Received_Date__c = System.today();
            payment.Status = STATUS_PAYMENT_UNCLEAR;
            payment.Payment_Cleared_Date__c = P2PWIBSParserFacadeBase.calculateT3(Date.today());
			this.ordersTobeUpdated.put(this.tokens.get(P2PWIBSParserFacadeBase.AUTH_NUMBER).trim(), payment);
        }
        
    }
	private void processCreditCardTxn() {
      
        String paymentRef = this.tokens.get(P2PWIBSParserFacadeBase.AUTH_NUMBER).trim();
        Order payment = [SELECT ID, TotalAmount	 FROM Order where Payment_Reference__c =: paymentRef];
        String summaryCode = this.tokens.get(P2PWIBSParserFacadeBase.SUMMARY_CODE).trim();
        payment.Payment_Summary_Code__c = summaryCode;
        payment.Payment_Response_Code__c = this.tokens.get(P2PWIBSParserFacadeBase.RESPONSE_CODE).trim();
        payment.Payment_Response_Description__c = this.tokens.get(P2PWIBSParserFacadeBase.RESPONSE_DESCRIPTION).trim();
            
        if(summaryCode != '0') {
            payment.Status = STATUS_REJECTED;
        } else {
            // successful payment
           	payment.Status = STATUS_PAID_IN_FULL;
            String totalAmountPaid = this.tokens.get(P2PWIBSParserFacadeBase.AMOUNT).trim();
            payment.Amount_Paid__c = Decimal.valueOf(totalAmountPaid)/100;
            payment.Surcharge_Amount__c = payment.Amount_Paid__c - payment.TotalAmount;
            payment.Received_Date__c = System.today();
            payment.Payment_Cleared_Date__c = System.today();
            payment.Receipt_Number__c = this.tokens.get(P2PWIBSParserFacadeBase.RECEIPT_NUMBER).trim();
        }
        this.ordersTobeUpdated.put(this.tokens.get(P2PWIBSParserFacadeBase.AUTH_NUMBER).trim(), payment);
       
    }
    
}