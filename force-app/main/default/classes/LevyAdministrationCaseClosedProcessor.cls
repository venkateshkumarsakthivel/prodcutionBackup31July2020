/*
 * Helper class to detect if levy administration case 
 * is approved or rejected and then accordingly perform
 * post approval/rejection steps
 */
public with sharing class LevyAdministrationCaseClosedProcessor {

    private Map<Id, Case> newApplications;
    private Map<Id, Case> oldApplications;
    
    public BusinessHours businessHours = [SELECT Id FROM BusinessHours WHERE isDefault = true];
    
    public LevyAdministrationCaseClosedProcessor(Map<Id, Case> newApplications, Map<Id, Case> oldApplications){
    
        this.newApplications = newApplications;
        this.oldApplications = oldApplications;
    }
    
    public void processClosedLevyCases() {    
    
        try {
              
                List<Assessment__c> assessmentsToInsert = new List<Assessment__c>();
                List<Assessment__c> assessmentsToUpdate = new List<Assessment__c>();
                List<Assessment__c> assessmentsToSupersede = new List<Assessment__c>();

                Set<String> validLevyAssessmentSubTypes = new Set<String>();
                validLevyAssessmentSubTypes.add(GlobalConstants.CASE_SUB_TYPE_ASSESSMENT_OTHER);
                validLevyAssessmentSubTypes.add(GlobalConstants.CASE_SUB_TYPE_ASSESSMENT_AUDIT_AND_COMPLIANCE);
                validLevyAssessmentSubTypes.add(GlobalConstants.CASE_SUB_TYPE_REASSESSMENT_OTHER);
                validLevyAssessmentSubTypes.add(GlobalConstants.CASE_SUB_TYPE_REASSESSMENT_AUDIT_AND_COMPLIANCE);

                Set<String> validLevyObjectionSubTypes = new Set<String>();
                validLevyObjectionSubTypes.add(GlobalConstants.LEVY_OBJECTION_CASE_SUB_TYPE);

                Set<String> relatedAssessmentTargetStatus = new Set<String>();
                relatedAssessmentTargetStatus.add(GlobalConstants.Assessment_STATUS_Closed);
                relatedAssessmentTargetStatus.add(GlobalConstants.Assessment_STATUS_ERROR);
                relatedAssessmentTargetStatus.add(GlobalConstants.Assessment_STATUS_OUTSTANDING);
                relatedAssessmentTargetStatus.add(GlobalConstants.Assessment_STATUS_SUBMITTED);
              
                for(Case tempCase : newApplications.values()) {
                
                    //case for initial assessment/reassessment/objection is approved
                    if((tempCase.Record_Type_Dev_Name__c == GlobalConstants.Levy_Administration_CASE_RECORD_TYPE_DEV_NAME
                         || tempCase.Record_Type_Dev_Name__c == GlobalConstants.Levy_OBJECTION_CASE_RECORD_TYPE_DEV_NAME)
                       && tempCase.Type == GlobalConstants.CASE_TYPE_PASSENGER_SERVICE_LEVY
                       && (validLevyAssessmentSubTypes.contains(tempCase.Sub_Type__c) || validLevyObjectionSubTypes.contains(tempCase.Sub_Type__c))
                       && tempCase.Status == GlobalConstants.CLOSED_CASE_STATUS
                       && tempCase.Sub_Status__c == GlobalConstants.APPROVED_CASE_SUB_STATUS) {
                       
                        Assessment__c tempAssessment;
                          
                        if(tempCase.Sub_Type__c == GlobalConstants.CASE_SUB_TYPE_ASSESSMENT_OTHER
                              || tempCase.Sub_Type__c == GlobalConstants.CASE_SUB_TYPE_ASSESSMENT_AUDIT_AND_COMPLIANCE){
                                tempAssessment = new Assessment__c(); 
                        } else if(tempCase.Sub_Type__c == GlobalConstants.CASE_SUB_TYPE_REASSESSMENT_OTHER
                                  || tempCase.Sub_Type__c == GlobalConstants.CASE_SUB_TYPE_REASSESSMENT_AUDIT_AND_COMPLIANCE
                                  || tempCase.Sub_Type__c == GlobalConstants.LEVY_OBJECTION_CASE_SUB_TYPE){
                           
                            String soql = GlobalUtility.getCreatableFieldsSOQL('Assessment__c','id=\''+tempCase.Assessment__c+'\'');    
                            Assessment__c tempAssessmentToSupersede = (Assessment__c)Database.query(soql);

                            tempAssessment = tempAssessmentToSupersede.clone(false, true, false, false);
                            tempAssessment.Result_of_Objection__c = false;
                            tempAssessment.Revenue_Response_Message__c = '';
                            tempAssessment.Revenue_Response_Type__c = '';
                            tempAssessment.Revenue_Assessment_Number_TSP__c = '';
                            tempAssessment.Revenue_Assessment_Number_BSP__c = '';
                            tempAssessment.Is_Closed__c = FALSE;
                            tempAssessment.Related_Assessment__c = tempAssessmentToSupersede.Id;

                            //supesede related existing assessment
                            tempAssessmentToSupersede.Status__c = GlobalConstants.ASSESSMENT_STATUS_SUPERSEDED; 
                            
                            assessmentsToSupersede.add(tempAssessmentToSupersede);
                        }
                          
                        tempAssessment.Account__c = tempCase.AccountId;
                        tempAssessment.Levy_Contact__c = tempCase.ContactId;
                        tempAssessment.BSP_Transaction_Count__c = tempCase.BSP_Trip_Count__c;
                        tempAssessment.TSP_Transaction_Count__c = tempCase.TSP_Trip_Count__c;
                        tempAssessment.Period_Start_Date__c = tempCase.Assessment_Start_Date__c;
                        tempAssessment.Period_End_Date__c = tempCase.Assessment_End_Date__c;
                        tempAssessment.Status__c = GlobalConstants.ASSESSMENT_STATUS_ASSESSED;
                        tempAssessment.Taxpayer_Registration__c = tempCase.Tax_Payer_Registration__c;
                        tempAssessment.Levy_Calculation_Method__c = GlobalConstants.LEVY_CALCULATION_METHOD_ASSESSED_MANUALLY;
                      
                        Date currentMonthPaymentDueDate = checkBusinessDay(Date.newInstance(System.Today().Year(), System.Today().Month(), 26));
                        Date currentMonthIssueDate = currentMonthPaymentDueDate.addDays(-14);
                      
                        if((tempCase.Sub_Type__c == GlobalConstants.CASE_SUB_TYPE_ASSESSMENT_OTHER
                          || tempCase.Sub_Type__c == GlobalConstants.CASE_SUB_TYPE_ASSESSMENT_AUDIT_AND_COMPLIANCE)) {
                        
                            if(tempCase.Compromise_Assessment__c == GlobalConstants.YES_VALUE) {
                                tempAssessment.Assessment_Type__c = GlobalConstants.ASSESSMENT_TYPE_ASSESSMENT_COMPROMISED;   
                            } else {
                                tempAssessment.Assessment_Type__c = GlobalConstants.ASSESSMENT_TYPE_ASSESSMENT;  
                            } 
                            tempAssessment.Payment_via_Sweep__c = TRUE;
                            tempAssessment.Payment_Due_Date__c = System.Today() < currentMonthIssueDate ? checkBusinessDay(Date.newInstance(System.Today().Year(), System.Today().Month(), 26)) : checkBusinessDay(Date.newInstance(System.Today().Year(), System.Today().addMonths(1).Month(), 26));   
                            tempAssessment.Issue_Date__c = tempAssessment.Payment_Due_Date__c.addDays(-14);
                        }
                          
                        //calculate payment due date as 26th or next business day of current month
                        //for reassessments with status not as 'Closed', 'Submitted',
                        //'Outstanding' or 'Error'
                        if(tempCase.Sub_Type__c == GlobalConstants.CASE_SUB_TYPE_REASSESSMENT_OTHER
                               || tempCase.Sub_Type__c == GlobalConstants.CASE_SUB_TYPE_REASSESSMENT_AUDIT_AND_COMPLIANCE
                               || tempCase.Sub_Type__c == GlobalConstants.LEVY_OBJECTION_CASE_SUB_TYPE) {
                            

                            if(tempCase.Compromise_Assessment__c == GlobalConstants.YES_VALUE) {
                              tempAssessment.Assessment_Type__c = GlobalConstants.ASSESSMENT_TYPE_REASSESSMENT_COMPROMISED;
                              tempAssessment.Reason__c = tempCase.Notice_Text_Verbatim__c;                                        
                            } else {
                              tempAssessment.Assessment_Type__c = GlobalConstants.ASSESSMENT_TYPE_REASSESSMENT;
                            }
                            
                            //P2PSUPPORT-170 : Issue date/Payment Due date calculation changed - Start
                            if(String.isBlank(tempCase.Revenue_Assessment_Number_BSP__c) && String.isBlank(tempCase.Revenue_Assessment_Number_TSP__c)) {
                                Date currentMonthRevenueSubmitDate = Date.newInstance(System.Today().Year(), System.Today().Month(), 21);
                                
                                tempAssessment.Payment_via_Sweep__c = TRUE;
                                //tempAssessment.Payment_Due_Date__c = System.Today() < currentMonthIssueDate ? checkBusinessDay(Date.newInstance(System.Today().Year(), System.Today().Month(), 26)) : checkBusinessDay(Date.newInstance(System.Today().Year(), System.Today().addMonths(1).Month(), 26));   
                                //tempAssessment.Payment_Due_Date__c = tempCase.Assessment_Payment_Due_Date__c;
                                tempAssessment.Payment_Due_Date__c = System.Today() < currentMonthRevenueSubmitDate ? checkBusinessDay(Date.newInstance(System.Today().Year(), System.Today().Month(), 26)) : checkBusinessDay(Date.newInstance(System.Today().Year(), System.Today().addMonths(1).Month(), 26));   
                                tempAssessment.Issue_Date__c = tempCase.Assessment_Issue_Date__c; //This will be overwritten by workflow - Conga: Notice of Reasessments to today
                                tempAssessment.Status__c = GlobalConstants.ASSESSMENT_STATUS_ISSUED; 
                            } else {
                             
                                tempAssessment.Payment_via_Sweep__c = FALSE;
                                tempAssessment.Payment_Due_Date__c = System.Today().addDays(7);
                                //tempAssessment.Issue_Date__c = tempAssessment.Payment_Due_Date__c.addDays(-14);
                                tempAssessment.Issue_Date__c = System.today();
                            }
                            //P2PSUPPORT-170 - End
                        }
                    if(tempCase.Estimation_Assessment__c == 'Yes') {
                        tempAssessment.Levy_Calculation_Method__c = 'Estimated Manually';
                    } else {
                        tempAssessment.Levy_Calculation_Method__c = 'Assessed Manually';
                    }
                    tempAssessment.Estimate_Reason_Code__c = tempCase.Estimate_Reason_Code__c;
                    if(tempCase.Sub_Type__c == GlobalConstants.LEVY_OBJECTION_CASE_SUB_TYPE){
                        tempAssessment.Result_of_Objection__c = TRUE;
                    }
                    assessmentsToInsert.add(tempAssessment);
                } else if((tempCase.Record_Type_Dev_Name__c == GlobalConstants.Levy_Administration_CASE_RECORD_TYPE_DEV_NAME
                         || tempCase.Record_Type_Dev_Name__c == GlobalConstants.Levy_OBJECTION_CASE_RECORD_TYPE_DEV_NAME)
                       && tempCase.Type == GlobalConstants.CASE_TYPE_PASSENGER_SERVICE_LEVY
                       && (tempCase.Sub_Type__c == GlobalConstants.CASE_SUBTYPE_HELD_ASSESSMENT)
                       && tempCase.Status == GlobalConstants.CLOSED_CASE_STATUS
                       && tempCase.Sub_Status__c == GlobalConstants.APPROVED_CASE_SUB_STATUS) {
                        // for Held Assessment
                    String soql = GlobalUtility.getCreatableFieldsSOQL('Assessment__c','id=\''+tempCase.Assessment__c+'\'');    
                    Assessment__c tempAssessment = (Assessment__c)Database.query(soql);
                    tempAssessment.Result_of_Objection__c = false;
                    if(tempCase.Compromise_Assessment__c == GlobalConstants.YES_VALUE) {
                        tempAssessment.Assessment_Type__c = GlobalConstants.ASSESSMENT_TYPE_ASSESSMENT_COMPROMISED;
                    }
                    if(tempCase.Estimation_Assessment__c == 'Yes') {
                        tempAssessment.Levy_Calculation_Method__c = 'Estimated Manually';
                        tempAssessment.Estimate_Reason_Code__c = tempCase.Estimate_Reason_Code__c;
                    } else {
                        tempAssessment.Levy_Calculation_Method__c = 'Assessed Manually';
                    }
                     
                    tempAssessment.Status__c = GlobalConstants.ASSESSMENT_STATUS_ASSESSED;
                    tempAssessment.BSP_Transaction_Count__c = tempCase.BSP_Trip_Count__c;
                    tempAssessment.TSP_Transaction_Count__c = tempCase.TSP_Trip_Count__c;
                    tempAssessment.Change_Code__c = tempCase.Change_Code__c;
                    tempAssessment.Change_Comment__c = tempCase.Change_Comment__c;
                    assessmentsToUpdate.add(tempAssessment);                    
                } else if((tempCase.Record_Type_Dev_Name__c == GlobalConstants.Levy_Administration_CASE_RECORD_TYPE_DEV_NAME
                         || tempCase.Record_Type_Dev_Name__c == GlobalConstants.Levy_OBJECTION_CASE_RECORD_TYPE_DEV_NAME)
                       && tempCase.Type == GlobalConstants.CASE_TYPE_PASSENGER_SERVICE_LEVY
                       && (tempCase.Sub_Type__c == GlobalConstants.CASE_SUBTYPE_HELD_ASSESSMENT)
                       && tempCase.Status == GlobalConstants.CLOSED_CASE_STATUS
                       && tempCase.Sub_Status__c == GlobalConstants.DECLINED_CASE_SUB_STATUS) {
                    String soql = GlobalUtility.getCreatableFieldsSOQL('Assessment__c','id=\''+tempCase.Assessment__c+'\'');    
                    Assessment__c tempAssessment = (Assessment__c)Database.query(soql);
                    tempAssessment.Status__c = GlobalConstants.ASSESSMENT_STATUS_ASSESSED;
                    tempAssessment.Change_Code__c = GlobalConstants.ASSESSMENT_NO_CHANGE_REQUIRED;
                    tempAssessment.Change_Comment__c = GlobalConstants.ASSESSMENT_NO_CHANGE_REQUIRED;
                    assessmentsToUpdate.add(tempAssessment);   
                }
            }
              
            if(!assessmentsToUpdate.IsEmpty()){
                AssessmentLevyAmountCalculator.calculate(assessmentsToUpdate , false);
                update assessmentsToUpdate;
            }
            
            if(assessmentsToSupersede.size() > 0)
                update assessmentsToSupersede;
                 
            if(assessmentsToInsert.size() > 0)
                insert assessmentsToInsert;
        } catch(Exception ex) {
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR,'LevyAdministrationCaseClosedProcessor','processClosedLevyCases',ex.getMessage(),ex);                        
        }
    }
    
    //Check if parameter date is business day else return next business day
    public Date checkBusinessDay(Date paymentDueDate) {
        
        boolean isInBusinessHours = GlobalUtility.isInBusinessHours(businessHours, paymentDueDate);
        
        if(isInBusinessHours) {
            return paymentDueDate;
        } else {
            paymentDueDate = paymentDueDate.addDays(1);
            return checkBusinessDay(paymentDueDate);
        }
    }
}