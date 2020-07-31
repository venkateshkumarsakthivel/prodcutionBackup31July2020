/*
 * Helper class to stamp Payment Type From authorisation for Order Type='Authorisation Fee'
 *
 */

public with sharing class AuthFeePaymentUpdator {

     public void updatePaymentType(List<Order> orders) {
         
         SET<String> accountIds = new SET<String>();
         MAP<String,Order> accountIdVsOrder = new MAP<String,Order>();
         
         //Map of orders of type = 'Authorisation fee'
         for(Order payment : orders) {
             
             if(payment.Type == 'Authorisation fee') {
                 accountIdVsOrder.put(payment.accountId, payment);
             }
         }
         
         if(accountIdVsOrder.keySet().size() > 0) {
       	 	
             // fetch previoud financial year period
             Integer currentYear = System.now().Year();
             Auth_Fee_Collection_Period_Configuration__mdt  FeeCollectionPeriod = [SELECT Start_Date__c, End_Date__c 
                                                                                   FROM Auth_Fee_Collection_Period_Configuration__mdt
                                                                                   WHERE Year__c = :String.valueOf(currentYear) LIMIT 1];
             Date previousFinancialYearStart = FeeCollectionPeriod.Start_Date__c;
             Date previousFinancialYearEnd = FeeCollectionPeriod.End_Date__c;
             
                
             //Auth required status
             SET<String> AuthStatusSet = new SET<String>{'Granted With Conditions','Granted Unconditionally','Lapsed','Granted','Suspended'};      
             SET<String> authTypeSet = new SET<String>{'TSP', 'BSP'};        
                 
             
             // Related authorisation for Account on Order
             List<Authorisation__c> auths = [SELECT Id, Authorisation_Type__c, Service_Provider__c
                                             FROM Authorisation__c
                                             WHERE Service_Provider__c IN: accountIdVsOrder.keySet()
                                             AND Authorisation_Type__c IN :authTypeSet
                                             AND ((Status__c IN :AuthStatusSet AND (Start_Date__c <= :previousFinancialYearEnd AND End_Date__c >= :previousFinancialYearStart))
                                                  OR (Status__c = 'Cancelled' AND (Decision_Date__c <= :previousFinancialYearEnd AND Decision_Date__c >= :previousFinancialYearStart)))];
             
             /*
              * Only BSP auth exist then Order.Payment_Type__c = 'BSP'
              * Only BSP auth exist then Order.Payment_Type__c = 'BSP'
              * Both TSP and BSP exist then Order.Payment_Type__c = 'TSP and BSP'
              */ 
             for(Authorisation__c auth : auths) {
             
                 Order payment = accountIdVsOrder.get(auth.Service_Provider__c);
                 
                 if(payment.Payment_Type__c != null && payment.Payment_Type__c != auth.Authorisation_Type__c) {
                     
                     payment.Payment_Type__c = 'TSP and BSP';
                 } else {
                     payment.Payment_Type__c = auth.Authorisation_Type__c;
                 }
                     
             }
          }
     }
}