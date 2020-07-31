/*
* Class to auto populate Assessment record data 
* from tax payer registration on creation of assessment of type 'Assessment'
*/
public with sharing class AssessmentInitialiser {
    
    public void initialiseAssessmentFromTPR(List<Assessment__c> newAssessments) {
        
        try {
            
            Date firstDateOfPreviousMonth = System.today().addMonths(-1).toStartOfMonth();
            Map<Id, Tax_Payer_Registration__c> idVsTPRMap = new Map<Id, Tax_Payer_Registration__c>();
            Set<Id> targetTPRIds = new Set<Id>();
            
            for(Assessment__c tempAssessment : newAssessments) {
                
                if(String.isNotBlank(tempAssessment.Taxpayer_Registration__c))
                    targetTPRIds.add(tempAssessment.Taxpayer_Registration__c);
            }
            
            for(Tax_Payer_Registration__c tempTPR : [SELECT Annual_Trip_Estimate__c, Booking_Service_Provider_Number__c, Taxi_Service_Provider_Number__c,
                                                     Booking_Service_Provider_Number__r.Status__c, Booking_Service_Provider_Number__r.Decision_Date__c,
                                                     Booking_Service_Provider_Number__r.Start_Date__c, Booking_Service_Provider_Number__r.End_Date__c,
                                                     Taxi_Service_Provider_Number__r.Status__c, Taxi_Service_Provider_Number__r.Decision_Date__c,
                                                     Taxi_Service_Provider_Number__r.Start_Date__c, Taxi_Service_Provider_Number__r.End_Date__c,
                                                     Rebate_Approved__c, Exemption_Approved__c,
                                                     Levy_Contact__c, Rebate_Approval_Date__c,
                                                     Exemption_Reason__c, Rebate_Reason__c,
                                                     Exemption_Comment__c, Rebate_Comment__c,
                                                     Estimated_TSP_Transactions__c, Estimated_BSP_Transactions__c
                                                     FROM Tax_Payer_Registration__c 
                                                     WHERE Id IN :targetTPRIds]) {
                                                         
                                                         idVsTPRMap.put(tempTPR.Id, tempTPR);
                                                     }
            
            for(Assessment__c assessmentToUpdate : newAssessments) {
                
                if((assessmentToUpdate.Assessment_Type__c == GlobalConstants.ASSESSMENT_TYPE_ASSESSMENT || assessmentToUpdate.Assessment_Type__c == GlobalConstants.ASSESSMENT_TYPE_ASSESSMENT_COMPROMISED)
                   && String.isNotBlank(assessmentToUpdate.Taxpayer_Registration__c)) {
                       
                       Tax_Payer_Registration__c relatedTPR = idVsTPRMap.get(assessmentToUpdate.Taxpayer_Registration__c);
                       
                       assessmentToUpdate.Annual_Estimates__c = relatedTPR.Annual_Trip_Estimate__c; 
                       //assessmentToUpdate.Change_Code__c = relatedTPR.Exemption_Approved__c ? relatedTPR.Exemption_Reason__c : (relatedTPR.Rebate_Approved__c ? relatedTPR.Rebate_Reason__c : '');
                       assessmentToUpdate.Change_Comment__c = relatedTPR.Exemption_Approved__c ? relatedTPR.Exemption_Comment__c : (relatedTPR.Rebate_Approved__c ? relatedTPR.Rebate_Comment__c: '');   
                       assessmentToUpdate.Rebate_Approved__c = relatedTPR.Rebate_Approved__c;
                       assessmentToUpdate.Exemption_Approved__c = relatedTPR.Exemption_Approved__c;
                       assessmentToUpdate.Levy_Contact__c = relatedTPR.Levy_Contact__c;
                       assessmentToUpdate.Levy__c = Decimal.valueOf(System.Label.Levy_Amount_Per_Trip);
                       assessmentToUpdate.Rebate_Approval_Date__c = relatedTPR.Rebate_Approval_Date__c;
                       assessmentToUpdate.Payment_via_Sweep__c = true;
                       
                       /* Copy value from estimated BSP transactions on taxpayer registration if
                        * 1: Status of authorisation is either "Granted Unconditionally" or "Granted Conditionally" or "Suspended" or "Expired" or "Cancelled"
                        * 2: Start date of authorisation linked to taxpayer registration is in past.
                        * 3: End date of authorisation (if status is not cancelled) linked to taxpayer registration is greater than or equal to 1st of previous month (either in future or in previous month) 
                        *    or Decision Date on authorisation (if status is cancelled) is equal to or greater than 1st of previous month.
                        */
                       if(relatedTPR.Booking_Service_Provider_Number__c != NULL
                          && relatedTPR.Booking_Service_Provider_Number__r.Status__c == GlobalConstants.AUTHORISATION_STATUS_CANCELLED
                          && relatedTPR.Booking_Service_Provider_Number__r.Decision_Date__c >= firstDateOfPreviousMonth) {
                              
                              assessmentToUpdate.Estimated_BSP_Transactions__c = relatedTPR.Estimated_BSP_Transactions__c;    
                          }
                       else if(relatedTPR.Booking_Service_Provider_Number__c != NULL
                               && relatedTPR.Booking_Service_Provider_Number__r.Status__c != GlobalConstants.AUTHORISATION_STATUS_CANCELLED
                               && relatedTPR.Booking_Service_Provider_Number__r.Start_Date__c < Date.today()
                               && relatedTPR.Booking_Service_Provider_Number__r.End_Date__c >= firstDateOfPreviousMonth) {
                                   
                                   assessmentToUpdate.Estimated_BSP_Transactions__c = relatedTPR.Estimated_BSP_Transactions__c;    
                               }
                       
                       /* Copy value from estimated TSP transactions on taxpayer registration if
                        * 1: Status of authorisation is either "Granted Unconditionally" or "Granted Conditionally" or "Suspended" or "Expired" or "Cancelled"
                        * 2: Start date of authorisation linked to taxpayer registration is in past.
                        * 3: End date of authorisation (if status is not cancelled) linked to taxpayer registration is greater than or equal to 1st of previous month (either in future or in previous month) 
                        *    or Decision Date on authorisation (if status is cancelled) is equal to or greater than 1st of previous month.
                        */
                       if(relatedTPR.Taxi_Service_Provider_Number__c != NULL
                          && relatedTPR.Taxi_Service_Provider_Number__r.Status__c == GlobalConstants.AUTHORISATION_STATUS_CANCELLED
                          && relatedTPR.Taxi_Service_Provider_Number__r.Decision_Date__c >= firstDateOfPreviousMonth) {
                              
                              assessmentToUpdate.Estimated_TSP_Transactions__c = relatedTPR.Estimated_TSP_Transactions__c; 
                          }
                       else if(relatedTPR.Taxi_Service_Provider_Number__c != NULL
                               && relatedTPR.Taxi_Service_Provider_Number__r.Status__c != GlobalConstants.AUTHORISATION_STATUS_CANCELLED
                               && relatedTPR.Taxi_Service_Provider_Number__r.Start_Date__c < Date.today()
                               && relatedTPR.Taxi_Service_Provider_Number__r.End_Date__c >= firstDateOfPreviousMonth) {
                                   
                                   assessmentToUpdate.Estimated_TSP_Transactions__c = relatedTPR.Estimated_TSP_Transactions__c;     
                               }
                   }                     
            }
        }
        catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'AssessmentInitialiser','initialiseAssessmentFromTPR',ex.getMessage(),ex);
        }
    }
}