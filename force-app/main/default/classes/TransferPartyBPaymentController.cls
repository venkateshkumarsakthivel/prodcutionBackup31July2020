/*
 * @Description: Controller class for transfer party B payment
 */
public without sharing class TransferPartyBPaymentController {

    @AuraEnabled
    public static Case retrieveApplicationDetails(String caseId){
        List<Case> applications = [SELECT Id, AccountId, Levy_Due__c, Licence_Fee_Due__c, 
                                        (SELECT Id, AccountId, Payment_Method__c, Status, TotalAmount, 
                                            Payment_Reference__c, BPay_Reference__c 
                                        FROM Orders__r)
                                   FROM Case WHERE Id = :caseId];
        Case caseRec = new Case();          
        if(!applications.isEmpty()){
            caseRec = applications[0];
        }
        return caseRec;
    }
    
    @AuraEnabled
    public static Case submitApplication(String caseId, String paymentStr){
        System.debug(LoggingLevel.INFO, 'Payment String: ' + paymentStr);
        Order payment = (Order)JSON.deserialize(paymentStr, Order.class);
        List<Case> application = [SELECT Id, Status, Levy_Due__c, Sub_Status__c, AccountId FROM Case WHERE Id =:caseId];
        List<Authorisation__c> licence = [SELECT Id, Application__c, Licence_Class__c, Service_Provider__c 
                                            FROM Authorisation__c 
                                            WHERE Application__c = :caseId];
        for(Case app: application){
            app.Status = GlobalConstants.APPLICATION_STATUS_LODGED;
            app.Sub_Status__c = GlobalConstants.PENDING_PAYMENT_SUB_STATUS;
            app.Date_Submitted__c = System.today();
        }
        if(application.isEmpty() || licence.isEmpty()){
            return null;
        }
        
        if(application[0].Levy_Due__c == 0) {
            payment.Status = GlobalConstants.PAYMENT_PAID_IN_FULL_STATUS;
        }
        
        update payment;
        
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= true;
        
        Database.update(application, dmo);
        
        //update status of authorisation linked to transfer case as draft
        for(Authorisation__c lic : licence){
            lic.Status__c = GlobalConstants.AUTHORISATION_STATUS_DRAFT;
        }
        update licence;
        
        application = [SELECT Id, Status, Sub_Status__c, Payment__c, 
                            Payment__r.Payment_Method__c, Payment__r.Payment_Reference__c, 
                            Payment__r.Status, Payment__r.TotalAmount,
                            (SELECT Id, Payment_Reference__c, Payment_Method__c, Status, BPay_Reference__c FROM Orders__r)
                        FROM Case WHERE Id = :caseId];
        return application[0];
    }
    
    @AuraEnabled
    public static String processPaymentRequest(Order payment){
       P2PWIBSPaymentFacade paymentFacade = new P2PWIBSPaymentFacade();
       
       Map<String, String> processedPaymentDetails = paymentFacade.securityToken('Taxi', payment.TotalAmount, payment.Payment_Reference__c, 
            GlobalConstants.PAYMENT_METHOD_FACADE_MAPPING.get(payment.Payment_Method__c), false, payment.Id);
       
       return processedPaymentDetails.get('redirectURL');
    }
    
    @AuraEnabled
    public static String orderStatus(String caseId) {
        system.debug('caseId '+ caseId);
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