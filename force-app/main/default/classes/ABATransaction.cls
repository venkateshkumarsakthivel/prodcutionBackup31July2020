/**
 * @name ABATransaction.cls
 * @description this class is responsible to hold properties required to generate ABA file transaction line (line per transaction), also this will take care of
 * generating transaction line using specification from ABA document as this will be fixedWidth format specification. specification of
 * each of the property is mentioned as inline comment against declaration and initialization statements.
 * initialization and population on each of the property will happen in the constructor of the class.
 */  

public with sharing class ABATransaction {
    public String recordType { get; private set; } { this.recordType = '1'; } /* length: 1 */
    public String bankStateBranchNumber { get; set; } /* length: 7 */
    public String accountNumberToBeCreditedOrDebited { get; set; } /* length: 9, right justified and blank filled. */
    public String indicator { get; private set; } { this.indicator = ''; this.indicator = this.indicator.leftPad(1); } /* length: 1 */
    public String transactionCode { get; set; } /* length: 2 */
    public String amount { get; set; } /* length: 10, must be in cents without punctuation, right justified and ZERO filled. */
    public String titleOfAccountToBeCreditedOrDebited { get; set{titleOfAccountToBeCreditedOrDebited = value.length() > 32? value.substring(0,32): value;} } /* length: 32,  left justified and blank filled. */
    public String lodgementReference { get; set; } /* length: 18, left justified and blank filled. */
    public String traceRecord { get; set; }/* length: 16, BSBNumber appended with accountNumberToBeCreditedOrDebited */
    public String nameOfRemitter { get; set{nameOfRemitter = value.length() > 16? value.substring(0,16): value;} } /* length: 16, left justified and blank filled. */
    public String amountOfWithholdingTax { get; private set; } { this.amountOfWithholdingTax = ''; this.amountOfWithholdingTax = this.amountOfWithholdingTax.leftPad(8, '0'); } /* length: 8, blank filled only. */

    /**
    * parameterized constructor to populate footer attributes / properties as per trasactions considered / included for / in current ABA file.
    */
    public ABATransaction(String pbankStateBranchNumber, String paccountNumberToBeCreditedOrDebited, String ptransactionCode, Decimal pamount, String ptitleOfAccountToBeCreditedOrDebited, String plodgementReference, String pnameOfRemitter)  {
            this.bankStateBranchNumber = pbankStateBranchNumber;
        this.accountNumberToBeCreditedOrDebited = paccountNumberToBeCreditedOrDebited;
        this.transactionCode = ptransactionCode;
        this.amount = String.valueOf((pamount * 100).intValue());
        this.titleOfAccountToBeCreditedOrDebited = ptitleOfAccountToBeCreditedOrDebited;
        this.lodgementReference = plodgementReference;
        this.nameOfRemitter = pnameOfRemitter;
    }
    
    override public String toString()  {
        String abaTransaction = '';
        abaTransaction += this.recordType + this.bankStateBranchNumber;
        abaTransaction += this.accountNumberToBeCreditedOrDebited.leftPad(9) + this.indicator + this.transactionCode;
        abaTransaction += this.amount.leftPad(10, '0');
        abaTransaction += this.titleOfAccountToBeCreditedOrDebited.rightPad(32) + this.lodgementReference.rightPad(18);
        abaTransaction += GlobalConstants.ABA_TRACE_RECORD_BSB.leftPad(7) + GlobalConstants.ABA_TRACE_RECORD_ACCOUNT_NUMBER.leftPad(9);
        abaTransaction += GlobalConstants.ABA_TRACE_RECORD_ACCOUNT_NAME.rightPad(16) + this.amountOfWithholdingTax;
        abaTransaction += '\r\n';
        System.debug(abaTransaction);
        return abaTransaction;
    }
    
}