public with sharing class P2PWIBSFileDownloadResponseParserVisitor implements AWSC_ResponseParserVisitor {
    public String data { get; set; } { this.data = ''; }
	public void visit(AWSC_ResponseParser responseParser)  {
		P2PWIBSClient.P2PWIBSFileDownloadResponseParser p2PWIBSFileDownloadResponseParser = (P2PWIBSClient.P2PWIBSFileDownloadResponseParser) responseParser;
		this.data = p2PWIBSFileDownloadResponseParser.data;
	}    
}