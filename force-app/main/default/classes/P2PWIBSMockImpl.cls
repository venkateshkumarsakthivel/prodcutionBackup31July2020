/**
 * Mock Implementation for WIBS API test
 * Built and used only for Mock Integration 
 * for E2E flow testing prior to SIT
 */
public class P2PWIBSMockImpl implements AWSC_TestProxy {

    public AWSC_Response execute(AWSC_Request request){
        
        String endpoint = request.getEndpoint();
        AWSC_Request.RequestMethod method = request.method;
        P2PWIBSClient.WIBSRequestParam reqParams = (P2PWIBSClient.WIBSRequestParam) ((AWSC_ServiceRestRequest)request).getParams();

        String responseText = '';
        Integer statusCode = 200;
        AWSC_Response response;
        if(reqParams.requestType == P2PWIBSClient.WIBS_REQUEST_TYPE.FILEUPLOAD){
            //202-Accepted, 400-BadRequest, 403-Forbidden, 404-Notfound, 500-InternalServerError, 503-ServiceUnavailable
            response = new AWSC_Response('wibs-mock', '', 202, 'text/plain');
        } else if(reqParams.requestType == P2PWIBSClient.WIBS_REQUEST_TYPE.FILESLIST){
            //200-OK, 204-NoContent, 403-Forbidden, 404-Notfound, 500-InternalServerError
            responseText = 'TNSWPTP_CashAppliedFile_21092017.csv\nTNSWPTP_RECALLL_23082017053511.txt\nTNSWPTP_DEEDS_23082017053511.txt\nTNSWPTP_DERPS_23082017053712.txt\n';
            response = new AWSC_Response('wibs-mock', responseText, 200, 'text/plain');
        } else if(reqParams.requestType == P2PWIBSClient.WIBS_REQUEST_TYPE.FILEDOWNLOAD){
            //200-OK, 403-Forbidden, 404-Notfound, 500-InternalServerError
            if(reqParams.fileName.trim().equalsIgnoreCase('TNSWPTP_DEEDS_23082017053511.txt'))  {
				responseText = 
							'0ENTR             01WBC       P2P Commission            999123P2P WBC PAY 230817                                        G\r\n'+
							'1032-002   123465 13    123067Title of Account all Okey       10001004699       032-002   123465okay remitter   00000000R\r\n'+
							'7999-999               1230670         0   1230670                        000010                                        G\r\n'+
							'0RLSE             01WBC       P2P Commission            999123P2P WBC PAY 230817                                        G\r\n'+
							'1032-002   123465 13    123067Title of Account all Okey       10001005649       032-002   123465okay remitter   00000000G\r\n'+
							'1032-002   123465 13    123067Title of Account all Okey       10001005649       032-002   123465okay remitter   00000000G\r\n'+
							'1032-002   123465 13    123067Title of Account all Okey       10001005649       032-002   123465okay remitter   00000000G\r\n'+
							'1032-002   123465 13    123067Title of Account all Okey       10001005649       032-002   123465okay remitter   00000000G\r\n'+
							'1032-002   123465 13    123067Title of Account all Okey       10001005649       032-002   123465okay remitter   00000000G\r\n'+
							'1032-002   123465 13    123067Title of Account all Okey       10001005649       032-002   123465okay remitter   00000000C\r\n'+
							'1032-002   123465 13    123067Title of Account all Okey       10001005649       032-002   123465okay remitter   00000000R\r\n'+
							'1032-002   123465 13    123067Title of Account all Okey       10001005649       032-002   123465okay remitter   00000000G\r\n'+
							'1032-002   123465 13    123067Title of Account all Okey       10001005649       032-002   123465okay remitter   00000000G\r\n'+
							'1032-002   123465 13    123067Title of Account all Okey       10001005649       032-002   123465okay remitter   00000000G\r\n';
            } else if(reqParams.fileName.trim().equalsIgnoreCase('TNSWPTP_DERPS_23082017053712.txt'))  {
				responseText = 
							'0                 01WBC       WESTPAC BANKING CORP      999123            230817032-002123465                                                                   \r\n' +
							'2032-797999999   6130000003212WOODS ANTHONY                   10001005659       637-000163344938COMPANYX        05184894COMPANYX INSURANCE        050203        \r\n' +
							'7999-999            000000000000000000000000000000                        000000                                                                                ';
            } else if(reqParams.fileName.trim().equalsIgnoreCase('TNSWPTP_CashAppliedFile_21092017.csv'))  {
            		responseText = '"Date","Receipt Number","Supplier Name","Payment Reference","Payment Amount","Transaction Code","Transaction Description","Card Type","Card Holder Name","Card Number","Customer Reference Number","Source Product"\n"22-Aug-2017","1021950776","TNSWPTP","TNSWPTP10001005669","120.00","G","WBC Exception Processing released successfully","","","","10001005669","QuickWeb"';
            } else if(reqParams.fileName.trim().equalsIgnoreCase('TNSWPTP_RECALLL_23082017053511.txt'))  {
            		responseText = '001111NSW TRANSPORT PTP           20320011704970000022092017                                                                                                                                            \r\n190100000019998               B00000050000IB          2   0000000000CBA2209201701412681799310000                                                                                                        \r\n197100000019894               B00000020000IB          2   0000000000CBA2209201701414373669310000                                                                                                        \r\n186100000019795               B00001000000IB          2   0000000000CBA2209201703537868019310000                                                                                                        \r\n9000000003000000000000000001070000000000000000000000000000000000000000000000000000000000000000000000000000000                                                                                           ';
            }
            
            response = new AWSC_Response('wibs-mock', responseText, 200, 'text/plain');
        } else if(reqParams.requestType == P2PWIBSClient.WIBS_REQUEST_TYPE.FILEDELETE){
            //204-NoContent, 403-Forbidden, 404-Notfound, 500-InternalServerError
            response = new AWSC_Response('wibs-mock', '', 204, 'text/plain');
        }
        return response;
    }
}