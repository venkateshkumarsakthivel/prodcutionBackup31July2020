public with sharing class P2PWIBSFilesListResponseParserVisitor implements AWSC_ResponseParserVisitor {
	public List<String> files { get; set; } { this.files = new List<String>(); }
	public void visit(AWSC_ResponseParser responseParser)  {
		P2PWIBSClient.P2PWIBSFilesListResponseParser p2PWIBSFilesListResponseParser = (P2PWIBSClient.P2PWIBSFilesListResponseParser) responseParser;
		this.files = p2PWIBSFilesListResponseParser.flist.split('\n');
	}    
}