public without sharing class CaseLegislationController {
    
    @AuraEnabled
    public static List<Case_Legislative_Reference__c> loadCaseLegislation(Id caseId){
        system.debug('Load Case Legislation called');
        return ([SELECT Id, Name, Case__c, Legislation__c,Legislation__r.Legislation_Name__c,Legislation__r.Description__c, Legislation__r.Schedule_Section_Clause_Rule__c, Legislation__r.Sub_Section_Clause__c, Reason_for_Change__c, Primary__c, Comment__c, Status__c 
                 FROM Case_Legislative_Reference__c 
                 WHERE Status__c = :GlobalConstants.ACTIVE_CONTACT_STATUS AND Case__r.Id = :caseId]);
    }
    
    @AuraEnabled
    public static Boolean valdiateIfRelatedNoticeSent(Id caseLegId){
        List<String> invalidStatus = new List<String>{'Draft','Cancelled'};
            if(caseLegId!=null){
                integer count= database.countQuery('SELECT count() FROM Notice_Legislative_Reference__c WHERE Case_Legislative_Reference__c=\''+ caseLegId + '\' AND Notice_Record__r.Status__c NOT IN :invalidStatus AND Status__c = \'Active\'');
                if(count>0){
                    return true;
                }else{
                    return false;
                }
            }else{
                return false;
            }    
    }    
    
    @AuraEnabled
    public static List<String> getPickListValuesIntoList(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Case_Legislative_Reference__c.Reason_for_Change__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    @AuraEnabled
    public static void saveCaseLegislation(String caseLegislation){
        List<Notice_Legislative_Reference__c> updatedNoticeLR = new List<Notice_Legislative_Reference__c>();
        system.debug('caseLegislation:'+caseLegislation);
        List<Case_Legislative_Reference__c> caseLeg = (List<Case_Legislative_Reference__c>) JSON.deserialize(caseLegislation, List<Case_Legislative_Reference__c>.class);
        
        try{
            if(caseLeg.size()>0){
                upsert caseLeg;
                System.debug('updated caseLeg:'+caseLeg[0]);
                //For CLR that are getting Inactive make there corresponding NLR Inactive
                if(caseLeg[0].Status__c=='Inactive'){                   
                    List<Notice_Legislative_Reference__c> noticeLeg = [SELECT Id, Name, Notice_Record__c, Status__c, Legislation__c 
                                                                       FROM Notice_Legislative_Reference__c 
                                                                       WHERE Notice_Record__r.Case__c =: caseLeg[0].Case__c AND Legislation__c =: caseLeg[0].Legislation__c AND Status__c = 'Active'];
                    
                    System.debug('noticeLeg: '+noticeLeg);
                    for(Notice_Legislative_Reference__c nLR :noticeLeg ){
                        nLR.Status__c = 'Inactive';
                        nlR.Reason_for_Change__c = caseLeg[0].Reason_for_Change__c;
                        updatedNoticeLR.add(nlR);
                    }
                    if(updatedNoticeLR.size()>0){
                        update updatedNoticeLR;
                    }
                    
                }
            } 
        } catch (exception ex){
            System.debug('Exception :'+ex.getMessage());
        }
        
    }
}