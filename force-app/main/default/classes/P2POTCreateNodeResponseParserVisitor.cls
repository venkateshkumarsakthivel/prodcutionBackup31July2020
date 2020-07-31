public with sharing class P2POTCreateNodeResponseParserVisitor implements AWSC_ResponseParserVisitor {
	public Boolean success {get; set;}
    public void visit(AWSC_ResponseParser responseParser){
		P2POTAppClient.P2POTCreateNodeResponseParser p2POTCreateNodeResponseParser = (P2POTAppClient.P2POTCreateNodeResponseParser) responseParser;
		success = p2POTCreateNodeResponseParser.success;
    }
}