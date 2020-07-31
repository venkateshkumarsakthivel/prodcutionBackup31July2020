public with sharing class P2POTBrowseNodeResponseParserVisitor implements AWSC_ResponseParserVisitor {
	public List<OTNode> otNodes {get;set;}
    public void visit(AWSC_ResponseParser responseParser){
		P2POTAppClient.P2POTBrowseNodeResponseParser p2POTBrowseNodeResponseParser = (P2POTAppClient.P2POTBrowseNodeResponseParser) responseParser;

    		for(OTNode node : p2POTBrowseNodeResponseParser.otNodes)  {
    			System.debug('Name : ' + node.name);
    		}

		this.otNodes = p2POTBrowseNodeResponseParser.otNodes;
    }    
}