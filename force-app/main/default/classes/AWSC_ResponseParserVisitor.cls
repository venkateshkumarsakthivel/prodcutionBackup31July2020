/**
 * Visitor for passing response parse data back to the invocation control
 */
public interface AWSC_ResponseParserVisitor {
    void visit(AWSC_ResponseParser responseParser);
}