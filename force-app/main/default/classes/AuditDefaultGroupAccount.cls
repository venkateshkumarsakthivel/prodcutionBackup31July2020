/*
* Helper class to populate Audit Vendor/Group on Audit Case on Update of Audit case
* if Audit Vendor/Group in blank before update
*/

public class AuditDefaultGroupAccount {
    
    private List<Case> checkAuditCases;
    
    
    public AuditDefaultGroupAccount(List<Case> checkAuditCases){
        
        this.checkAuditCases = checkAuditCases;
    }
    
    public void postAuditCaseCreationUpdateVendorGroup() {
        System.debug('Method Called');
        try{ 
            List<Account> defaultAuditVendorGroupId = [Select Id, Name, CreatedDate from Account where Record_Type_Dev_Name__c =: GlobalConstants.ACCOUNT_RECORDTYPE_DEV_NAME_AUDIT_VENDOR
                                                       and Auditor_Type__c =: GlobalConstants.AUDITOR_TYPE_INTERNAL and Auditor_Status__c =: GlobalConstants.AUDITOR_STATUS_ACTIVE ORDER BY CreatedDate ASC LIMIT 1]; 
            
           // List<Case> updateAuditCases = new List<Case>();
            
            
            if(defaultAuditVendorGroupId.size() != 0){
                for(Case tempCase : checkAuditCases){
                    if(tempCase.Record_Type_Dev_Name__c == GlobalConstants.CASE_RECORDTYPE_DEV_NAME_AUDIT && tempcase.Audit_Vendor__c == NULL){
                        tempCase.Audit_Vendor__c = defaultAuditVendorGroupId[0].Id;
                       // updateAuditCases.add(tempCase);
                        
                    }
                }
                for(integer i = 0; i <checkAuditCases.size(); i++){
                    System.debug('Case updated:'+checkAuditCases[i]);
                }
                
              // update updateAuditCases;
                                 
            }
        }
        catch(Exception ex){
             ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'AuditDefaultGroupAccount','postAuditCaseCreationVendorGroupx',ex.getMessage(),ex);
        }
    }
    
    
}