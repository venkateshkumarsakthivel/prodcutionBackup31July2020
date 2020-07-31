// this class is used as SchedulerToGenerateS3CSVFiles's test class 
@isTest
public class SchedulerToGenerateS3CSVFilesTest {
    
    @testSetup
    private static void setupTestData() {
        
        List<Law_Part_Code__c> lawPartCodeList = new List<Law_Part_Code__c>();
        Law_Part_Code__c lawPartCodeSDRecord1 = new Law_Part_Code__c(Name = '11111', Unapproved_Special_Conditions__c = '1001', Legislation__c = 'Serious Driving Offence', 
                                                                     Section_Clause__c = 'Serious Driving Offence', Law_Part_Description__c = 'Serious Driving Offence', 
                                                                     Special_Conditions__c = 'Serious Driving Offence', Status__c = 'Approved', 
                                                                     Approval_Date__c = System.Today(), P2P_Regulatory_End_Date__c = System.Today().addYears(1), 
                                                                     P2P_Classification__c = 'Serious Driving Offence', Law_Part_Commencement_Date__c = System.Today());
        lawPartCodeList.add(lawPartCodeSDRecord1);
        Law_Part_Code__c lawPartCodeSDRecord2 = new Law_Part_Code__c(Name = '22222', Unapproved_Special_Conditions__c = '1002', Legislation__c = 'Serious Driving Offence', 
                                                                     Section_Clause__c = 'Serious Driving Offence', Law_Part_Description__c = 'Serious Driving Offence', 
                                                                     Special_Conditions__c = 'Serious Driving Offence', Status__c = 'Approved', 
                                                                     Approval_Date__c = System.Today(), P2P_Regulatory_End_Date__c = System.Today().addYears(1), 
                                                                     P2P_Classification__c = 'Serious Driving Offence', Law_Part_Commencement_Date__c = System.Today());
        lawPartCodeList.add(lawPartCodeSDRecord2);
        Law_Part_Code__c lawPartCodeSDRecord3 = new Law_Part_Code__c(Name = '33333', Unapproved_Special_Conditions__c = '1003', Legislation__c = 'Serious Driving Offence', 
                                                                     Section_Clause__c = 'Serious Driving Offence', Law_Part_Description__c = 'Serious Driving Offence', 
                                                                     Special_Conditions__c = 'Serious Driving Offence', Status__c = 'Approved', 
                                                                     Approval_Date__c = System.Today().addYears(-1), P2P_Regulatory_End_Date__c = System.Today(), 
                                                                     P2P_Classification__c = 'Serious Driving Offence', Law_Part_Commencement_Date__c = System.Today());
        lawPartCodeList.add(lawPartCodeSDRecord3);
        Law_Part_Code__c lawPartCodeSDRecord4 = new Law_Part_Code__c(Name = '77777', Unapproved_Special_Conditions__c = '1004', Legislation__c = 'Serious Driving Offence', 
                                                                     Section_Clause__c = 'Serious Driving Offence', Law_Part_Description__c = 'Serious Driving Offence', 
                                                                     Special_Conditions__c = 'Serious Driving Offence', Status__c = 'Approved', 
                                                                     Approval_Date__c = System.Today(), P2P_Regulatory_End_Date__c = System.Today().addYears(1), 
                                                                     P2P_Classification__c = 'Serious Driving Offence', Law_Part_Commencement_Date__c = System.Today());
        lawPartCodeList.add(lawPartCodeSDRecord4);
        Law_Part_Code__c lawPartCodeSDRecord5 = new Law_Part_Code__c(Name = '11111', Unapproved_Special_Conditions__c = '1001', Legislation__c = 'Serious Driving Offence', 
                                                                     Section_Clause__c = 'Serious Driving Offence', Law_Part_Description__c = 'Serious Driving Offence', 
                                                                     Special_Conditions__c = 'Serious Driving Offence', Status__c = 'Approved', 
                                                                     Approval_Date__c = System.Today(), P2P_Regulatory_End_Date__c = System.Today(), 
                                                                     P2P_Classification__c = 'Serious Driving Offence', Law_Part_Commencement_Date__c = System.Today());
        lawPartCodeList.add(lawPartCodeSDRecord5);
        
        Law_Part_Code__c lawPartCodeCORecord1 = new Law_Part_Code__c(Name = '44444', Unapproved_Special_Conditions__c = '2001', Legislation__c = 'Criminal Offence', 
                                                                     Section_Clause__c = 'Criminal Offence', Law_Part_Description__c = 'Criminal Offence', 
                                                                     Special_Conditions__c = 'Criminal Offence', Status__c = 'Approved', 
                                                                     Approval_Date__c = System.Today(), P2P_Regulatory_End_Date__c = System.Today().addYears(1), 
                                                                     P2P_Classification__c = 'Criminal Offence', Law_Part_Commencement_Date__c = System.Today());
        lawPartCodeList.add(lawPartCodeCORecord1);
        Law_Part_Code__c lawPartCodeCORecord2 = new Law_Part_Code__c(Name = '55555', Unapproved_Special_Conditions__c = '2002', Legislation__c = 'Criminal Offence', 
                                                                     Section_Clause__c = 'Criminal Offence', Law_Part_Description__c = 'Criminal Offence', 
                                                                     Special_Conditions__c = 'Criminal Offence', Status__c = 'Approved', 
                                                                     Approval_Date__c = System.Today(), P2P_Regulatory_End_Date__c = System.Today().addYears(1), 
                                                                     P2P_Classification__c = 'Criminal Offence', Law_Part_Commencement_Date__c = System.Today());
        lawPartCodeList.add(lawPartCodeCORecord2);
        Law_Part_Code__c lawPartCodeCORecord3 = new Law_Part_Code__c(Name = '66666', Unapproved_Special_Conditions__c = '2003', Legislation__c = 'Criminal Offence', 
                                                                     Section_Clause__c = 'Criminal Offence', Law_Part_Description__c = 'Criminal Offence', 
                                                                     Special_Conditions__c = 'Criminal Offence', Status__c = 'Approved', 
                                                                     Approval_Date__c = System.Today().addYears(-1), P2P_Regulatory_End_Date__c = System.Today(), 
                                                                     P2P_Classification__c = 'Criminal Offence', Law_Part_Commencement_Date__c = System.Today());
        lawPartCodeList.add(lawPartCodeCORecord3);
        Law_Part_Code__c lawPartCodeCORecord4 = new Law_Part_Code__c(Name = '88888', Unapproved_Special_Conditions__c = '2004', Legislation__c = 'Criminal Offence', 
                                                                     Section_Clause__c = 'Criminal Offence', Law_Part_Description__c = 'Criminal Offence', 
                                                                     Special_Conditions__c = 'Criminal Offence', Status__c = 'Approved', 
                                                                     Approval_Date__c = System.Today(), P2P_Regulatory_End_Date__c = System.Today().addYears(1), 
                                                                     P2P_Classification__c = 'Criminal Offence', Law_Part_Commencement_Date__c = System.Today());
        lawPartCodeList.add(lawPartCodeCORecord4);
        Law_Part_Code__c lawPartCodeCORecord5 = new Law_Part_Code__c(Name = '44444', Unapproved_Special_Conditions__c = '2001', Legislation__c = 'Criminal Offence', 
                                                                     Section_Clause__c = 'Criminal Offence', Law_Part_Description__c = 'Criminal Offence', 
                                                                     Special_Conditions__c = 'Criminal Offence', Status__c = 'Approved', 
                                                                     Approval_Date__c = System.Today(), P2P_Regulatory_End_Date__c = System.Today(), 
                                                                     P2P_Classification__c = 'Criminal Offence', Law_Part_Commencement_Date__c = System.Today());
        lawPartCodeList.add(lawPartCodeCORecord5);
        
        insert lawPartCodeList;
    }
    
