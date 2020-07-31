/**
* Server side Rest resource controller for ASP Dashboard

* This controller services FileUpload.cmp component
*/

public without sharing class FileUploadController {
    
    @AuraEnabled
    public static String  attach(String parent, String name, String contents, String ctype)  {

        
        try {
        		//insert attachment;
			P2POTAppClient appClient = new P2POTAppClient();
			
			P2POTAppClient.P2POTRequestParam nodeParams = new P2POTAppClient.P2POTRequestParam();
			
			nodeParams.nodeName = '202408'; //Michael Assocs Pty Ltd
			nodeParams.fileData = contents;
			nodeParams.fileBlob = EncodingUtil.base64Decode(contents);
			nodeParams.fileName = name;
			nodeParams.ctype = ctype;
            System.debug('before actual call');
            System.debug(name);
			appClient.callOTApp(P2POTAppClient.OT_REQUEST_TYPE.CREATENODE, null, nodeParams);
            return 'SUCCESS';
        } catch(Exception e)  {
            System.debug(e.getMessage());
            return 'FAILURE';
        }

        
    }
    
}