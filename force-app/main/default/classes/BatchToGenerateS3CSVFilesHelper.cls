public class BatchToGenerateS3CSVFilesHelper {
    
    public BatchToGenerateS3CSVFilesHelper() {
    }
    
    //method to generate csv files
    Public Map<Id, Attachment> generateS3CSVFiles(List<LPC_Config__mdt> lpcConfigMetadataList) {
        
        List<Attachment> attachementList = new List<Attachment>();
        Map<Id, Attachment> attachementParentIdVsAttachemntMap = new Map<Id, Attachment>();
        
        if(lpcConfigMetadataList != null && lpcConfigMetadataList.size() > 0) { 
            attachementList = fetchAttachmentList(lpcConfigMetadataList);
        }
        
        if(attachementList != null && attachementList.size() > 0) {
            for(Attachment attachRec : attachementList) {
                attachementParentIdVsAttachemntMap.put(attachRec.ParentId, attachRec);
            }
        }
        
        return attachementParentIdVsAttachemntMap;
    }
    
    //method to fetch attachment list
    @TestVisible
    private List<Attachment> fetchAttachmentList(List<LPC_Config__mdt> lpcConfigMetadataList) {
        
        List<Attachment> attachementList = new List<Attachment>();
        
        for(LPC_Config__mdt LpcConfigMetadataRec : lpcConfigMetadataList) {
            
            String lpcConfigMetadataClassName = LpcConfigMetadataRec.ClassName__c;
            String lpcConfigMetadataFileName = LpcConfigMetadataRec.FileName__c;
            ICsvFileGenerator fileGeneratorInstance = (ICsvFileGenerator)Type.forName(lpcConfigMetadataClassName).newInstance();
            fileGeneratorInstance.setFileName(lpcConfigMetadataFileName);
            Attachment attachmentRec = fileGeneratorInstance.generateCsvFile();
            if(attachmentRec != null) {
                attachementList.add(attachmentRec);
            }
        }
        return attachementList;
    }
    
    //method to fetch LPC Config metadata list
    public Map<String, LPC_Config__mdt> fetchLpcConfigMetadatasList() {
        Map<String, LPC_Config__mdt> fileNameVsLpcConfigMdtMap = new Map<String, LPC_Config__mdt>();
        List<LPC_Config__mdt> lpcConfigMetadatasList = [SELECT Id, MasterLabel, DeveloperName, Key__c, Secret__c, Bucket__c, 
                                                       Host__c, Directory__c, FileName__c, ClassName__c 
                                                       FROM LPC_Config__mdt 
                                                       ORDER BY Id ASC];
        for(LPC_Config__mdt lpcConfigMdt : lpcConfigMetadatasList) {
            fileNameVsLpcConfigMdtMap.put(lpcConfigMdt.FileName__c + '_' + System.now().format('ddMMyyyy') + '.csv', lpcConfigMdt);
        }
        
        return fileNameVsLpcConfigMdtMap;
    }
    
    //method to fetch Application Log Id Set
    public Set<Id> fetchApplicationLogIdSet(Map<Id, Attachment> attachementParentIdVsAttachemntMap) {
        Set<Id> applicationLogIdSet = new Set<Id>();
        for(Id appLogId : attachementParentIdVsAttachemntMap.keySet()) {
            applicationLogIdSet.add(appLogId);
        }
        
        return applicationLogIdSet;
        
    }
    
    //method to fetch Application Log records
    public Map<Id, Application_Log__c> fetchIdVsApplicationLogMap(Set<Id> applicationLogIdSet) {
        Map<Id, Application_Log__c> idVsApplicationLogMap = new Map<Id, Application_Log__c>();
        List<Application_Log__c> applicationLogList = [SELECT Id, Integration_Payload__c, Debug_Level__c, Message__c, Source__c, Source_Function__c 
                                                       FROM Application_Log__c WHERE Id IN : applicationLogIdSet];
        for(Application_Log__c appLogRec : applicationLogList) {
            idVsApplicationLogMap.put(appLogRec.Id, appLogRec);
        }
        
        return idVsApplicationLogMap;
    }
    
    //method to upload file in S3
    public HTTPResponse uploadFileToS3(Attachment attachRec, Map<String, LPC_Config__mdt> fileNameVsLpcConfigMdtMap) {
        
        Attachment attach = [SELECT Body, ContentType, Name FROM Attachment WHERE Id =: attachRec.Id  LIMIT 1];
        String attachmentBody = EncodingUtil.base64Encode(attach.Body);
        String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
        String key = fileNameVsLpcConfigMdtMap.get(attachRec.Name).Key__c;
        String secret = fileNameVsLpcConfigMdtMap.get(attachRec.Name).Secret__c;
        String bucketname = fileNameVsLpcConfigMdtMap.get(attachRec.Name).Bucket__c;
        String host = fileNameVsLpcConfigMdtMap.get(attachRec.Name).Host__c;
        String directory = fileNameVsLpcConfigMdtMap.get(attachRec.Name).Directory__c;
        String method = 'PUT';
        String filename = attach.Name;
        HttpRequest req = new HttpRequest();
        req.setMethod(method);
        req.setEndpoint('https://' + bucketname + '.' + host + directory + filename);
        req.setHeader('Host', bucketname + '.' + host);
        req.setHeader('Content-Length', String.valueOf(attachmentBody.length()));
        req.setHeader('Content-Encoding', 'UTF-8');
        req.setHeader('Content-type', attach.ContentType);
        req.setHeader('Connection', 'keep-alive');
        req.setHeader('Date', formattedDateString);
        req.setHeader('ACL', 'public-read-write');
        req.setBodyAsBlob(attach.Body);
        String stringToSign = 'PUT\n\n' + attach.ContentType + '\n' + formattedDateString + '\n' + '/' + bucketname + directory + filename;
        String encodedStringToSign = EncodingUtil.urlEncode(stringToSign, 'UTF-8');
        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign),blob.valueof(secret));
        String signedKey  = EncodingUtil.base64Encode(mac);
        String authHeader = 'AWS' + ' ' + key + ':' + signedKey ;
        req.setHeader('Authorization',authHeader);
        String decoded = EncodingUtil.urlDecode(encodedStringToSign , 'UTF-8');
        HTTPResponse res = new HTTPResponse();
        Http http = new Http();
        if(!Test.isRunningTest()) {
            res = http.send(req);
        }
        else {
            HttpResponse responseForTestClass = new HttpResponse();
            responseForTestClass.setHeader('Content-Type', 'application/json');
            responseForTestClass.setBody('{"foo":"bar"}');
            responseForTestClass.setStatusCode(200);
            return responseForTestClass;
        }
        
        return res;
    }
    
    //method to fetch updated Application Log records
    public Map<Id, Application_Log__c> fetchUpdateApplicationLog(HTTPResponse res, Map<Id, Application_Log__c> idVsApplicationLogMap, String attachmentParentId) {
        if(res.getStatusCode() == 200) {
            idVsApplicationLogMap.get(attachmentParentId).Integration_Payload__c = res.getStatus();
        }
        else {
            idVsApplicationLogMap.get(attachmentParentId).Integration_Payload__c = res.getStatus();
            idVsApplicationLogMap.get(attachmentParentId).Debug_Level__c = 'Error';
        }
        
        return idVsApplicationLogMap;
    }
    
    //method to fetch Law Part Code list to update for IsAddedForUploadToS3_c
    public Map<Id, Law_Part_Code__c> fetchLawPartCodeListToUpdate(HTTPResponse res, Map<Id, Law_Part_Code__c> idVsLawPartCodeMap, Attachment attachRec, Map<String, LPC_Config__mdt> fileNameVsLpcConfigMdtMap) {
        if(res.getStatusCode() == 200) {
            List<Law_Part_Code__c> fetchedLawPartCodeList = new List<Law_Part_Code__c>();
            if(fileNameVsLpcConfigMdtMap.get(attachRec.Name).FileName__c == 'LPC_CRI_NSWPF' || fileNameVsLpcConfigMdtMap.get(attachRec.Name).FileName__c == 'LPC_CRI_RMS') {
                fetchedLawPartCodeList = new CriminalChargeFileGenerator().fetchLawPartCodeList();
            }
            if(fileNameVsLpcConfigMdtMap.get(attachRec.Name).FileName__c == 'LPC_SDO_RMS') {
                fetchedLawPartCodeList = new SeriousDrivingFileGenerator().fetchLawPartCodeList();
            }
            for(Law_Part_Code__c lawPartCodeRecord : fetchedLawPartCodeList) {
                if((lawPartCodeRecord.P2P_Classification__c == 'Criminal Offence' || lawPartCodeRecord.P2P_Classification__c == 'Serious Driving Offence') 
                   && lawPartCodeRecord.Status__c == 'Approved' && lawPartCodeRecord.Approval_Date__c == System.Today() 
                   && lawPartCodeRecord.IsAddedForUploadToS3__c != true 
                   && (lawPartCodeRecord.P2P_Regulatory_End_Date__c > System.Today() || lawPartCodeRecord.P2P_Regulatory_End_Date__c == null)) {
                       
                       lawPartCodeRecord.IsAddedForUploadToS3__c = true;
                       lawPartCodeRecord.Old_Special_Conditions__c = lawPartCodeRecord.Special_Conditions__c;
                       lawPartCodeRecord.Old_P2P_Classification__c = lawPartCodeRecord.P2P_Classification__c;
                       idVsLawPartCodeMap.put(lawPartCodeRecord.Id, lawPartCodeRecord);
                }
                if((lawPartCodeRecord.P2P_Classification__c == 'Criminal Offence' || lawPartCodeRecord.P2P_Classification__c == 'Serious Driving Offence') 
                   && lawPartCodeRecord.Status__c == 'Approved' && lawPartCodeRecord.Approval_Date__c == System.Today() 
                   && lawPartCodeRecord.IsAddedForUploadToS3__c == true
                   && lawPartCodeRecord.Special_Conditions__c != lawPartCodeRecord.Old_Special_Conditions__c
                   && (lawPartCodeRecord.P2P_Regulatory_End_Date__c > System.Today() || lawPartCodeRecord.P2P_Regulatory_End_Date__c == null)) {
                       
                       lawPartCodeRecord.Old_Special_Conditions__c = lawPartCodeRecord.Special_Conditions__c;
                       lawPartCodeRecord.Old_P2P_Classification__c = lawPartCodeRecord.P2P_Classification__c;
                       idVsLawPartCodeMap.put(lawPartCodeRecord.Id, lawPartCodeRecord);
                }
                if(((lawPartCodeRecord.P2P_Classification__c != 'Criminal Offence' && lawPartCodeRecord.Old_P2P_Classification__c == 'Criminal Offence') 
                    || (lawPartCodeRecord.P2P_Classification__c != 'Serious Driving Offence' && lawPartCodeRecord.Old_P2P_Classification__c == 'Serious Driving Offence')) 
                   && lawPartCodeRecord.Status__c == 'Approved' && lawPartCodeRecord.Approval_Date__c == System.Today()
                   && (lawPartCodeRecord.P2P_Regulatory_End_Date__c > System.Today() || lawPartCodeRecord.P2P_Regulatory_End_Date__c == null)) {
                       
                       lawPartCodeRecord.Old_Special_Conditions__c = lawPartCodeRecord.Special_Conditions__c;
                       lawPartCodeRecord.Old_P2P_Classification__c = lawPartCodeRecord.P2P_Classification__c;
                       idVsLawPartCodeMap.put(lawPartCodeRecord.Id, lawPartCodeRecord);
                }
            }
        }
        
        return idVsLawPartCodeMap;
    }

}