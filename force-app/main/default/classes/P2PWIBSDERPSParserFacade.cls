public with sharing class P2PWIBSDERPSParserFacade extends P2PWIBSParserFacadeBase  {
	
	/** private header class to hold status and type of section being processed. */
	private with sharing class Header {
		private String type;
		private String status;
		private String rdate;
		public Header(String type, String status, String rdate)  {
			this.type = type;
			this.status = status;
			this.rdate = rdate;
		}
	}
	private Header header;
	
	
	/**
	* this private process method will switch between processing of transactions related to exception report or disbursment report.
	*/
	private void process() {
			this.orders = [SELECT Id, Payment_Reference__c, Status, Previous_Payment_Status__c, Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c FROM ORDER WHERE Payment_Reference__c = :this.tokens.get(P2PWIBSParserFacadeBase.PAYMENT_REFERENCE_NUMBER).trim() LIMIT 1];
			System.debug('Order.Payment_Reference__c = ' + this.tokens.get(P2PWIBSParserFacadeBase.PAYMENT_REFERENCE_NUMBER).trim() + ' Orders.found : ' + this.orders.size());
			if(this.orders.size() == 1)  {
				Order order = this.orders[0];
				order.Previous_Payment_Status__c = order.Status;
				order.Status = GlobalConstants.ORDER_STATUS.get('REJECTED');
				
				this.ordersTobeUpdated.put(this.tokens.get(P2PWIBSParserFacadeBase.PAYMENT_REFERENCE_NUMBER).trim(), order);
			}
	}
	
	public P2PWIBSDERPSParserFacade () { this.ordersToBeUpdated = new Map<String,Order>(); }
	public override void execute(List<String> tokens)  {
		this.tokens = tokens;
		System.debug(this.tokens);
		if(tokens.get(P2PWIBSParserFacadeBase.HEADER_TYPE).equalsIgnoreCase('0'))  {
			this.header = new Header(tokens.get(P2PWIBSParserFacadeBase.HEADER_REPORT_TYPE).trim(), tokens.get(P2PWIBSParserFacadeBase.HEADER_REPORT_STATUS), tokens.get(P2PWIBSParserFacadeBase.HEADER_REPORT_DATE).trim());
		} else if(tokens.get(P2PWIBSParserFacadeBase.HEADER_TYPE).equalsIgnoreCase('7'))  {
			System.debug('Process foooter if required');
		} else this.process();
	}
}