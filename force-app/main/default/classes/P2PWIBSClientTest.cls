/**
 * Test Class For WIBS API Proxy
 */
@isTest 
public  class P2PWIBSClientTest {
    
    public class WIBSClientTestVisitor implements AWSC_ResponseParserVisitor{
        public Integer responseStatus {get; set;}
        public String responseText {get; set;}
        public void visit(AWSC_ResponseParser responseParser){
			P2PWIBSClient.P2PWIBSResponseParser resP = (P2PWIBSClient.P2PWIBSResponseParser)responseParser;
            responseStatus = resP.responseStatus;
            responseText = resP.responseText;
            
            //if ! 204 - (text/plain) - parse and get list
            //create iterable from filenames
            //launch batch with iterable with scope = 1 
            //in batch - each process will download 1 file and process it for reconciliation
            //order status update to be handled by some PaymentProcessor class (e.g PaymentProcessor.updateToComplete(List<OrderIds))
        }
    }
	
    private static testmethod void testFileUpload(){
        P2PWIBSClient.WIBSRequestParam params = new P2PWIBSClient.WIBSRequestParam();
        params.fileName = 'APITest1.txt';
        params.fileData = 'this is dummy data';
        P2PWIBSClient client = new P2PWIBSClient();
        WIBSClientTestVisitor visitor = new WIBSClientTestVisitor();
        client.callWIBSApp(P2PWIBSClient.WIBS_REQUEST_TYPE.FILEUPLOAD, visitor, params);
        
        System.assert(visitor.responseStatus == P2PWIBSConstants.HTTP_ACCEPTED, 'Incorrect Response Status - Expected Accepted, received: ' + visitor.responseStatus);
    } 
    
    private static testmethod void testFilesList(){
        P2PWIBSClient.WIBSRequestParam params = new P2PWIBSClient.WIBSRequestParam();
        P2PWIBSClient client = new P2PWIBSClient();
        WIBSClientTestVisitor visitor = new WIBSClientTestVisitor();
        client.callWIBSApp(P2PWIBSClient.WIBS_REQUEST_TYPE.FILESLIST, visitor, params);
        System.assert(visitor.responseStatus == P2PWIBSConstants.HTTP_OK, 'Incorrect Response Status - Expected OK, received: ' + visitor.responseStatus);
        System.assert(visitor.responseText == 'TNSWPTP_CashAppliedFile_21092017.csv\nTNSWPTP_RECALLL_23082017053511.txt\nTNSWPTP_DEEDS_23082017053511.txt\nTNSWPTP_DERPS_23082017053712.txt\n', 'Incorrect Response Data');
    } 
    private static testmethod void testFileDownload(){
        P2PWIBSClient.WIBSRequestParam params = new P2PWIBSClient.WIBSRequestParam();
        params.fileName = 'TNSWPTP_RECALLL_23082017053511.txt';
        P2PWIBSClient client = new P2PWIBSClient();
        WIBSClientTestVisitor visitor = new WIBSClientTestVisitor();
        client.callWIBSApp(P2PWIBSClient.WIBS_REQUEST_TYPE.FILEDOWNLOAD, visitor, params);
        System.assert(visitor.responseStatus == P2PWIBSConstants.HTTP_OK, 'Incorrect Response Status - Expected OK, received: ' + visitor.responseStatus);
        System.assert(visitor.responseText == '001111NSW TRANSPORT PTP           20320011704970000022092017                                                                                                                                            \r\n190100000019998               B00000050000IB          2   0000000000CBA2209201701412681799310000                                                                                                        \r\n197100000019894               B00000020000IB          2   0000000000CBA2209201701414373669310000                                                                                                        \r\n186100000019795               B00001000000IB          2   0000000000CBA2209201703537868019310000                                                                                                        \r\n9000000003000000000000000001070000000000000000000000000000000000000000000000000000000000000000000000000000000                                                                                           ', 'Incorrect Response Data');
    }
    private static testmethod void testFileDelete(){
        P2PWIBSClient.WIBSRequestParam params = new P2PWIBSClient.WIBSRequestParam();
        params.fileName = 'APITest1.txt';
        P2PWIBSClient client = new P2PWIBSClient();
        WIBSClientTestVisitor visitor = new WIBSClientTestVisitor();
        client.callWIBSApp(P2PWIBSClient.WIBS_REQUEST_TYPE.FILEDELETE, visitor, params);
        System.assert(visitor.responseStatus == P2PWIBSConstants.HTTP_NO_CONTENT, 'Incorrect Response Status - Expected NO_CONTENT, received: ' + visitor.responseStatus);
    }
}