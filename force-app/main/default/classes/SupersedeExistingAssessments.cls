/* Class to supersede existing assessments when new assessment of
*  type "Reassessment" or "Reassessment-Compromised" is created for same period 
*/
public class SupersedeExistingAssessments {
    
    @InvocableMethod(label='Supersede Existing Assessments' description='Supersede existing assessments when new assessment of type "Reassessment" or "Reassessment-Compromised" is created for same period')
    public static List<Assessment__c> supersedeExistingAssessments(List<Assessment__c> newAssessments) {
        
        Map<Id, Assessment__c> levyRegistrationIdsVsAssessments = new Map<Id, Assessment__c>();
        List<Assessment__c> assessmentsToSupersede = new List<Assessment__c>();
        
        //create map of registrationId vs related assessment
        for(Assessment__c tempNewAssessment : newAssessments) {
            levyRegistrationIdsVsAssessments.put(tempNewAssessment.Taxpayer_Registration__c, tempNewAssessment);
        }
        
        //superseding existing assessment which belong to same period
        for(Assessment__c tempExistingAssessment : [SELECT Period_Start_Date__c, Period_End_Date__c, 
                                                    Taxpayer_Registration__c, Status__c
                                                    FROM Assessment__c
                                                    WHERE Taxpayer_Registration__c IN :levyRegistrationIdsVsAssessments.keySet()
                                                    AND Status__c != :GlobalConstants.STATUS_SUPERSEDED]) 
        {
            
            Assessment__c tempNewAssessment = levyRegistrationIdsVsAssessments.get(tempExistingAssessment.Taxpayer_Registration__c);
            
            //validate if existing assessment belong to same period as that of new assessment of type "Reassessment" or "Reassessment-Compromised
            if(tempExistingAssessment.Period_Start_Date__c == tempNewAssessment.Period_Start_Date__c
               && tempExistingAssessment.Period_End_Date__c == tempNewAssessment.Period_End_Date__c) {
                   
                   // we dont want to change status of new assessment
                   if(tempExistingAssessment.Id == tempNewAssessment.Id) {
                       continue;
                   }
                   
                   tempExistingAssessment.Status__c = GlobalConstants.STATUS_SUPERSEDED;
                   assessmentsToSupersede.add(tempExistingAssessment);
               }                                         
        }
        
        if(assessmentsToSupersede.size() > 0)
            Database.update(assessmentsToSupersede, FALSE);
        
        return NULL;
    }
}