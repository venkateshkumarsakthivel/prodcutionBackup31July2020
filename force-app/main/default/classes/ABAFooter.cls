/**
 * @name ABAFooter.cls
 * @description this class is responsible to hold properties required to generate ABA file footer, also this will take care of
 * generating footer line using specification from ABA document as this will be fixedWidth format specification. specification of
 * each of the property is mentioned as inline comment against declaration and initialization statements.
 * initialization and population on each of the property will happen in the constructor of the class.
 */  

public with sharing class ABAFooter {

    public String recordType { get; private set; } { this.recordType = '7'; } /* length: 1 */
    public String bsbformatFillter { get; private set; } { this.bsbformatFillter = '999-999'; } /* length: 7 */
    public String blank12 { get; private set; } { this.blank12 = ''; this.blank12 = this.blank12.leftPad(12); } /* length: 12 */
    public String fileNetTotalAmount { get; set; } /* length: 10 */
    public String fileCreditTotalAmount { get; set; } /* length: 10 */
    public String fileDebitTotalAmount { get; set; } /* length: 10 */
    public String blank24 { get; private set; } { this.blank24 = ''; this.blank24 = this.blank24.leftPad(24); } /* length: 24 */
    public String fileCountOfTransactions { get; set; } /* length: 6 */
    public String blank40 { get; private set; } { this.blank40 = ''; this.blank40 = this.blank40.leftPad(40); } /* length: 40 */

    /**
    * parameterized constructor to populate footer attributes / properties as per trasactions considered / included for / in current ABA file.
    */
    public ABAFooter(Decimal pfileNetTotalAmount, Decimal pfileCreditTotalAmount, Decimal pfileDebitTotalAmount, Integer pfileCountOfTransactions)  {
        this.fileNetTotalAmount = String.valueOf((pfileNetTotalAmount * 100).intValue());
        this.fileCreditTotalAmount = String.valueOf((pfileCreditTotalAmount * 100).intValue());
        this.fileDebitTotalAmount = String.valueOf((pfileDebitTotalAmount * 100).intValue());
        this.fileCountOfTransactions = String.valueOf(pfileCountOfTransactions);
        
    }
    
    override public String toString()  {
        String footer = '';
        footer += this.recordType + this.bsbformatFillter + this.blank12;
        footer += this.fileNetTotalAmount.leftPad(10, '0');
        footer += this.fileCreditTotalAmount.leftPad(10, '0');
        footer += this.fileDebitTotalAmount.leftPad(10,'0') + this.blank24;
        footer += this.fileCountOfTransactions.leftPad(6, '0') + this.blank40;
        return footer;
    }

}