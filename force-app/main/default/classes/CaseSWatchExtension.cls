public with sharing class CaseSWatchExtension {

        private Case caseRec {get; set;}
        public Integer days {get; set;}
        public Boolean paused {get; set;}
        public DateTime pausedTimeStamp;
        public Integer pausedDays;
        public Boolean startTimer {get; set;}
        public Boolean stopTimer {get; set;}
        public Boolean permissionsAvailable {get; set;}
        public Boolean isLoadedFromCommunity{get;set;}
        
        /**
          Days contans the age of Case
        * Paused Days Contains the Days for which timer was Pause or resume
        * pausedTimeStamp Containd Date Time whenever timer is paused
        **/
            
        public CaseSWatchExtension(ApexPages.StandardController stdController) {
            stopTimer = false;
            permissionsAvailable = true;
            isLoadedFromCommunity = true;
            Schema.DescribeSObjectResult d = Case.sObjectType.getDescribe();                                              
            if (CheckUserPermission.checkObjectReadAccess(d) && CheckUserPermission.checkObjectUpdateAccess(d)) {
                
            
                List<Schema.DescribeFieldResult> fieldsDes = getFieldDes();                        
                List<Schema.DescribeFieldResult> readfieldsDes = new List<Schema.DescribeFieldResult>();
                readfieldsDes.addAll(fieldsDes);
                Schema.DescribeFieldResult CaseNumberDes = Case.CaseNumber.getDescribe();
                readfieldsDes.add(CaseNumberDes);
                
                if (CheckUserPermission.checkFieldsReadAccess(readfieldsDes) && CheckUserPermission.checkFieldsCreateAccess(fieldsDes)
                        && CheckUserPermission.checkFieldsUpdateAccess(fieldsDes)) {
                        
                    this.caseRec= (Case)stdController.getRecord();      //  not fethcing custom fields
                    List<Case> caseList = [SELECT id, CaseNumber, Stop_Timer__c,isPaused__c,Case_Paused_TimeStamp__c,status,
                                           Case_Paused_Days__c,Start_Timer__c,Case_Age__c FROM Case WHERE id = : caseRec.id LIMIT 1];
                    if (caseList != null && (!caseList.isEmpty())) { 
                        caseRec = caseList[0];
                        paused = caseRec.isPaused__c;
                        stopTimer = caseRec.Stop_Timer__c;
                        startTimer = caseRec.Start_Timer__c;
                        pausedTimeStamp = caseRec.Case_Paused_TimeStamp__c;
                        pausedDays = Integer.valueOf(caseRec.Case_Paused_Days__c);
                        days = Integer.valueOf(caseRec.Case_Age__c);
                        system.debug('pausedDays---------'+pausedDays);
                        system.debug('days---------'+days);
                        if(caseRec.status == 'New' || caseRec.status == 'Draft' || caseRec.status == 'Escalated'){
                            stopTimer = true;
                            days = 0;
                        }
                        System.debug('Case Record'+ caseRec);
                    }               
                } else {
                    permissionsAvailable = false;
                }                        
            } else {
                permissionsAvailable = false;
            }
            
            if (!permissionsAvailable) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access, Please contact System Administrator')); 
            } 
        }
      
        // Resume Timer Clock
        public PageReference resumeClock() {
            System.debug('In resume Clock');
            paused = false;
            DateTime resumeTime;
            resumeTime = System.now();
            Long resume = resumeTime.getTime();
            Long pause = pausedTimeStamp.getTime();
            Long milliseconds = resume - pause;
            Long seconds = milliseconds / 1000;
            Long minutes = seconds / 60;
            Long hours = minutes / 60;
            Long noOfDays = hours / 24;
            pausedDays += Integer.valueOf(noOfDays);
            system.debug('-----------'+pausedDays);
            saveCaseRecord();   
            return null;    
        }
    
        // Pause Timer Clock
        public PageReference pauseClock() {
            System.debug('In pause Clock');
            paused = true;
            pausedTimeStamp = System.now();
            saveCaseRecord();   
            return null;
        }
        
        // Save Records to the database when the clock is Paused Or Resumed
        private Boolean saveCaseRecord() {   
            caseRec.Case_Paused_TimeStamp__c = pausedTimeStamp;
            caseRec.Case_Paused_Days__c = pausedDays;
            caseRec.isPaused__c = paused;
            try {
                Schema.DescribeSObjectResult d = Case.sObjectType.getDescribe();                
                if (CheckUserPermission.checkObjectReadAccess(d) && CheckUserPermission.checkObjectUpdateAccess(d)) {
                    List<DescribeFieldResult> fieldsDes = getFieldDes();
                    if (CheckUserPermission.checkFieldsReadAccess(fieldsDes) && CheckUserPermission.checkFieldsCreateAccess(fieldsDes)
                        && CheckUserPermission.checkFieldsUpdateAccess(fieldsDes)) {
                            update(caseRec);
                            System.debug('#UPDATED RECORD:' + caseRec.CaseNumber);
                            System.debug('# Case Record'+ caseRec);
                        } else {
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access, Please contact System Administrator'));
                            return null;
                        }                                
                }
            }
            catch (Exception e) {
                System.debug('#EXCEPTION :' + e.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Error during update : ' +e.getMessage()));
            }  
           return true;
        }
        private List<Schema.DescribeFieldResult> getFieldDes() {
            List<Schema.DescribeFieldResult> fieldsDes = new List<Schema.DescribeFieldResult>();
            Schema.DescribeFieldResult CaseNumberDes = Case.CaseNumber.getDescribe();
            Schema.DescribeFieldResult pauseDateTime = Case.Case_Paused_TimeStamp__c.getDescribe();
            Schema.DescribeFieldResult Stop_TimerDes = Case.Stop_Timer__c.getDescribe();
            Schema.DescribeFieldResult pausedDays = Case.Case_Paused_Days__c.getDescribe(); 
            Schema.DescribeFieldResult ispaused = Case.isPaused__c.getDescribe(); 
            fieldsDes.add(pausedDays);
            fieldsDes.add(pauseDateTime);
            fieldsDes.add(Stop_TimerDes);
            fieldsDes.add(ispaused);
            return fieldsDes;
        }
}