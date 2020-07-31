public with sharing class AuditNoticesConfiguration {
    
    public static List<Audit_Notice_Records_Config__mdt> auditNoticesConfigMDT;
    
    public static List<Audit_Notice_Records_Config__mdt> get()  {
        
        if(auditNoticesConfigMDT != null) {
            
            return auditNoticesConfigMDT;
            
        } else {
            
            auditNoticesConfigMDT = [SELECT Type__c, Sub_Type__c, Record_Type_Dev_Name__c, Record_Type_Id__c,
                           Description_Text_Block_1__c, Description_Text_Block_2__c, Description_Text_Block_3__c,
                           Legislation_Text_Block_1__c, Directions_Text_Block_1__c, Directions_Text_Block_2__c,
                           Recommendations_Text_Block_1__c
                           FROM Audit_Notice_Records_Config__mdt];
            
            return auditNoticesConfigMDT;
        }
        
    }
}