public with sharing class PayFromOrderDetailsLayoutController {

    @AuraEnabled
    public static String show(String Id)  {
        Order order = [SELECT Id, Payment_Reference__c, Status, Previous_Payment_Status__c, Receipt_Number__c, Amount_Paid__c, Payment_Cleared_Date__c, Surcharge_Amount__c, TotalAmount, Payment_Method__c, Authorisation__r.Authorisation_Type__c FROM ORDER WHERE Id = :id];
        return Json.serialize(order);
    }
}