/*******************************************************************************************
* Author:         Abhi Indulkar
* Company:        Transport for NSW
* Description:    Helper class for Case Trigger utilities
*
* Test Class:   CaseTriggerHelperTest
* History
* <Date>      <Authors Name>      <Brief Description of Change>
* 21/08/2018  Abhi Indulkar       Created
*******************************************************************************************/

public without sharing class CaseTriggerHelper {
    public final static String CASE_RECORDTYPE_DEVNAME_ICC_ESCALATION = 'ICC_Escalation';
    public final static String CASE_RECORDTYPE_NAME_ENQUIRY = 'Enquiry';
    public final static String CASE_RECORDTYPE_DEVNAME_ENQUIRY = 'Enquiry';
    
    public static Map<Id, Group> mAllQueues = new Map<Id, Group> ();
    
    //P2PSUPPORT-121
    //Method to update Case Record Type
    public static void changeCaseRecordType(Map<Id, Case> pNewCases, Map<Id, Case> pOldCases) {
        
        //1. Change Case record Type to 'Enquiry', if ICC Escalation Case is assigned to new Compliance Queue
        Id enquiryCaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CASE_RECORDTYPE_NAME_ENQUIRY).getRecordTypeId();
        
        for (Case c : pNewCases.values()) {
            //Update only ICC Escalation Cases where owner changed to 'Compliance' Queue
            if (c.Record_Type_Dev_Name__c == CASE_RECORDTYPE_DEVNAME_ICC_ESCALATION
                && getQueueById(c.OwnerId) != null
                && getQueueById(c.OwnerId).DeveloperName == Label.Queue_DeveloperName_Compliance)
            {
                //Update Enquiry RecordType Id on Case. Before trigger context will facilitate update
                c.RecordTypeId = enquiryCaseRecordTypeId;
            }
        }
    }
    
    /**
* @author      Abhi Indulkar
* @date        07/08/2018
* @description	Retriev Queue By queue Id
*
* @param       Id QueueId
* @return      Group (Queue)
* @example     getQueueById(pQueueId)
*   
**/
    private static Group getQueueById(Id pQueueId)
    {
        if (mAllQueues.isEmpty()) {
            //populate map of Queues by QueueId
            mAllQueues = new Map<Id, Group> ([SELECT
                                              Id,
                                              DeveloperName
                                              FROM Group
                                              WHERE Type = 'Queue']);
        }
        
        return mAllQueues.get(pQueueId);
    }
    
    //Method to check if all Notice Records are closed for the Case
    public static void checkCaseRelatedNoticeClosed(Map<id,Case> pNewCases, Map<Id,Case> pOldCases){
        
        User LoggedInUeser = GlobalUtility.getLoggedInUser();
        Profile SysProfile = GlobalUtility.getSysAdminProfile();
        
        
        if(LoggedInUeser.Profile.Name == SysProfile.Name){
            //Allow System admin to close Case without checking for Notice Close Status
            System.debug('Sys admin user');
            return;
        } else {         
            try{  
                //Check if all the Notice Records related to the Case are Closed / Cancelled
                Set<String> allowedCaseTypes = GlobalConstants.COMPLIANCE_Case_RECORD_TYPE;
                Set<String> noticeClosedStatus = GlobalConstants.NOTICE_CLOSED_STATUS;
                List<String> caseIdList = new List<String>();
                Map<Id,List<Notice_Record__c>> caseIdVsNoticeRecordMap = new Map<Id,List<Notice_Record__c>>();
                Map<Id,Case> caseIdErrorMap = new Map<Id,Case>();
                
                for(Case c : pNewCases.values()){
                    System.debug('Record Type:'+c.Record_Type_Dev_Name__c);
                    System.debug('Current Status '+c.Status);
                    System.debug('Old Status '+pOldCases.get(c.Id).Status);
                    if(allowedCaseTypes.contains(c.Record_Type_Dev_Name__c) && c.Status != pOldCases.get(c.Id).Status && c.Status == 'Closed' &&  c.Sub_Status__c=='Completed'){
                        System.debug('True');
                        caseIdList.add(c.Id);
                    } else {
                        System.debug('False');
                    }
                }
                
                if(caseIdList.size()>0){
                    for(Notice_Record__c notice : [SELECT Id, Case__c, Status__c 
                                                   FROM Notice_Record__c
                                                   WHERE Case__c IN :caseIdList
                                                   AND Status__c NOT IN :noticeClosedStatus
                                                  ]){
                                                      System.debug('notice:'+notice);  
                                                      if(caseIdVsNoticeRecordMap.containsKey(notice.Case__c)){
                                                          caseIdVsNoticeRecordMap.get(notice.Case__c).add(notice);
                                                      } else{
                                                          caseIdVsNoticeRecordMap.put(notice.Case__c,new List<Notice_Record__c>{notice}); 
                                                      }
                                                  }
                    
                    if(caseIdVsNoticeRecordMap.size()>0){
                        for(Id caseNoticeOpen :caseIdVsNoticeRecordMap.keySet()){
                            // pNewCases.get(caseNoticeOpen).addError('Cannot close the case as one or more Notice records are still open');
                            Case thisCase =  pNewCases.get(caseNoticeOpen);
                            thisCase.addError('Can not close the case as one or more Notice records are still open');
                            caseIdErrorMap.put(caseNoticeOpen,thisCase);
                        }
                    }
                    
                }
            }catch (Exception ex) {
                //Insert Application Log
                ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'CaseTriggerHelper', 'checkCaseRelatedNoticeClosed', ex.getMessage(), null, ex, null, null, null, null);
            }
        }
    }
}