public with sharing class P2PWIBSFileUploadResponseParserVisitor implements AWSC_ResponseParserVisitor {
	public Map<String, String> response { get; set; } { this.response = new Map<String, String>(); }
	public void visit(AWSC_ResponseParser responseParser)  {
		P2PWIBSClient.P2PWIBSFileUploadResponseParser p2PWIBSFileUploadResponseParser = (P2PWIBSClient.P2PWIBSFileUploadResponseParser) responseParser;
		this.response = p2PWIBSFileUploadResponseParser.response;
	}    
}