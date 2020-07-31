/**
* @name P2PWIBSDEEDSParserFacade.cls
* @description this class is reposible to process every token parsed by DEEDS parser per record Type
* record type are HEADER, RECORD (transaction) and FOOTER
* if HEADER contains ENTR in the second token then 
* all transactions RECORD type lines till FOOTER line will be process by validating amount, transaction date and payment reference number
* against Order record in the salesforce system based on indicator status if G
* then Order record status is changed to 'Payment Uncleared' else if R
* then Order record status is changed to 'Payment Rejected'
* if HEADER contains RLSE in the second token then 
* all transactions RECORD type lines till last line will be process by validating amount, transaction date and payment reference number
* against Order record in the salesforce system based on indicator status if G
* then Order record status is changed to 'Payment Uncleared' else if R OR D
* then Order record status is changed to 'Payment Rejected' else if C
* then Order record status is changed to 'Payment Cancelled'
*/
public with sharing class P2PWIBSDEEDSParserFacade extends P2PWIBSParserFacadeBase  {
    
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
        if(this.header.type.equalsIgnoreCase('ENTR'))  {
            this.processENTRs();
        } else if (this.header.type.equalsIgnoreCase('RLSE'))  {
            this.processRLSEs();
        }
    }
    
    /** this method will process all exception report transactions and mark corresponding Order status to 'Payment Rejected' based on staus, if Status Indicator is marked as R */
    private void processENTRs() {
        System.debug('processing ENTRs : process records only with status Indicator R as R status records will have corresponding record in Release Report with appropriate Status Indicator.');
        System.debug('Payment Reference to find : ' + this.tokens.get(P2PWIBSParserFacadeBase.PAYMENT_REFERENCE_NUMBER));
        if(this.tokens.get(P2PWIBSParserFacadeBase.STATUS_INDICATOR).trim().equalsIgnoreCase('R'))  {
            this.orders = [SELECT Id, Payment_Reference__c, Status, Previous_Payment_Status__c, Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c FROM ORDER WHERE Payment_Reference__c = :this.tokens.get(P2PWIBSParserFacadeBase.PAYMENT_REFERENCE_NUMBER).trim() LIMIT 1];
            System.debug('Orders.found : ' + this.orders.size());
            if(this.orders.size() == 1)  {
                Order order = this.orders[0];
                order.Previous_Payment_Status__c = order.Status;
                order.Status = GlobalConstants.ORDER_STATUS.get('REJECTED');
                
                this.ordersTobeUpdated.put(this.tokens.get(P2PWIBSParserFacadeBase.PAYMENT_REFERENCE_NUMBER).trim(), order);
            }
        }
    }
    
    /** this method will process all disbursment report transactions and mark corresponding Order status to 'Paid In Full' or 'Payment Rejected' or 'Payment Cancelled' based on staus Indicator G, C, (R OR D) */
    private void processRLSEs() {
        System.debug('processing RLSEs : process order and other related fields as per report.');
        this.orders = [SELECT Id, Payment_Reference__c, Status, Previous_Payment_Status__c, Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c FROM ORDER WHERE Payment_Reference__c = :this.tokens.get(P2PWIBSParserFacadeBase.PAYMENT_REFERENCE_NUMBER).trim() LIMIT 1];
        System.debug('Order.Payment_Reference__c = ' + this.tokens.get(P2PWIBSParserFacadeBase.PAYMENT_REFERENCE_NUMBER).trim() + ' Orders.found : ' + this.orders.size());
        Date receivedOrClearedDate = Date.today();
        if(this.orders.size() == 1)  {
            System.debug('Payment Reference to find : ' + this.tokens.get(P2PWIBSParserFacadeBase.PAYMENT_REFERENCE_NUMBER).trim()  
                         + ' Status.found : ' + this.tokens.get(P2PWIBSParserFacadeBase.STATUS_INDICATOR).trim());
            Order order = this.orders[0];
            order.Previous_Payment_Status__c = order.Status;
            order.Status = this.tokens.get(P2PWIBSParserFacadeBase.STATUS_INDICATOR).trim() == 'G'   		?
                GlobalConstants.ORDER_STATUS.get('UNCLEARED') 		:
            this.tokens.get(P2PWIBSParserFacadeBase.STATUS_INDICATOR).trim() == 'C' 	?
                GlobalConstants.ORDER_STATUS.get('CANCELLED') 	:
            GlobalConstants.ORDER_STATUS.get('REJECTED');
            order.Amount_Paid__c = Decimal.valueOf(this.tokens.get(P2PWIBSParserFacadeBase.AMOUNT_PAID).trim()) / 100;
            
            System.debug('Order.Amount_Paid__c : ' + order.Amount_Paid__c);
            
            /** re construct date in the as existing format is not support in APEX for direct conversion using valueOf or parse methods. */
            String year, month, day;
            day = this.header.rdate.subString(0, 2);
            month = this.header.rdate.subString(2, 4);
            year = this.header.rdate.subString(4, 6);
            receivedOrClearedDate = Date.parse(day + '/' + month + '/' + year);
            
            order.Payment_Cleared_Date__c = P2PWIBSParserFacadeBase.calculateT3(receivedOrClearedDate);
            
            this.ordersTobeUpdated.put(this.tokens.get(P2PWIBSParserFacadeBase.PAYMENT_REFERENCE_NUMBER).trim(), order);
        }
    }
    
    public P2PWIBSDEEDSParserFacade()  { this.ordersToBeUpdated = new Map<String, Order>(); }
    
    public override void execute(List<String> tokens)  {
        this.tokens = tokens;
        if(tokens.get(P2PWIBSParserFacadeBase.HEADER_TYPE).equalsIgnoreCase('0'))  {
            this.header = new Header(tokens.get(P2PWIBSParserFacadeBase.HEADER_REPORT_TYPE).trim(), tokens.get(P2PWIBSParserFacadeBase.HEADER_REPORT_STATUS), tokens.get(P2PWIBSParserFacadeBase.HEADER_REPORT_DATE).trim());
        } else if(tokens.get(P2PWIBSParserFacadeBase.HEADER_TYPE).equalsIgnoreCase('7'))  {
            System.debug('Process foooter if required');
        } else this.process();
    }
}