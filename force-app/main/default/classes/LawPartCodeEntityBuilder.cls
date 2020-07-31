public with sharing class LawPartCodeEntityBuilder {
    
    //Input :- Single row of CSV 
    //Output :- Law Part Code record formed from the input
    public static Law_Part_Code__c buildLawPartCode(List<String> lawPartCodesRecord, Map<String, Integer> headerNameVsIndex, List<Bulk_Upload_Law_Part_Code_Mapping__mdt> lpcUploadMapping){	
        
        try {
            
            Law_Part_Code__c lpc = new Law_Part_Code__c();
            
            System.debug('lawPartCodesRecord====> ' +lawPartCodesRecord);
            System.debug('headerNameVsIndex====> ' +headerNameVsIndex);
            System.debug('lpcUploadMapping====> ' +lpcUploadMapping);
            System.debug('lawPartCodesRecord====> ' +lawPartCodesRecord.size());
            
            for(Bulk_Upload_Law_Part_Code_Mapping__mdt tempLPCMapping : lpcUploadMapping) {
                
                if(headerNameVsIndex.containsKey(tempLPCMapping.MasterLabel)) {
                    
                    String fieldAPIName = tempLPCMapping.Field_API_Name__c;
                    
                    String fieldValue = lawPartCodesRecord.size() > headerNameVsIndex.get(tempLPCMapping.MasterLabel) ? lawPartCodesRecord[headerNameVsIndex.get(tempLPCMapping.MasterLabel)] : '';
                    
                    system.debug('Debug log to capture====>>> '+ fieldValue +' --***-- '+ tempLPCMapping.Is_Date_Field__c);
                    if(String.isNotBlank(fieldValue) && tempLPCMapping.Is_Date_Field__c == true)
                        lpc.put(fieldAPIName, Date.parse(fieldValue.replace('-', '/')));
                    else if(tempLPCMapping.Is_Date_Field__c == false)
                        lpc.put(fieldAPIName, fieldValue);
                    
                    if(fieldAPIName == 'Name')
                        lpc.put('Law_Part_Code__c', fieldValue);
                }
            }
            
            lpc.Status__c = 'Unapproved';
            lpc.P2P_Classification__c = 'Unclassified';
            
            return lpc;
        }
        catch(Exception e){
            System.debug('LawPartCodeEntityBuilder error Message==> '+e);
            return null;
        }
    }
}