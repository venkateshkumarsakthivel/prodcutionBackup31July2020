/**
 * This class populated authorisation number
 */
public class NoticeRecordAuthNumberFieldUpdater {
    
    private List<Notice_Record__c> newNoticeRecords;
    
    public NoticeRecordAuthNumberFieldUpdater(List<Notice_Record__c> newNoticeRecords){
        
        this.newNoticeRecords = newNoticeRecords;
    }
    
    public void updateAuthNumbersField() {    
        
        try {
            Set<String> aspAuthorisationTypes = new Set<String>();
            aspAuthorisationTypes.add(GlobalConstants.AUTHORISATION_TYPE_TSP);
            aspAuthorisationTypes.add(GlobalConstants.AUTHORISATION_TYPE_BSP);
            
            Set<String> grantedStatusValueSet = new Set<String>();
            grantedStatusValueSet.add(GlobalConstants.GRANTED_UNCONDITIONALLY);
            grantedStatusValueSet.add(GlobalConstants.GRANTED_CONDITIONALLY);
            grantedStatusValueSet.add(GlobalConstants.AUTHORISATION_SUSPENDED);
            
            Set<String> targetAccountIds = new Set<String>();
            Map<Id, Notice_Record__c> accountIdVSNoticeRecord = new Map<Id, Notice_Record__c>();
            for(Notice_Record__c noticeRecord : newNoticeRecords) {
                
                if(noticeRecord.Issued_To__c != NULL) {
                    targetAccountIds.add(noticeRecord.Issued_To__c);
                    accountIdVSNoticeRecord.put(noticeRecord.Issued_To__c, noticeRecord);
                }
            }
            
            Map<Id, List<Authorisation__c>> mapAccountIdVSAuthorisations = new Map<Id, List<Authorisation__c>>();
            
            for(Authorisation__c tempAuth : [SELECT Id, Name, Authorisation_Type__c, Status__c, Service_Provider__c
                                             FROM Authorisation__c
                                             WHERE Service_Provider__c IN :targetAccountIds
                                             AND Status__c IN :grantedStatusValueSet
                                             AND Authorisation_Type__c IN : aspAuthorisationTypes]) {
                                                 
                                                 if(mapAccountIdVSAuthorisations.containsKey(tempAuth.Service_Provider__c)) {
                                                     mapAccountIdVSAuthorisations.get(tempAuth.Service_Provider__c).add(tempAuth);
                                                 } else {
                                                     mapAccountIdVSAuthorisations.put(tempAuth.Service_Provider__c, new List<Authorisation__c>{tempAuth});
                                                 }
                                             }
            
            for (Id accountId : mapAccountIdVSAuthorisations.keySet()) {

                List<Authorisation__c> listAuths = mapAccountIdVSAuthorisations.get(accountId);
                
                String tempAuthNames = '';
                Set<String> authNames = new Set<String>(); 
                
                for(Authorisation__c tempAuth : listAuths) {
                    
                    if(!authNames.contains(tempAuth.Name)) {
                        
                        authNames.add(tempAuth.Name);
                        
                        if(tempAuthNames != '') {
                            tempAuthNames += ' and ';
                        }
                        
                        tempAuthNames += tempAuth.Name;
                    }
                }
                
                Notice_Record__c noticeRecord = accountIdVSNoticeRecord.get(accountId);
                noticeRecord.Authorisation_Numbers__c = tempAuthNames;
            }
            
        }
        catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'NoticeRecordAuthNumberFieldUpdater','updateAuthNumbersField',ex.getMessage(),ex);                        
        }
    } 
}