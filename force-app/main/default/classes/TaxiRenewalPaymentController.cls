/*
 * @Description: Controller class to for licence renewal payment component.
 */
public without sharing class TaxiRenewalPaymentController {
    
    private static final String renewalProductName = GlobalConstants.LICENCE_RENEWAL_PRODUCT_NAME_PREFIX + ' - ';
    
    @AuraEnabled
    public static Order submit(Order payment){
        if(payment == null){
            return null;
        }
        //update payment details with payment method
        payment.Status = GlobalConstants.PAYMENT_PAID_IN_FULL_STATUS;
        if(payment.TotalAmount > 0){
            payment.Status = GlobalConstants.PAYMENT_DUE_STATUS;
        }
        update payment;
        
        List<Case> application = [  SELECT Id, Status, Sub_Status__c, Date_Submitted__c, CaseNumber,
                                        Authorisation__c, Authorisation__r.Status__c 
                                    FROM Case WHERE Id = :payment.Application__c];
        if(application.isEmpty()){
            return null;
        }
        
        application[0].Status = GlobalConstants.CLOSED_CASE_STATUS;
        application[0].Sub_Status__c = GlobalConstants.APPROVED_CASE_SUB_STATUS ;
        application[0].Date_Submitted__c = System.today();
        if(payment.TotalAmount > 0){
            application[0].Sub_Status__c = GlobalConstants.PENDING_PAYMENT_SUB_STATUS;
        }
        
        //update status as lodge if authorisation is not auto-granted
        if(application[0].Authorisation__r == null 
                || application[0].Authorisation__r.Status__c != GlobalConstants.TAXI_LICENCE_GRANTED_STATUS){
            application[0].Status = GlobalConstants.APPLICATION_STATUS_LODGED;
            application[0].Sub_Status__c = GlobalConstants.CASE_SUB_STATUS_ASSESSMENT_PENDING ;            
        }
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= true;
        
        Database.update(application, dmo);
        
        Order paymentRec = [SELECT Id, TotalAmount, Status, Description, BPay_Reference__c, 
                                Application__c, Payment_Method__c, Payment_Reference__c, Application__r.CaseNumber
                            FROM Order WHERE Id =:payment.Id];
        
        return paymentRec;
    }
    
    @AuraEnabled
    public static Order retrievePaymentDetails(String caseId){
        //retrieve payment records for the renewal application.
        Map<Id, Order> paymentMap = new Map<Id, Order>([SELECT Id, TotalAmount, Status, Description, BPay_Reference__c, 
                                                            Application__c, Payment_Method__c, Payment_Reference__c, 
                                                            (SELECT Id, Description, TotalPrice FROM OrderItems)
                                                        FROM Order
                                                        WHERE Application__c = :caseId]);
        
        //retrieve line item for renewal application fees.
        List<OrderItem> lineItems = [SELECT Id, OrderId FROM OrderItem 
                                    WHERE OrderId IN :paymentMap.keySet() 
                                        AND Product2.Name LIKE :renewalProductName + '%'];
        
        if(lineItems.isEmpty()){
            return null;
        }
        return paymentMap.get(lineItems[0].OrderId);
    }
    
    @AuraEnabled
    public static Boolean isInternalUser(){
        return GlobalUtility.isInternalUser();
    }
    
    @AuraEnabled
    public static String processPaymentRequest(String paymentId, Boolean isInitiatedFromManageAccount){
       List<Order> payment = [SELECT Id, Payment_Method__c, TotalAmount, Payment_Reference__c, BPay_Reference__c FROM Order WHERE Id =:paymentId];
       if(payment.isEmpty()){
           return null;
       }
       String context = GlobalConstants.INVOCATION_CONTEXT_TAXI;
       if(isInternalUser()){
           context = GlobalConstants.INVOCATION_CONTEXT_INTERNAL_STAFF;
       }
       P2PWIBSPaymentFacade paymentFacade = new P2PWIBSPaymentFacade();
       
       Map<String, String> processedPaymentDetails = paymentFacade.securityToken(context, payment[0].TotalAmount, payment[0].Payment_Reference__c, 
            GlobalConstants.PAYMENT_METHOD_FACADE_MAPPING.get(payment[0].Payment_Method__c), isInitiatedFromManageAccount, payment[0].Id);
       
       return processedPaymentDetails.get('redirectURL');
    }
    
    @AuraEnabled
    public static String orderStatus(String caseId) {
        system.debug('caseID '+ caseId);
        Order orderst = [SELECT status FROM Order WHERE Application__c =: caseId LIMIT 1];
        system.debug('orderStatus '+ orderst.status);
        return orderst.status;
        
    }
    
    @AuraEnabled
    public static String orderReceiptNumber(String caseId) {
        system.debug('caseID '+ caseId);
        Order orderReceiptNum = [SELECT Receipt_Number__c FROM Order WHERE Application__c =: caseId LIMIT 1];
        system.debug('Order Receipt Number '+ orderReceiptNum.Receipt_Number__c);
        return orderReceiptNum.Receipt_Number__c;
        
    }
}