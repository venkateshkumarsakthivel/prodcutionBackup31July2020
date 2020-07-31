/**
 * @Description: Implementation class to generate csv file for law part code related to serious driving offence to be consumed by RMS
 * @Author: Arxxus Technology Partners Pty Ltd
 * @Date: 21/08/2018
 */
public with sharing class SeriousDrivingFileGenerator extends LawPartCodeFileGenerator{
        
    public SeriousDrivingFileGenerator(){
        super();
    }
    
    //method to retrieve quaified law part codes
    public override List<LawPartCode> retrieveQualifiedLPC() {
        
        List<Law_Part_Code__c> lawPartCodeList = fetchLawPartCodeList();
        List<LawPartCode> lawPartCodeWrapper = fetchlawPartCodeWrapper(lawPartCodeList);
        
        return lawPartCodeWrapper;
    }
    
    //mehod to fetch law part code records
    public List<Law_Part_Code__c> fetchLawPartCodeList() {
        List<Law_Part_Code__c> lawPartCodeList = [SELECT Id, Name, Legislation__c, Section_Clause__c, Law_Part_Description__c, 
                                                  Special_Conditions__c, Status__c, Approval_Date__c, P2P_Regulatory_End_Date__c, 
                                                  P2P_Classification__c , Old_P2P_Classification__c, Old_Special_Conditions__c, 
                                                  IsAddedForUploadToS3__c 
                                                  FROM Law_Part_Code__c 
                                                  WHERE Status__c = 'Approved' AND Approval_Date__c = TODAY];
        
        return lawPartCodeList;
    }
    
    //method to fetch LawPartCode wrapper list
    @TestVisible
    private List<LawPartCode> fetchlawPartCodeWrapper(List<Law_Part_Code__c> lawPartCodeList) {
        List<LawPartCode> lawPartCodeWrapperList = new List<LawPartCode>();
        
        for(Law_Part_Code__c lawPartCodeRecord : lawPartCodeList) {
            
            if(lawPartCodeRecord.P2P_Classification__c == 'Serious Driving Offence' && lawPartCodeRecord.Status__c == 'Approved' 
               && lawPartCodeRecord.Approval_Date__c == System.Today() && lawPartCodeRecord.IsAddedForUploadToS3__c != true
               && (lawPartCodeRecord.P2P_Regulatory_End_Date__c > System.Today() || lawPartCodeRecord.P2P_Regulatory_End_Date__c == null)) {
                   
                   lawPartCodeWrapperList.add(new LawPartCode(lawPartCodeRecord.Name, lawPartCodeRecord.Legislation__c, lawPartCodeRecord.Section_Clause__c, lawPartCodeRecord.Law_Part_Description__c, lawPartCodeRecord.Special_Conditions__c, LawPartCodeFileGenerator.ACTION.Add));
            }
            
            if(lawPartCodeRecord.P2P_Classification__c == 'Serious Driving Offence' && lawPartCodeRecord.Status__c == 'Approved' 
               && lawPartCodeRecord.Approval_Date__c == System.Today() && lawPartCodeRecord.IsAddedForUploadToS3__c == true
               && lawPartCodeRecord.Special_Conditions__c != lawPartCodeRecord.Old_Special_Conditions__c
               && (lawPartCodeRecord.P2P_Regulatory_End_Date__c > System.Today() || lawPartCodeRecord.P2P_Regulatory_End_Date__c == null)) {
                   
                   lawPartCodeWrapperList.add(new LawPartCode(lawPartCodeRecord.Name, lawPartCodeRecord.Legislation__c, lawPartCodeRecord.Section_Clause__c, lawPartCodeRecord.Law_Part_Description__c, lawPartCodeRecord.Special_Conditions__c, LawPartCodeFileGenerator.ACTION.Change));
            }
            
            if(lawPartCodeRecord.P2P_Classification__c != 'Serious Driving Offence' && lawPartCodeRecord.Old_P2P_Classification__c == 'Serious Driving Offence' 
               && lawPartCodeRecord.Status__c == 'Approved' && lawPartCodeRecord.Approval_Date__c == System.Today()) {
                   
                   lawPartCodeWrapperList.add(new LawPartCode(lawPartCodeRecord.Name, lawPartCodeRecord.Legislation__c, lawPartCodeRecord.Section_Clause__c, lawPartCodeRecord.Law_Part_Description__c, lawPartCodeRecord.Special_Conditions__c, LawPartCodeFileGenerator.ACTION.Remove));
            }
            
            if(lawPartCodeRecord.P2P_Classification__c == 'Serious Driving Offence' && lawPartCodeRecord.Status__c == 'Approved' 
               && ((lawPartCodeRecord.P2P_Regulatory_End_Date__c <= System.Today() && lawPartCodeRecord.Approval_Date__c == System.Today())
                   || lawPartCodeRecord.P2P_Regulatory_End_Date__c == System.Today())) {
                   
                   lawPartCodeWrapperList.add(new LawPartCode(lawPartCodeRecord.Name, lawPartCodeRecord.Legislation__c, lawPartCodeRecord.Section_Clause__c, lawPartCodeRecord.Law_Part_Description__c, lawPartCodeRecord.Special_Conditions__c, LawPartCodeFileGenerator.ACTION.Remove));
            }
        }
        
        return lawPartCodeWrapperList;
    }
}