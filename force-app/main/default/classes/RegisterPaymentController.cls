public class RegisterPaymentController {
    
    @AuraEnabled
    public static String fetchHandOffURL(String paymentReference, String sfRecordId) {
        P2PQuickVaultPaymentFacade p2PQVPaymentFacade = new P2PQuickVaultPaymentFacade();
        Map<String, String> result = p2PQVPaymentFacade.securityToken(paymentReference, sfRecordId);
        String urlRet = result.get('redirectURL');
        System.debug('urlRet: '+urlRet);
        return urlRet;
    }
    
    @AuraEnabled
    public static boolean isExistingTransferApplicationOpen(String authorisationId) {
        
        try {
            
            Id transferRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName()
                .get(GlobalConstants.TAXI_TRANSFER_CASE_RECORD_TYPE_NAME).getRecordTypeId();
            
            List<Case> casesList = [SELECT Id, CaseNumber, Type, Sub_Type__c FROM Case 
                                    WHERE IsClosed = false 
                                    AND RecordTypeId =: transferRecordTypeId 
                                    AND Type =: GlobalConstants.SERVICE_TYPE_TAXI
                                    AND Sub_Type__c =: GlobalConstants.CASE_SUB_TYPE_TRANSFER_PROPOSED_OWNER
                                    AND Authorisation__c =: authorisationId];
            
            
            return !casesList.isEmpty();
        }
        catch(Exception e) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'RegisterPaymentController', 'isExistingTransferApplicationOpen', e.getMessage(), e);
            return null;
        }
    }
}