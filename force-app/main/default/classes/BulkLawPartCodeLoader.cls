public with sharing class BulkLawPartCodeLoader {
    
    private String filedata; 
    private String headerRow;
    
    //array to store success and error count. 0th element -> success count, 1st element -> error count
    private List<Integer> uploadResult;    
    
    public BulkLawPartCodeLoader(String filedata, String headerRow){
        
        this.filedata = filedata;
        this.headerRow = headerRow;
        this.uploadResult = new List<Integer>();
        uploadResult.add(0);
        uploadResult.add(0);
    }    
    
    //Executes the process of insertion of Fleet records
    //returns number of successfully inserted records
    public String execute() {
        
        Integer recordIndex = 0;
        String errorString = '';
        String resultString;
        
        try {
            
            System.debug('In Execute');  
            
            if(filedata == null) {
                
                throw new BulkLoadException(Label.EXCEPTION_MSG_INVALID_DATA);
            }
            
            List<Law_Part_Code__c> lawPartCodes; 
            lawPartCodes = parseLawPartCodes();
            
            //Save records in database allowing partial insertion
            Database.SaveResult[] srList = Database.insert(lawPartCodes, false);
            
            for(Database.SaveResult sr : srList) {
                
                System.debug('srResult = '+sr);
                if(!sr.isSuccess()) {
                    
                    //Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        
                        if(!String.isBlank(lawPartCodes[recordIndex].Name))
                            errorString += lawPartCodes[recordIndex].Name+': ';
                        
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        errorString += 'Error- '+err.getMessage();
                        System.debug('Law part code fields that affected this error: ' + err.getFields());
                        errorString += 'Fields- '+err.getFields();
                        
                        //error at database level, increase error count & decrease success count
                        /*
uploadResult[0] = uploadResult[0] - 1;
uploadResult[1] = uploadResult[1] + 1;
*/
                        
                        errorString += '\r\n';
                    }
                    
                    uploadResult[1] = uploadResult[1]+1;
                }
                else {
                    
                    uploadResult[0] = uploadResult[0]+1;
                }
                
                recordIndex++;
            }
            /* Helper method to capture the csv generation process in application log */
            
            Application_Log__c log = new Application_Log__c();
            log.Debug_Level__c = GlobalConstants.INFO;
            log.Message__c = String.isBlank(errorString) ? 'No errors.' : errorString;
            log.Source__c = 'BulkLawPartCodeLoader'; 
            log.Source_Function__c = 'execute';   
            insert log;
            
            log = [SELECT Name FROM Application_Log__c WHERE Id =:log.Id];
            
            resultString = uploadResult[0]+ ' records inserted. '+uploadResult[1]+ ' records failed to upload. <br/>Upload details available in log <a href="/lightning/r/Application_Log__c/'+log.Id+'/view" target="_blank">'+log.Name+'</a>.';
        }
        catch(Exception e){
            
            System.debug(e.getMessage());
            ApplicationLogUtility.logMessage(GlobalConstants.ERROR, 'BulkLawPartCodeLoader', 'execute', e.getMessage(), e);
        }
        
        return resultString;
    }
    
    //passes single row of csv to insert single law part code record
    @TestVisible
    private List<Law_Part_Code__c> parseLawPartCodes() {
        
        List<Law_Part_Code__c> newLawPartCodes = new List<Law_Part_Code__c>();
        List<String> headerRows = headerRow.split(',');
        
        Map<String, Integer> headerNameVsIndex = new Map<String, Integer>();
        
        Integer index = 0;
        for(String tempHead : headerRows) {
            
            headerNameVsIndex.put(tempHead.replaceAll('\\r', ''), index++);
        }
        System.debug('Header Row Map: '+headerNameVsIndex);
        
        Iterator<List<String>> parser = new ATP_CSVParser(filedata);
        
        List<Bulk_Upload_Law_Part_Code_Mapping__mdt> lpcUploadMapping = [SELECT MasterLabel, Field_API_Name__c, Is_Date_Field__c
                                                                         FROM Bulk_Upload_Law_Part_Code_Mapping__mdt];
        
        System.debug('Add law part codes');
        while(parser.hasNext()) {
            
            List<String> lawPartCodesRecord = new List<String>();
            Law_Part_Code__c newLawPartCode = new Law_Part_Code__c();
            
            lawPartCodesRecord = parser.next();
            newLawPartCode = LawPartCodeEntityBuilder.buildLawPartCode(lawPartCodesRecord, headerNameVsIndex, lpcUploadMapping);
            
            if(newLawPartCode != NULL)
                newLawPartCodes.add(newLawPartCode);
            
        }
        
        System.debug('Success Count---> '+uploadResult[0]+' -----Error Count --->'+uploadResult[1]);
        
        return newLawPartCodes;
    }
    
    public class BulkLoadException extends Exception {}
}