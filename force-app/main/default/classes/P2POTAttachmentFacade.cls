public with sharing class P2POTAttachmentFacade {
    
    /**
        this private method will be used by other methods to find the OpenText workspace (node) reference (nodeId)
        against salesforce caseId
    */
    private String fetchCaseRefrenceNumberFromOT(String identifier, String stype)  {
        P2POTSOAPAuthenticator p2POTSOAPAuthenticator = new P2POTSOAPAuthenticator();
        p2POTSOAPAuthenticator.invoke();
        /* current implementation to find nodeId against statically assigned case in DEV1*/
        /* commenting line below as we are executing this method in DEV1 sandbox environment. 
         * by commenting line we are using caseId passed as an argument.
        */
        /** identifier = '5000l000000vGoqAAE'; */
        Map<String, String> requestParameters = new Map<String, String>();
        requestParameters.put('SFOBJECTID', identifier);
        requestParameters.put('OTOBJECTTYPENAME', stype);
        
        P2POTNodeIdResource p2POTNodeIdResource = new P2POTNodeIdResource(requestParameters, p2POTSOAPAuthenticator);
        p2POTNodeIdResource.invoke();
            return p2POTNodeIdResource.getNodeId();
    }
    
    /**
            this method will be used to upload document into OT from community pages.
    */
    public Boolean uploadFromTrigger(String identifier, String name, String contents, String ctype, String stype)  {
        String parent;
        if(Test.isRunningTest())  {
            parent = '12345';
        } else { parent = this.fetchCaseRefrenceNumberFromOT(identifier, stype); }
            
        P2POTAppClient p2pOTApplicationClient = new P2POTAppClient();
        P2POTAppClient.P2POTRequestParam p2POTRequestParameter = new P2POTAppClient.P2POTRequestParam();
        
        p2POTRequestParameter.nodeName = parent;
        p2POTRequestParameter.fileData = contents;
        p2POTRequestParameter.fileBlob = EncodingUtil.base64Decode(contents);
        p2POTRequestParameter.fileName = name;
        p2POTRequestParameter.ctype = ctype;
        
        P2POTCreateNodeResponseParserVisitor p2POTCreateNodeResponseParserVisitor = new P2POTCreateNodeResponseParserVisitor();
        p2pOTApplicationClient.callOTApp(P2POTAppClient.OT_REQUEST_TYPE.CREATENODE, p2POTCreateNodeResponseParserVisitor, p2POTRequestParameter);
        return p2POTCreateNodeResponseParserVisitor.success;
    }
    
    /**
            this method will be used to upload document into OT from community pages.
    */
    public Boolean upload(String identifier, String name, String contents, String ctype)  {
        String parent;
        if(Test.isRunningTest())  {
            parent = '12345';
        } else { parent = this.fetchCaseRefrenceNumberFromOT(identifier, 'Case'); }
            
        P2POTAppClient p2pOTApplicationClient = new P2POTAppClient();
        P2POTAppClient.P2POTRequestParam p2POTRequestParameter = new P2POTAppClient.P2POTRequestParam();
        
        p2POTRequestParameter.nodeName = parent;
        p2POTRequestParameter.fileData = contents;
        p2POTRequestParameter.fileBlob = EncodingUtil.base64Decode(contents);
        p2POTRequestParameter.fileName = name;
        p2POTRequestParameter.ctype = ctype;
        
        P2POTCreateNodeResponseParserVisitor p2POTCreateNodeResponseParserVisitor = new P2POTCreateNodeResponseParserVisitor();
        p2pOTApplicationClient.callOTApp(P2POTAppClient.OT_REQUEST_TYPE.CREATENODE, p2POTCreateNodeResponseParserVisitor, p2POTRequestParameter);
        return p2POTCreateNodeResponseParserVisitor.success;
    }
    
    /**
            this method will be used to list documents from OT from community pages.
    */
    public List<OTNode> rbrowse(String identifier)  {
        String parent;
        if(Test.isRunningTest())  {
            parent = '12345';
        } else { parent = this.fetchCaseRefrenceNumberFromOT(identifier, 'Case'); }
            
        P2POTAppClient p2pOTApplicationClient = new P2POTAppClient();
        P2POTAppClient.P2POTRequestParam p2POTRequestParameter = new P2POTAppClient.P2POTRequestParam();
        
        p2POTRequestParameter.nodeName = parent;
        p2POTRequestParameter.requestType = P2POTAppClient.OT_REQUEST_TYPE.BROWSENODE;
        
        P2POTBrowseNodeResponseParserVisitor p2POTBrowseNodeResponseParserVisitor = new P2POTBrowseNodeResponseParserVisitor();
        p2pOTApplicationClient.callOTApp(P2POTAppClient.OT_REQUEST_TYPE.BROWSENODE, p2POTBrowseNodeResponseParserVisitor, p2POTRequestParameter);
        /* filter only documents and skip folders from OT for display purpose. */
        List<OTNode> onlyFileNodes = new List<OTNode>();            
        for(OTNode node : p2POTBrowseNodeResponseParserVisitor.otNodes)  {
            if(!node.container)  {
                onlyFileNodes.add(node);
            }
        }
        return onlyFileNodes;
    }
    
    /**
            this method will be used to list documents from loacal salesforce Attachment Object from community pages.
    */
    public List<OTNode> browse(String identifier)  {
        List<OTNode> fileNodes = new List<OTNode>();
        fileNodes = this.attachments(identifier);
        return fileNodes;
    }
    
    private List<OTNode> attachments(String identifier)  {
        
        System.debug('Who am I : ' + UserInfo.getUserName() + ' : ' + UserInfo.getUserId());
        
        User loggedInUser = [SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        
        List<Attachment> attachments = new List<Attachment>();
        
        //attachments = [SELECT Id, Name, ContentType, BodyLength, OwnerId, ParentId FROM Attachment WHERE ParentId IN (SELECT Id FROM Case WHERE Id = :identifier)];
        
        attachments = [SELECT Id, Name, ContentType, BodyLength, OwnerId, ParentId FROM Attachment WHERE ParentId = :identifier];
        
        List<OTNode> files = new List<OTNode>();
        
        for(Attachment attachment : attachments)  {
        
            files.add(new OTNode(attachment.Name, 0, false, attachment.ContentType, attachment.BodyLength));
        }
        
        return files;
    }
}