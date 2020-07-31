public with sharing class P2PWIBSSTResponseParserVisitor implements AWSC_ResponseParserVisitor  {
	public String  token { get; set; } { this.token = ''; }
	public void visit(AWSC_ResponseParser responseParser)  {
		P2PWIBSPaymentClient.P2PWIBSPaymentSecurityTokenResponseParser p2PWIBSPaymentSecurityTokenResponseParser = (P2PWIBSPaymentClient.P2PWIBSPaymentSecurityTokenResponseParser) responseParser;
		this.token = p2PWIBSPaymentSecurityTokenResponseParser.token;
	}
}