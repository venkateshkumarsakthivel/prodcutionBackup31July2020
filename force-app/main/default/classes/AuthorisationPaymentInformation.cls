public without sharing class AuthorisationPaymentInformation {

    @AuraEnabled
    public static OrderItem getAuthorisationPaymentInformation(String orderId){
        try{
            OrderItem orderItem = [SELECT Id, Annual_BSP_Count__c, Annual_TSP_Count__c, Order.Description 
                                   FROM OrderItem WHERE OrderId = :orderId];
            System.debug('item>>' + orderItem);
            return orderItem;
        }
        catch (Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'AuthorisationPaymentInformation','getAuthorisationPaymentInformation',ex.getMessage(),ex);
            return null;
        }
    }
}