    @isTest
    private static void executeTest() {
        
        List<Law_Part_Code__c> lawPartCodeList = [SELECT Id, Name, Unapproved_Special_Conditions__c, Legislation__c, Section_Clause__c, Law_Part_Description__c, 
                                                  Special_Conditions__c, Status__c, Approval_Date__c, P2P_Regulatory_End_Date__c, 
                                                  P2P_Classification__c , Old_P2P_Classification__c, Old_Special_Conditions__c, 
                                                  IsAddedForUploadToS3__c  
                                                  FROM Law_Part_Code__c WHERE Unapproved_Special_Conditions__c IN ('1002','2002')];
        lawPartCodeList[0].P2P_Classification__c = 'Unclassified';
		lawPartCodeList[0].Status__c = 'Approved';
        lawPartCodeList[0].Approval_Date__c = System.Today();
        lawPartCodeList[1].P2P_Classification__c = 'Unclassified';
		lawPartCodeList[1].Status__c = 'Approved';
        lawPartCodeList[1].Approval_Date__c = System.Today();
        update lawPartCodeList;
        
        List<Law_Part_Code__c> lawPartCodeList2 = [SELECT Id, Name, Unapproved_Special_Conditions__c, Legislation__c, Section_Clause__c, Law_Part_Description__c, 
                                                  Special_Conditions__c, Status__c, Approval_Date__c, P2P_Regulatory_End_Date__c, 
                                                  P2P_Classification__c , Old_P2P_Classification__c, Old_Special_Conditions__c, 
                                                  IsAddedForUploadToS3__c  
                                                  FROM Law_Part_Code__c WHERE Unapproved_Special_Conditions__c IN ('1004','2004')];
        lawPartCodeList2[0].Special_Conditions__c = 'Test';
        lawPartCodeList2[0].IsAddedForUploadToS3__c = true;
        lawPartCodeList2[1].Special_Conditions__c = 'Test';
        lawPartCodeList2[1].IsAddedForUploadToS3__c = true;
        update lawPartCodeList2;
        Test.startTest();
        new SchedulerToGenerateS3CSVFiles().execute(null);
        Test.stopTest();
    }
    
    @isTest
    private static void executeTest2() {
        
        List<Law_Part_Code__c> lawPartCodeList = [SELECT Id, Name, Unapproved_Special_Conditions__c, Legislation__c, Section_Clause__c, Law_Part_Description__c, 
                                                  Special_Conditions__c, Status__c, Approval_Date__c, P2P_Regulatory_End_Date__c, 
                                                  P2P_Classification__c , Old_P2P_Classification__c, Old_Special_Conditions__c, 
                                                  IsAddedForUploadToS3__c  
                                                  FROM Law_Part_Code__c];
        
        delete lawPartCodeList;
        
        Test.startTest();
        new SchedulerToGenerateS3CSVFiles().execute(null);
        Test.stopTest();
    }

}