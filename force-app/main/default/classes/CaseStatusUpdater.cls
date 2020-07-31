/*
 * @Description: Helper class to change Case status
 */
public class CaseStatusUpdater {
    public static void changeCaseStatus(List<Task> tasklist){
        set<Id> caseIds = new Set<Id>();
        List<Case> casesToUpdate = new List<Case>();
        system.debug('In changeCaseStatus method');
        for(Task tsk: tasklist){
            if(tsk.Subject == 'Email: Notice of Tender Bid – Expired'){
                system.debug('In tasklist for loop');
                caseIds.add(tsk.WhatId);
                system.debug('==caseIds=='+caseIds);
            }
            if(caseIds.size()>0){
                system.debug('**caseIds**'+caseIds);
                
                /*Id taxiCorporationApplicationRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Taxi Corporation Application').getRecordTypeId();
                id taxiIndividualApplicationRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Taxi Individual Application').getRecordTypeId();
                id taxiJointHolderApplicationRecordType = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Taxi Joint Holder Application').getRecordTypeId();
                Set<Id> RecordTypeIds = new Set<Id>{taxiCorporationApplicationRecordType, taxiIndividualApplicationRecordType, taxiJointHolderApplicationRecordType};*/
                
                List<RecordType> recordTypelst = [SELECT Id from RecordType where DeveloperName In ('Taxi_Corporation_Application','Taxi_Joint_Holder_Application','Taxi_Individual_Application')];
                system.debug('recordTypelst' + recordTypelst);
                    
                    
                for(Case cs: [select id, status From Case where Id In : caseIds AND recordtypeId In : recordTypelst] ){
                    system.debug('In Case For loop');
                    if(cs.Status != 'Not Continued'){
                        system.debug('***cs.Status***'+cs.Status);
                        cs.Status = 'Not Continued';
                        casesToUpdate.add(cs);
                    }
                }
            } 
            if(casesToUpdate.size()>0){
                system.debug('***casesToUpdate***'+casesToUpdate);
                update casesToUpdate; 
            }
        }
    }

}