public with sharing abstract class P2PWIBSParserFacadeBase {
    protected List<String> tokens;
   @TestVisible protected Map<String, Order> ordersToBeUpdated;
    @TestVisible protected List<Order> orders;
    /** some constants related to header section of the file for ENTRs and RLSEs. */
    public static Integer HEADER_TYPE = 0;
    public static Integer HEADER_REPORT_TYPE = 1;
    public static Integer HEADER_REPORT_STATUS = 10;
    public static Integer HEADER_REPORT_DATE = 8; 
    
    public static Integer QBRECORD_TYPE = 0;
    public static Integer AUTH_NUMBER = 7;
    public Static Integer BATCH_TYPE = 3;
    public Static Integer SUMMARY_CODE = 11;
    public Static Integer RESPONSE_CODE = 12;
    public Static Integer RESPONSE_DESCRIPTION = 13;
    
    public Static Integer RECEIPT_NUMBER = 9;
    public Static Integer AMOUNT = 4;
    
    public Static Integer QB_RETURNS_REFERENCE_NUMBER = 3;
    public Static Integer QB_RETURNS_TXN_CODE = 5;
    public Static Integer QB_RETURNS_TXN_DESC = 6;
    
    /** some constans related to fields in the response file. */
    public static Integer PAYMENT_REFERENCE_NUMBER = 7;
    public static Integer AMOUNT_PAID = 5;
    public static Integer STATUS_INDICATOR = 11;
    
    
    /** RECALL file constants related to HEADER recrod. */
    public static Integer RECALL_HEADER_REPORT_DATE = 7;
    
    /** RECALL file constants related to transaction recrod. */
    public static Integer RECALL_PAYMENT_REFERENCE_NUMBER = 1;
    public static Integer RECALL_AMOUNT_PAID = 3;
    public static Integer RECALL_RECEIPT_NUMBER = 7;
    
    /** CAF file constants related to transaction record. */
    public static Integer CAF_CLEARING_DATE = 0;
    public static Integer CAF_RECEIPT_NUMBER = 1;
    public static Integer CAF_PAYMENT_REFERENCE_NUMBER = 3;
    public static Integer CAF_PAYMENT_AMOUNT = 4;
    public static Integer CAF_PAYMENT_STATUS = 5;
    public static Integer CAF_CUSTOMER_REFERENCE_NUMBER = 11;
    public static Integer RETURNS_CAF_CUSTOMER_REFERENCE_NUMBER = 10;
    public static Integer CAF_CARD_TYPE = 7;
    
    public abstract void execute(List<String> tokens);
    
    /** finalize method will push all order to update queue. */
    public List<Database.SaveResult> finalize()  {
        return Database.update(this.ordersToBeUpdated.values(), false);
    }
    
    
    public static Date calculateT3(Date receivedOrClearedDate)  {
        /** latest logic will skip everything manually calculated and will be based on Business Hours configured in the System
        * weekends, public holidays will be configured in the system and this will use the pre configured date and time */
       
        BusinessHours nswBusinessHours = [SELECT Id, MondayStartTime,MondayEndTime FROM BusinessHours WHERE isDefault = true];
        
        /* Calculate T+3 business day from received date */
        receivedOrClearedDate = GlobalUtility.retrieveBusinessDay(receivedOrClearedDate, 3, nswBusinessHours);
        
        return receivedOrClearedDate;
    }
    
}